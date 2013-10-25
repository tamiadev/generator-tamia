# Scaffolds `js` direcotory with base main.js file.
# Also adds JSHint, Uglify and creates/updates Gruntfile.

'use strict'

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
			files: [
				"#{@htdocs_prefix}js/components/*.js",
				"#{@htdocs_prefix}js/*.js"
			]

	unless gf.hasSection 'bower'
		gf.addSection 'bower',
			main:
				dest: "#{@htdocs_prefix}build/_bower.js"
				exclude: 'jquery'

	unless gf.hasSection 'traceur_build'
		gf.addSection 'traceur_build',
			options:
				blockBinding: true
				freeVariableChecker: false
			main:
				src: [
					'<%= bower.main.dest %>'
					"#{@htdocs_prefix}tamia/tamia/traceur-rt-light.js"
					"#{@htdocs_prefix}tamia/tamia/tamia.js"
					"#{@htdocs_prefix}tamia/tamia/component.js"
					"#{@htdocs_prefix}tamia/blocks/*/*.js"
					"#{@htdocs_prefix}js/components/*.js"
					"#{@htdocs_prefix}js/main.js"
				]
				dest: "#{@htdocs_prefix}build/script.js"

		gf.addWatcher 'traceur_build',
			files: '<%= traceur_build.main.src %>'
			tasks: 'traceur_build'

	unless gf.hasSection 'uglify'
		gf.addSection 'uglify',
			main:
				options:
					banner: '<%= banner %>'
					compress:
						global_defs:
							DEBUG: gf.JS 'debug'
				files:
					'<%= traceur_build.main.dest %>': '<%= traceur_build.main.dest %>'

	gf.addTask 'default', ['jshint', 'traceur_build', 'uglify']
	gf.addTask 'deploy', ['traceur_build', 'uglify']

	gf.save()

Generator::files = ->
	@template 'main.js', 'js/main.js'
	@copyIfNot '.jshintrc'

Generator::dependencies = ->
	@installFromNpm ['grunt', 'matchdep', 'grunt-contrib-jshint', 'grunt-traceur-build', 'grunt-contrib-uglify', 'grunt-contrib-watch', 'grunt-bower-concat']
