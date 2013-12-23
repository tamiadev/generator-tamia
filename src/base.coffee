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

module.exports = class Generator extends yeoman.generators.Base
	constructor: (args, options) ->
		super(args, options)

		@args = args
		@options = options

		# Single folder for all templates
		@sourceRoot path.join __dirname, 'templates'

		# Check environment
		htdocs_dir = @preferDir ['htdocs', 'www']
		@htdocs_prefix = if htdocs_dir then "#{htdocs_dir}/" else ''

		# Project name
		@project = path.basename process.cwd()

		# Optional CLI argument: @name
		@argument 'name', {type: String, required: false}

		# User data: ~/.config/configstore/yeoman-generator.yml
		# TODO: Ask to fill values if they are default
		@config = new Configstore 'yeoman-generator',
			authorName: 'John Smith'
			authorUrl: 'http://example.com'
		@_.extend this, @config.all

		# Expose useful libraries
		@grunt = grunt
		@chalk = chalk
		@moment = moment
		@log.update = @_log_update

# @hookFor that doesn’t requre to be invoked from constructor.
# Can be used inside @prompt.
Generator::hookFor = (name, config) ->
	config ?= {}

	# Add the corresponding option to this class, so that we output these hooks in help
	@option name,
		desc: @_.humanize(name) + ' to be invoked'
		defaults: @options[name] or ''

	@_hooks.push (@_.defaults config, name: name)

	this

Generator::copyIfNot = (filepath) ->
	@copy filepath, filepath  unless (fs.existsSync filepath)

###
Renders template and saves it. Silently exists when file already exists.

@param {String} template Template file name
@param {String} [filepath] Destination file
###
Generator::templateIfNot = (template, filepath) ->
	filepath = template  unless filepath
	@template template, filepath  unless (fs.existsSync filepath)

###
Renders template, saves file and opens it in default editor.

@param {String} template Template file name
@param {String} [filepath] Destination file
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
	@openInEditor filepath, curpos

###
Finds “cursor” position in template: line and column of “®” symbol.

@param {String} File contents
@returns {String} line:column
###
Generator::getCursorPosition = (str) ->
	[str, __] = str.split '®'
	lines = str.split '\n'
	line = lines.length
	column = lines.pop().length + 1
	"#{line}:#{column}"

Generator::stop = (message) ->
	@error message
	process.exit()

Generator::stopIfExists = (filepath) ->
	return  unless fs.existsSync filepath
	@stop "File `#{filepath}` already exists."

Generator::writeFile = (filepath, content) ->
	fs.writeFileSync (path.join process.cwd(), filepath), content

Generator::copyEditorConfig = ->
	@copyIfNot '.editorconfig'

Generator::preferDir = (preferred) ->
	for dir in preferred
		return dir  if fs.existsSync dir
	null

Generator::isWordpress = ->
	fs.existsSync 'wp-config.php'

Generator::isWordpressTheme = ->
	(fs.existsSync 'header.php') and (fs.existsSync 'footer.php') and (fs.existsSync 'functions.php')

Generator::installFromBower = (packages, skip_gitignore = false) ->
	return  if @options['skip-bower']
	return  if @options['skip-install']
	@echo 'Installing ' + (@grunt.log.wordlist packages) + ' from Bower...'
	@gitIgnore 'bower_components'  unless skip_gitignore
	@templateIfNot 'bower.json'
	@bowerInstall packages, {save: true}, ->

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

Generator::printLog = (func, messages...) ->
	colorize = (msg) ->
		msg.replace(/`(.*?)`/g, (m, str) -> chalk.cyan(str))

	messages = @_.map messages, colorize
	@log[func] messages...

Generator::echo = ->
	console.log arguments...

Generator::ok = ->
	@printLog 'ok', arguments...

Generator::error = ->
	@printLog 'error', arguments...

Generator::printList = (list) ->
	width = @_.reduce list, ((max, row) ->
		Math.max row[0].length, max
		), 0

	@_.each list, (row) =>
		@echo (@chalk.white(@_.pad row[0], width)), row[1]

Generator::readJsonFile = (filepath) ->
	JSON.parse(@readFileAsString(filepath))

Generator::readTemplate = (filepath) ->
	fs.readFileSync (path.join @sourceRoot(), filepath), encoding: 'utf-8'

Generator::process = (filepath) ->
	@engine (@readTemplate filepath), this

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

@param {String} filepath Destination file
@param {String} [curpos] Cursor position: "line:column"
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

Generator::_log_update = ->
	@write (chalk.yellow '   update ')
	@write (util.format.apply util, arguments) + '\n'
	this
