# Adds imagemin and svgmin tasks to Gruntfile.

'use strict'

base = require '../base'
Gruntfile = require '../lib/gruntfile'

module.exports = class Generator extends base

Generator::askFor = ->
	done = @async()
	prompts = [
		name: 'svg'
		type: 'confirm'
		message: 'Would you like to optimize SVG files?'
		default: 'y/N'
	]

	@prompt prompts, (props) =>
		@svg = @unlessNo props.svg
		done()

Generator::dirs = ->
	@grunt.file.mkdir 'images_src'

Generator::gruntfile = ->
	gf = new Gruntfile()

	# imagemin
	unless gf.hasSection 'imagemin'
		gf.addSection 'imagemin',
			options:
				pngquant: true
			main:
				files: [
					expand: true
					cwd: 'images_src/'
					src: '**/*.{png,jpg,gif}'
					dest: 'images/'
				]
		gf.addTask 'default', ['imagemin']

	# svgmin
	unless not @svg or gf.hasSection 'svgmin'
		gf.addSection 'svgmin',
			options:
				pngquant: true
			main:
				files: [
					expand: true
					cwd: 'images_src/'
					src: '**/*.svg'
					dest: 'images/'
				]
		gf.addTask 'default', ['svgmin']

	gf.save()

Generator::dependencies = ->
	modules = ['grunt', 'load-grunt-tasks', 'grunt-contrib-imagemin']
	modules.push 'grunt-svgmin'  if @svg
	@installFromNpm modules
