# Installs Tâmia module.
# Also updates Gruntfile and index stylesheet.

'use strict'

base = require '../base'

module.exports = class Generator extends base

Generator::showList = ->
	modules = @grunt.file.expand {cwd: 'tamia/modules', filter: 'isDirectory'}, '*'
	modules = @_.map modules, (name) =>
		readme = @read "tamia/modules/#{name}/Readme.md"
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
	return  unless (@exists "#{@moduleBase}/script.js")

	filename = 'Gruntfile.js'
	return  unless (@exists filename)

	gf = @read filename
	importStr = "'tamia/modules/#{@module}/script.js'"
	return  unless (gf.indexOf importStr) is -1

	gf = gf.replace /(\n\t*)('tamia\/tamia\/component.js',?)/, '$1$2$1' + importStr
	@write filename, gf

	@log.update filename

Generator::styles = ->
	return  unless (@exists "#{@moduleBase}/index.styl")

	filename = 'styles/index.styl'
	return  unless (@exists filename)

	stylus = @read filename
	importStr = "@import \"modules/#{@module}\";"
	return  unless (stylus.indexOf importStr) is -1

	stylus = stylus.replace /(@import ['"]tamia['"];?)/, '$1\n' + importStr
	@write filename, stylus

	@log.update filename
