'use strict'

path = require 'path'
util = require 'util'
exec = (require 'child_process').exec
Configstore = require 'configstore'
yeoman = require 'yeoman-generator'
through = require 'through2'
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

		@skipConflicter = [
			'.yo-rc.json'
			'.yo-rc-global.json'
		]

		# Expose useful libraries
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
	@copy filepath, filepath  unless (@exists filepath)

###
Renders template and saves it.

@param {String} template Template file name.
@param {String} [filepath] Destination file.
###
Generator::template = (template, filepath) ->
	filepath = template  unless filepath
	@fs.copyTpl @templatePath(template), @destinationPath(filepath), this

###
Renders template and saves it. Silently exists when file already exists.

@param {String} template Template file name.
@param {String} [filepath] Destination file.
###
Generator::templateIfNot = (template, filepath) ->
	filepath = template  unless filepath
	@template template, filepath  unless (@exists filepath)

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
	return  unless @exists filepath
	@stop "File `#{filepath}` already exists."

###
Chooses first existent folder.

@param [Array] dirs Folders list.
###
Generator::preferDir = (dirs) ->
	for dir in dirs
		return dir  if @exists dir
	null

###
Checks whether current folder is a Wordpress istallation.
###
Generator::isWordpress = ->
	@exists 'wp-config.php'

###
Checks whether current folder is a Wordpress theme folder.
###
Generator::isWordpressTheme = ->
	(@exists 'header.php') and (@exists 'footer.php') and (@exists 'functions.php')

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
	if @exists filepath
		json = @fs.readJSON filepath
		packages = @_.filter packages, ((pkg) -> not json?.dependencies[pkg])
	return  if not packages.length

	@echo 'Installing ' + (@wordlist packages) + ' from Bower...'
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

	# Create package.json if needed
	unless @exists filepath
		@template filepath

	# Filter out already installed modules to speed up installation
	json = @fs.readJSON filepath
	packages = @_.filter packages, ((pkg) -> not json?.devDependencies?[pkg])
	return  unless packages.length

	@echo 'Installing ' + (@wordlist packages) + ' from npm...'
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
Prints array as a comma separated list.

@params {Array} items Items array.
###
Generator::wordlist = (items) ->
	items = items.map (item) ->
		return chalk.cyan(item)
	return items.join(', ')

###
Prints list in a table:
*First row header* Row description.
*Second header*    Row description.

@params {Array} items Items array.
###
Generator::printList = (items) ->
	width = @_.reduce items, ((max, row) ->
		Math.max row[0].length, max
		), 0

	@_.each items, (row) =>
		@echo (@chalk.white(@_.pad row[0], width)), row[1]

###
Reads a template from templates folder.

@param {String} [filepath] Path to a file.
###
Generator::readTemplate = (filepath) ->
	@read @templatePath(filepath)

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
	if @exists filepath
		ignores = (@read filepath).split '\n'
	else
		ignores = []

	return  if pattern in ignores

	ignores.push pattern
	@writeForce filepath, (ignores.join '\n')

	@ok "`#{pattern}` added to .gitignore"

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
Writes file to disk.

@param {String} filepath File path.
@param {String} contents Contents to write.
###
Generator::write = ->
	@fs.write arguments...

###
Writes file to disk (skips collision check).

@param {String} filepath File path.
@param {String} contents Contents to write.
###
Generator::writeForce = (filepath, contents) ->
	@skipConflicter.push path.basename filepath
	@fs.write arguments...

###
Reads file from disk.

@param {String} filepath File path.
@return {String}
###
Generator::read = ->
	@fs.read arguments...

###
Deletes the specified filepath. Will deletes files and folders recursively.

@param {String} filepath Path to delete.
###
Generator::delete = ->
	@fs.delete arguments...

###
Check whether file exists.

@param {String} filepath File path.
###
Generator::exists = ->
	@fs.exists arguments...

###
Inits Gruntfile (creates if necessary).
@return {Gruntfile}
###
Generator::initGruntfile = ->
	filename = 'Gruntfile.js'

	# Copy template if file doesn’t exist
	if not @exists filename
		@template filename
	gruntfile = @read filename

	return new Gruntfile({file: filename, source: gruntfile})

###
Saves Gruntfile.
@param {Gruntfile} gruntfile Gruntfile class instance.
###
Generator::saveGruntfile = (gruntfile) ->
	@writeForce gruntfile.file, gruntfile.code()

Generator::_logUpdate = ->
	@write (chalk.yellow '   update ')
	@write (util.format.apply util, arguments) + '\n'
	this

Generator::_printLog = (func, messages...) ->
	colorize = (msg) ->
		msg.replace(/`(.*?)`/g, (m, str) -> chalk.cyan(str))

	messages = @_.map messages, colorize
	@log[func] messages...

###
Write memory fs file to disk and logging results.
Instead of internal Yeomen’s _writeFiles function this version uses custom @skipConflicter array of files that should
be excluded from collision check.

@param {Function} done Callback once files are written
###
Generator::_writeFiles = (done) ->
	self = this

	conflictChecker = through.obj (file, enc, cb) ->
		stream = this

		# These files should not be processed by the conflicter. Just pass through
		filename = path.basename file.path
		if filename in self.skipConflicter
			@push file
			return cb()

		self.conflicter.checkForCollision file.path, file.contents, (err, status) ->
			return cb(err)  if err
			if status isnt 'skip'
				stream.push file
			cb()

		self.conflicter.resolve()

	transformStreams = @_transformStreams.concat [conflictChecker]
	@fs.commit transformStreams, ->
		done()
