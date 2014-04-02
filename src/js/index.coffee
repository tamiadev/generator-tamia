# Scaffolds `js` direcotory with base main.js file.
# Also adds JSHint, Uglify and creates/updates Gruntfile.

'use strict'

base = require '../base'
Gruntfile = require '../lib/gruntfile'

module.exports = class Generator extends base

Generator::gruntfile = ->
	gf = new Gruntfile()

	gf.addBanner this

	unless gf.hasSection 'coffeelint'
		gf.addSection 'coffeelint',
			options: configFile: 'coffeelint.json'
			files: '<%= coffee.main.src %>'

	unless gf.hasSection 'bower_concat'
		gf.addSection 'bower_concat',
			main:
				dest: "#{@htdocs_prefix}build/_bower.js"
				exclude: [
					'jquery'
					'modernizr'
				]

	unless gf.hasSection 'coffee'
		gf.addSection 'coffee',
			main:
				expand: true
				src: [
					"#{@htdocs_prefix}js/components/*.coffee"
					"#{@htdocs_prefix}js/*.coffee"
				]
				dest: '.'
				ext: '.js'

		gf.addWatcher 'coffee',
			files: '<%= coffee.main.src %>'
			tasks: 'coffee'

	unless gf.hasSection 'concat'
		gf.addSection 'concat',
			main:
				src: [
					'<%= bower_concat.main.dest %>'
					"#{@htdocs_prefix}tamia/vendor/*.js"
					"#{@htdocs_prefix}tamia/tamia/tamia.js"
					"#{@htdocs_prefix}tamia/tamia/component.js"
					"#{@htdocs_prefix}js/components/*.js"
					"#{@htdocs_prefix}js/main.js"
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

	gf.addTask 'default', ['coffeelint', 'bower_concat', 'coffee', 'concat', 'uglify']
	gf.addTask 'deploy', ['bower_concat', 'coffee', 'concat', 'uglify']

	gf.save()

Generator::files = ->
	@template 'main.coffee', 'js/main.coffee'
	@copyIfNot '.coffeelintrc'

Generator::dependencies = ->
	@installFromNpm ['grunt', 'load-grunt-tasks', 'grunt-coffeelint', 'grunt-contrib-coffee', 'grunt-contrib-uglify',
		'grunt-contrib-watch', 'grunt-contrib-concat', 'grunt-bower-concat']
