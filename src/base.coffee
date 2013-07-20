'use strict'

path = require 'path'
fs = require 'fs'
util = require 'util'
_ = require 'lodash'
Configstore = require 'configstore'
yeoman = require 'yeoman-generator'

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

		# User data: ~/.config/configstore/yomen-generator.yml
		# TODO: Ask to fill values if they are default
		@config = new Configstore 'yomen-generator',
			authorName: 'John Smith'
			authorUrl: 'http://example.com'
		_.extend this, @config.all

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

Generator::installFromBower = (name) ->
	return  if @options['skip-bower']
	return  if @options['skip-install']
	@bowerInstall name, {save: true}, ->

Generator::installFromNpm = (name) ->
	return  if @options['skip-npm']
	return  if @options['skip-install']
	@npmInstall name, {'save-dev': true}, ->

