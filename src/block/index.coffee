# Installs block.
# Also updates Gruntfile and index stylesheet.

'use strict'

fs = require 'fs'
grunt = require 'grunt'
base = require '../base'
Gruntfile = require '../lib/gruntfile'

module.exports = class Generator extends base

Generator::showList = ->
	blocks = grunt.file.expand {cwd: 'tamia/blocks', filter: 'isDirectory'}, '*'
	blocks = @_.map blocks, (name) ->
		readme = grunt.file.read "tamia/blocks/#{name}/Readme.md"
		m = readme.match /^#.*?\n+([^\n]+?)\n/
		[name, m && m[1] || '']

	@blocks = @_.pluck blocks, 0

	console.log ''
	grunt.log.subhead 'Available blocks:'
	@printList blocks
	console.log ''

Generator::askFor = ->
	done = @async()
	prompts = [
		name: 'name'
		message: 'Install block'
	]

	@prompt prompts, (err, props) =>
		return (@emit 'error', err)  if err

		@block = props.name

		if @block not in @blocks
			grunt.log.error "Block \"#{@block}\" not found."
			process.exit()

		done()

Generator::init = ->
	@blockBase = "tamia/blocks/#{@block}"

Generator::gruntfile = ->
	return  unless (fs.existsSync "#{@blockBase}/script.js")

	filename = 'Gruntfile.coffee'
	return  unless (fs.existsSync filename)

	gf = grunt.file.read filename
	importStr = "'tamia/blocks/#{@block}/script.js'"
	return  unless (gf.indexOf importStr) is -1

	gf = gf.replace /(\n\t*)('tamia\/tamia\/tamia.js',?)/, '$1$2$1' + importStr
	grunt.file.write filename, gf

	console.log "File \"#{filename}\" updated."

Generator::styles = ->
	return  unless (fs.existsSync "#{@blockBase}/index.styl")

	filename = 'styles/index.styl'
	return  unless (fs.existsSync filename)

	stylus = grunt.file.read filename
	importStr = "@import \"blocks/#{@block}\";"
	return  unless (stylus.indexOf importStr) is -1

	stylus = stylus.replace /(@import ['"]tamia['"];?)/, '$1\n' + importStr
	grunt.file.write filename, stylus

	console.log "File \"#{filename}\" updated."
