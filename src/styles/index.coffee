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

	buildCss = if @isWordpressTheme() then 'style.css' else "#{@htdocs_prefix}build/styles.css"

	gf.addBanner this

	# Stylus
	unless gf.hasSection 'stylus'
		config =
			options:
				'include css': true
				'urlfunc': 'embedurl'
				'banner': '<%= banner %>'
				'define':
					DEBUG: gf.JS 'debug'
				'paths': ['tamia']
				'use': [
					gf.JS """-> require('stylobuild')(
							autoprefixer:
								browsers: 'last 2 versions, ie 8, ie 9'
							csso: not debug
							pixrem: false
)"""
				]
			compile:
				files: {}
		config.compile.files[buildCss] = 'styles/index.styl'
		gf.addSection 'stylus', config

		gf.addWatcher 'stylus',
			files: 'styles/**'
			tasks: 'stylus'

	gf.addTask 'default', ['stylus']
	gf.addTask 'deploy', ['stylus']

	gf.save()

Generator::dependencies = ->
	@installFromNpm ['grunt', 'load-grunt-tasks', 'grunt-contrib-stylus', 'grunt-contrib-watch', 'stylobuild']
