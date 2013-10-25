'use strict'

path = require 'path'
fs = require 'fs'
util = require 'util'
_ = require 'lodash'
Configstore = require 'configstore'
yeoman = require 'yeoman-generator'
grunt = require 'grunt'
chalk = require 'chalk'

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

		# User data: ~/.config/configstore/yeoman-generator.yml
		# TODO: Ask to fill values if they are default
		@config = new Configstore 'yeoman-generator',
			authorName: 'John Smith'
			authorUrl: 'http://example.com'
		_.extend this, @config.all

		# Expose useful libraries
		@grunt = grunt
		@chalk = chalk

Generator::ifYes = (prop) ->
	/y/i.test prop

Generator::unlessNo = (prop) ->
	not (/n/i.test prop)

# @hookFor that doesn’t requre to be invoked from constructor.
# Can be used inside @prompt.
Generator::hookFor = (name, config) ->
	config ?= {}

	# Add the corresponding option to this class, so that we output these hooks in help
	@option name,
		desc: @_.humanize(name) + ' to be invoked'
		defaults: @options[name] or ''

	@_hooks.push (_.defaults config, name: name)

	this

Generator::copyIfNot = (filepath) ->
	@copy filepath, filepath  unless (fs.existsSync filepath)

Generator::templateIfNot = (filepath) ->
	@template filepath  unless (fs.existsSync filepath)

Generator::stop = (message) ->
	@grunt.log.error message
	process.exit()

Generator::stopIfExists = (filepath) ->
	return  unless fs.existsSync filepath
	@stop "File \"#{filepath}\" already exists."

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

Generator::installFromBower = (packages) ->
	return  if @options['skip-bower']
	return  if @options['skip-install']
	@log.writeln 'Installing ' + (@grunt.log.wordlist packages) + ' from Bower...'
	@gitIgnore 'bower_components'
	@templateIfNot 'bower.json'
	@bowerInstall packages, {save: true}, ->

Generator::installFromNpm = (packages) ->
	return  if @options['skip-npm']
	return  if @options['skip-install']
	@log.writeln 'Installing ' + (@grunt.log.wordlist packages) + ' from npm...'
	@gitIgnore 'node_modules'
	@templateIfNot 'package.json'
	@npmInstall packages, {'save-dev': true}, ->

Generator::printList = (list) ->
	width = @_.reduce list, ((max, row) ->
		Math.max row[0].length, max
		), 0

	@_.each list, (row) =>
		@log.writeln (@chalk.white (@_.pad row[0], width)), row[1]

Generator::readJsonFile = (filepath) ->
	JSON.parse(@readFileAsString(filepath))

Generator::gitIgnore = (pattern) ->
	filepath = '.gitignore'
	if fs.existsSync filepath
		ignores = (@readFileAsString filepath).split '\n'
	else
		ignores = []

	return  if pattern in ignores

	ignores.push pattern
	@writeFile filepath, (ignores.join '\n')

	@log.writeln "\"#{pattern}\" added to .gitignore."
