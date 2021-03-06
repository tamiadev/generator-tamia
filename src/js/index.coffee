# Scaffolds `js` direcotory with base main.js file.
# Also adds JSHint, Uglify and creates/updates Gruntfile.

'use strict'

base = require '../base'

module.exports = class Generator extends base

Generator::gruntfile = ->
	gf = @initGruntfile()

	gf.addTask('concat', {
		main:
			nonull: true
			src: [
				'<%= bower_concat.main.dest %>'
				"#{@htdocs_prefix}tamia/vendor/*.js"
				"#{@htdocs_prefix}tamia/tamia/tamia.js"
				"#{@htdocs_prefix}tamia/tamia/opor.js"
				"#{@htdocs_prefix}tamia/tamia/component.js"
				"#{@htdocs_prefix}js/components/*.js"
				"#{@htdocs_prefix}js/main.js"
			]
			dest: "#{@htdocs_prefix}build/scripts.js"
	})

	gf.registerTask 'default', ['scripts']

	@saveGruntfile gf

Generator::files = ->
	@template 'main.js', 'js/main.js'
	@copyIfNot '.jshintrc'

Generator::dependencies = ->
	@installFromNpm [
		'grunt'
		'tamia-grunt'
		'grunt-contrib-jshint'
		'grunt-contrib-uglify'
		'grunt-contrib-watch'
		'grunt-contrib-concat'
		'grunt-bower-concat'
		'grunt-modernizr'
	]
