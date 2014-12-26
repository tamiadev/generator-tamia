'use strict'

path = require 'path'
fs = require 'fs'
util = require 'util'
exec = (require 'child_process').exec
Configstore = require 'configstore'
yeoman = require 'yeoman-generator'
grunt = require 'grunt'
chalk = require 'chalk'
moment = require 'moment'

Gruntfile = require './gruntfile'

module.exports = class Generator extends yeoman.generators.Base
	constructor: (args, options) ->
		super(args, options)

		# Config
		package_name = require('./package').name
		@userConfig = new Configstore package_name
		@_.extend this, @userConfig.all
		if not @authorName and options.name isnt 'init'
			@stop 'Generator config not found. Please run yo tamia:init.'

		# Single folder for all templates
		@sourceRoot path.join __dirname, 'templates'

		# Check environment
		htdocs_dir = @preferDir ['htdocs', 'www']
		@htdocs_prefix = if htdocs_dir then "#{htdocs_dir}/" else ''

		# Project name
		@project = path.basename process.cwd()

		# Optional CLI argument: @name
		@argument 'name', {type: String, required: false}

		# Expose useful libraries
		@grunt = grunt
		@chalk = chalk
		@moment = moment
		@log.update = @_logUpdate

###
@hookFor that doesn’t requre to be invoked from constructor. Can be used inside @prompt.
###
Generator::hookFor = (name, config) ->
	config ?= {}

	# Add the corresponding option to this class, so that we output these hooks in help
	@option name,
		desc: @_.humanize(name) + ' to be invoked'
		defaults: @options[name] or ''

	@_hooks.push (@_.defaults config, name: name)

	this

###
Copies file if it doesn’t exist in a destination location.

@param {String} filepath Destination file.
###
Generator::copyIfNot = (filepath) ->
	@copy filepath, filepath  unless (fs.existsSync filepath)

###
Renders template and saves it. Silently exists when file already exists.

@param {String} template Template file name.
@param {String} [filepath] Destination file.
###
Generator::templateIfNot = (template, filepath) ->
	filepath = template  unless filepath
	@template template, filepath  unless (fs.existsSync filepath)

###
Renders template, saves file and opens it in default editor.

@param {String} template Template file name.
@param {String} [filepath] Destination file.
###
Generator::templateAndOpen = (template, filepath) ->
	filepath = template  unless filepath
	@stopIfExists filepath

	contents = @process template

	curpos = undefined
	if contents.indexOf '®' isnt -1
		curpos = @getCursorPosition contents
		contents = contents.replace /®/, ''

	@write filepath, contents

	process.nextTick =>
		@openInEditor filepath, curpos

###
Finds “cursor” position in template: line and column of “®” symbol.

@param {String} str File contents.
@returns {String} line:column.
###
Generator::getCursorPosition = (str) ->
	[str, __] = str.split '®'
	lines = str.split '\n'
	line = lines.length
	column = lines.pop().length + 1
	"#{line}:#{column}"

###
Prints an error message and exits.

@param {String} message Error message.
###
Generator::stop = (message) ->
	@error message
	process.exit()

###
Prints an error message and exits if file exists.

@param {String} [filepath] Path to a file.
###
Generator::stopIfExists = (filepath) ->
	return  unless fs.existsSync filepath
	@stop "File `#{filepath}` already exists."

###
Writes file.

@param {String} [filepath] Path to a file.
@param {String} [content] Contents.
###
Generator::writeFile = (filepath, content) ->
	fs.writeFileSync (path.join process.cwd(), filepath), content

###
Chooses first existent folder.

@param [Array] dirs Folders list.
###
Generator::preferDir = (dirs) ->
	for dir in dirs
		return dir  if fs.existsSync dir
	null

###
Checks whether current folder is a Wordpress istallation.
###
Generator::isWordpress = ->
	fs.existsSync 'wp-config.php'

###
Checks whether current folder is a Wordpress theme folder.
###
Generator::isWordpressTheme = ->
	(fs.existsSync 'header.php') and (fs.existsSync 'footer.php') and (fs.existsSync 'functions.php')

###
Installs Bower packages.

