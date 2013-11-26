# Installs block.
# Also updates Gruntfile and index stylesheet.

'use strict'

fs = require 'fs'
base = require '../base'
Gruntfile = require '../lib/gruntfile'

module.exports = class Generator extends base

Generator::showList = ->
	blocks = @grunt.file.expand {cwd: 'tamia/blocks', filter: 'isDirectory'}, '*'
	blocks = @_.map blocks, (name) =>
		readme = @readFileAsString "tamia/blocks/#{name}/Readme.md"
		m = readme.match /^#.*?\n+([^\n]+?)\n/
		[name, m && m[1] || '']

	@blocks = @_.pluck blocks, 0

	@echo ''
	@grunt.log.subhead 'Available blocks:'
	@printList blocks
	@echo ''

Generator::askFor = ->
	done = @async()
	prompts = [
		name: 'name'
		message: 'Install block:'
	]

	@prompt prompts, (props) =>
		@block = props.name

		if @block not in @blocks
			@error "Block `#{@block}` not found."
			process.exit()

		done()

Generator::init = ->
	@blockBase = "tamia/blocks/#{@block}"

Generator::gruntfile = ->
	return  unless (fs.existsSync "#{@blockBase}/script.js")

	filename = 'Gruntfile.coffee'
	return  unless (fs.existsSync filename)

	gf = @readFileAsString filename
	importStr = "'tamia/blocks/#{@block}/script.js'"
	return  unless (gf.indexOf importStr) is -1

	gf = gf.replace /(\n\t*)('tamia\/tamia\/component.js',?)/, '$1$2$1' + importStr
	@writeFile filename, gf

	@echo "File `#{filename}` updated."

Generator::styles = ->
	return  unless (fs.existsSync "#{@blockBase}/index.styl")

	filename = 'styles/index.styl'
	return  unless (fs.existsSync filename)

	stylus = @grunt.file.read filename
	importStr = "@import \"blocks/#{@block}\";"
	return  unless (stylus.indexOf importStr) is -1

	stylus = stylus.replace /(@import ['"]tamia['"];?)/, '$1\n' + importStr
	@writeFile filename, stylus

	@echo "File `#{filename}` updated."
