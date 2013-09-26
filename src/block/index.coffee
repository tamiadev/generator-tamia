# Installs block.
# Also adds it to index stylesheet.

'use strict'


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

Generator::styles = ->
	filename = 'styles/index.styl'
	stylus = grunt.file.read filename
	return  unless stylus

	importStr = "@import \"blocks/#{@block}\";"
	return  unless stylus.indexOf importStr is -1

	stylus = stylus.replace /(@import ['"]tamia['"];?)/, '$1\n' + importStr
	grunt.file.write filename, stylus

	console.log 'File "styles/index.styl" updated.'
