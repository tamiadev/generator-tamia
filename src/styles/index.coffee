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

	# Stylus
	unless gf.hasSection 'stylus'
		config =
			options:
				'include css': true
				'urlfunc': 'embedurl'
				'define':
					DEBUG: gf.JS 'debug'
				'paths': ['tamia']
				'use': [gf.JS "() -> (require 'autoprefixer-stylus')('last 2 versions', 'ie 8')"]
			compile:
				files: {}
		config.compile.files[buildCss] = 'styles/index.styl'
		gf.addSection 'stylus', config

		gf.addWatcher 'stylus',
			files: 'styles/**'
			tasks: 'stylus'

	# CSSO
	# TODO: Temporary solution because of https://github.com/LearnBoost/stylus/issues/1137
	unless gf.hasSection 'csso'
		gf.addBanner this

		config =
			options:
				banner: '<%= banner %>'
			files: {}
		config.files[buildCss] = buildCss
		gf.addSection 'csso', config

	gf.addTask 'default', ['stylus', 'csso']
	gf.addTask 'deploy', ['stylus', 'csso']

	gf.save()

Generator::dependencies = ->
	@installFromNpm ['grunt', 'matchdep', 'grunt-contrib-stylus', 'grunt-contrib-watch', 'grunt-csso', 'autoprefixer-stylus']
