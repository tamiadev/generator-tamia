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
			main:
				devFile: 'remote'
				outputFile: 'build/modernizr.js'
				extra:
					load: false
				files:
					src: [
						'build/scripts.js',
						'build/styles.css'
					]

	gf.addTask 'default', ['modernizr']
	gf.addTask 'deploy', ['modernizr']

	gf.save()

Generator::dependencies = ->
	@installFromNpm ['grunt', 'load-grunt-tasks', 'grunt-modernizr']
	@installFromBower ['modernizr']
