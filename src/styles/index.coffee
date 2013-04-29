# Scaffolds `styles` direcotory with base Stylus styles.
# Also installs Tâmia (tamia:framework) and creates/updates Gruntfile.

'use strict'

util = require 'util'
path = require 'path'
base = require '../base'
Gruntfile = require '../lib/gruntfile'

module.exports = class Generator extends base
	constructor: (args, options) ->
		super(args, options)
		htdocs_dir = @preferDir ['htdocs', 'www']
		@htdocs_prefix = if htdocs_dir then "#{htdocs_dir}/" else ''

Generator::styles = ->
	@template 'styles/index.styl'
	@template 'styles/styles.styl'
	@template 'styles/print.styl'

Generator::gruntfile = ->
	gf = new Gruntfile()

	config =
		compile:
			options:
				'include css': true
				'define':
					DEBUG: gf.JS 'debug'
				'paths': ['tamia']
			files: {}
	config.compile.files[@isWordpressTheme() ? 'style.css' : "#{@htdocs_prefix}build/styles.css"] = 'styles/index.styl'
	gf.addSection 'stylus', config

	gf.addWatcher 'stylus',
		files: 'styles/**'
		tasks: 'stylus'

	gf.addTask 'default', 'stylus'
	gf.addTask 'deploy', 'stylus'

	gf.save()


