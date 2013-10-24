# Adds Modernizr to project.
# Also updates Gruntfile.

'use strict'

base = require '../base'
Gruntfile = require '../lib/gruntfile'

module.exports = class Generator extends base

Generator::gruntfile = ->
	gf = new Gruntfile()

	unless gf.hasSection 'modernizr'
		gf.addSection 'modernizr',
			devFile: 'bower_components/modernizr/modernizr.js'
			outputFile: 'build/modernizr.js'
			extra:
				load: false
			files: [
				'build/scripts.js',
				'build/styles.css'
			]

	gf.addTask 'default', ['modernizr']
	gf.addTask 'deploy', ['modernizr']

	gf.save()

Generator::dependencies = ->
	@installFromNpm ['grunt', 'matchdep', 'grunt-modernizr']
	@installFromBower ['modernizr']