@param {Array} packages Packages.
@param {Boolean} [skip_gitignore] Do not add `bower_components` to `.gitignore` (default: false).
###
Generator::installFromBower = (packages, skip_gitignore = false) ->
	return  if @options['skip-bower']
	return  if @options['skip-install']
	filepath = 'bower.json'

	# Filter out already installed modules to speed up installation
	if fs.existsSync filepath
		json = @readJsonFile filepath
		packages = @_.filter packages, ((pkg) -> not json?.dependencies[pkg])
	return  if not packages.length

	@echo 'Installing ' + (@grunt.log.wordlist packages) + ' from Bower...'
	@gitIgnore 'bower_components'  unless skip_gitignore
	@templateIfNot filepath
	@bowerInstall packages, {save: true}, ->

###
Installs npm packages.

@param {Array} packages Packages.
###
Generator::installFromNpm = (packages) ->
	return  if @options['skip-npm']
	return  if @options['skip-install']
	filepath = 'package.json'

	# Filter out already installed modules to speed up installation
	if fs.existsSync filepath
		json = @readJsonFile filepath
		packages = @_.filter packages, ((pkg) -> not json?.devDependencies[pkg])
	return  if not packages.length

	@echo 'Installing ' + (@grunt.log.wordlist packages) + ' from npm...'
	@gitIgnore 'node_modules'
	@templateIfNot filepath
	@npmInstall packages, {'save-dev': true}, ->

###
Prints message (`console.log` alias).
###
Generator::echo = ->
	console.log arguments...

###
Prints OK message with colorization (text `like this` becomes cyan).
###
Generator::ok = ->
	@_printLog 'ok', arguments...

###
Prints error message with colorization (text `like this` becomes cyan).
###
Generator::error = ->
	@_printLog 'error', arguments...

###
Prints list in a table:
*First row header* Row description.
*Second header*    Row description.

@params {Array} list List.
###
Generator::printList = (list) ->
	width = @_.reduce list, ((max, row) ->
		Math.max row[0].length, max
		), 0

	@_.each list, (row) =>
		@echo (@chalk.white(@_.pad row[0], width)), row[1]

###
Reads a JSON file.

@param {String} [filepath] Path to a file.
###
Generator::readJsonFile = (filepath) ->
	JSON.parse(@readFileAsString(filepath))

###
Reads a template from templates folder.

@param {String} [filepath] Path to a file.
###
Generator::readTemplate = (filepath) ->
	fs.readFileSync (path.join @sourceRoot(), filepath), encoding: 'utf-8'

###
Reads a template from templates folder and processes it.

@param {String} [filepath] Path to a file.
###
Generator::process = (filepath) ->
	@engine (@readTemplate filepath), this

###
Adds a pattern to `.gitignore`. Creates the file if it doesn’t exist.

@param {String} pattern Ignore pattern.
###
Generator::gitIgnore = (pattern) ->
	filepath = '.gitignore'
	if fs.existsSync filepath
		ignores = (@readFileAsString filepath).split '\n'
	else
		ignores = []

	return  if pattern in ignores

	ignores.push pattern
	@writeFile filepath, (ignores.join '\n')

	@ok "`#{pattern}` added to .gitignore."

###
Opens file in default editor.

@param {String} filepath Destination file.
@param {String} [curpos] Cursor position: "line:column".
###
Generator::openInEditor = (filepath, curpos) ->
	done = @async()
	filepath += ":#{curpos}"  if curpos
	exec "$EDITOR '#{filepath}'", done

###
Deletes the specified filepath. Will deletes files and folders recursively.

@param {String} filepath Path to delete.
###
Generator::delete = ->
	grunt.file.delete arguments...

###
Inits Gruntfile (creates if necessary).
You have to call this function before using `@gf`.
###
Generator::initGruntfile = ->
	# Copy template if file doesn’t exist
	if not fs.existsSync(filename)
		@template 'Gruntfile.js'
		@ok (chalk.green 'Gruntfile:') + "created"

	@gf = new Gruntfile()

Generator::_logUpdate = ->
	@write (chalk.yellow '   update ')
	@write (util.format.apply util, arguments) + '\n'
	this

Generator::_printLog = (func, messages...) ->
	colorize = (msg) ->
		msg.replace(/`(.*?)`/g, (m, str) -> chalk.cyan(str))

	messages = @_.map messages, colorize
	@log[func] messages...
