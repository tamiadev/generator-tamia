# Scaffolds `styles` direcotory with base Stylus styles.
# Also installs Tâmia (tamia:framework) and creates/updates Gruntfile.

'use strict'

util = require 'util'
path = require 'path'
base = require '../base'
Gruntfile = require '../lib/gruntfile'

module.exports = class Generator extends base

Generator::gruntfile = ->
	gf = new Gruntfile()

	gf.addBanner this

	unless gf.hasSection 'jshint'
		gf.addSection 'jshint',
			options:
				jshintrc: '.jshintrc'
			files: ["#{@htdocs_prefix}js/mylibs/*.js", "#{@htdocs_prefix}js/*.js"]

	unless gf.hasSection 'concat'
		gf.addSection 'concat',
			main:
				src: [
					"#{@htdocs_prefix}js/utils.js"
					"tamia/blocks/*/*.js"
					"tamia/tamia/tamia.js"
				]
				dest: "#{@htdocs_prefix}build/scripts.js"

		gf.addWatcher 'concat',
			files: '<%= concat.main.src %>'
			tasks: 'concat'

	unless gf.hasSection 'uglify'
		gf.addSection 'uglify',
			main:
				options:
					banner: '<%= banner %>'
					compress:
						global_defs:
							DEBUG: gf.JS 'debug'
				files:
					'<%= concat.main.dest %>': '<%= concat.main.dest %>'

	gf.addTask 'default', ['jshint', 'concat', 'uglify']
	gf.addTask 'deploy', ['concat', 'uglify']

	gf.save()

Generator::files = ->
	@copyIfNot '.jshintrc'

Generator::dependencies = ->
	#@installFromNpm ['grunt', 'matchdep', 'grunt-contrib-jshint', 'grunt-contrib-concat', 'grunt-contrib-uglify', 'grunt-contrib-watch']
