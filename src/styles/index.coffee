# Scaffolds `styles` direcotory with base Stylus styles.
# Also installs Tâmia (tamia:framework) and creates/updates Gruntfile.

'use strict'

util = require 'util'
path = require 'path'
base = require '../base'
Gruntfile = require '../lib/gruntfile'

module.exports = class Generator extends base

Generator::styles = ->
	@template 'styles/index.styl'
	@template 'styles/styles.styl'

Generator::gruntfile = ->
	gf = new Gruntfile()
	return  if gf.hasSection 'stylus'

	config =
		compile:
			options:
				'include css': true
				'define':
					DEBUG: gf.JS 'debug'
				'paths': ['tamia']
			files: {}
	config.compile.files[if @isWordpressTheme() then 'style.css' else "#{@htdocs_prefix}build/styles.css"] = 'styles/index.styl'
	gf.addSection 'stylus', config

	gf.addWatcher 'stylus',
		files: 'styles/**'
		tasks: 'stylus'

	gf.addTask 'default', 'stylus'
	gf.addTask 'deploy', 'stylus'

	gf.save()

Generator::dependencies = ->
	@installFromNpm ['grunt', 'matchdep', 'grunt-contrib-stylus', 'grunt-contrib-watch']
	# @hookFor 'tamia:framework', @args
