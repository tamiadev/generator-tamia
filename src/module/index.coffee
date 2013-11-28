# Installs Tâmia module.
# Also updates Gruntfile and index stylesheet.

'use strict'

fs = require 'fs'
base = require '../base'
Gruntfile = require '../lib/gruntfile'

module.exports = class Generator extends base

Generator::showList = ->
	modules = @grunt.file.expand {cwd: 'tamia/modules', filter: 'isDirectory'}, '*'
	modules = @_.map modules, (name) =>
		readme = @readFileAsString "tamia/modules/#{name}/Readme.md"
		m = readme.match /^#.*?\n+([^\n]+?)\n/
		[name, m && m[1] || '']

	@modules = @_.pluck modules, 0

	@echo ''
	@grunt.log.subhead 'Available modules:'
	@printList modules
	@echo ''

Generator::askFor = ->
	done = @async()
	prompts = [
		name: 'name'
		message: 'Install module:'
	]

	@prompt prompts, (props) =>
		@module = props.name

		if @module not in @modules
			@stop "Module `#{@block}` not found."

		done()

Generator::init = ->
	@moduleBase = "tamia/modules/#{@module}"

Generator::gruntfile = ->
	return  unless (fs.existsSync "#{@moduleBase}/script.js")

	filename = 'Gruntfile.coffee'
	return  unless (fs.existsSync filename)

	gf = @readFileAsString filename
	importStr = "'tamia/modules/#{@module}/script.js'"
	return  unless (gf.indexOf importStr) is -1

	gf = gf.replace /(\n\t*)('tamia\/tamia\/component.js',?)/, '$1$2$1' + importStr
	@writeFile filename, gf

	@echo "File `#{filename}` updated."

Generator::styles = ->
	return  unless (fs.existsSync "#{@moduleBase}/index.styl")

	filename = 'styles/index.styl'
	return  unless (fs.existsSync filename)

	stylus = @grunt.file.read filename
	importStr = "@import \"modules/#{@module}\";"
	return  unless (stylus.indexOf importStr) is -1

	stylus = stylus.replace /(@import ['"]tamia['"];?)/, '$1\n' + importStr
	@writeFile filename, stylus

	@echo "File `#{filename}` updated."
