# Creates new Stylus block. Also updates stylus/index.styl.

'use strict'

fs = require 'fs'
base = require '../base'

module.exports = class Generator extends base

Generator::askFor = ->
	done = @async()
	prompts = [
		name: 'name'
		message: 'Block name:'
	]

	@prompt prompts, (props) =>
		@name = props.name
		done()

Generator::files = ->
	filepath = "styles/blocks/#{@name}.styl"
	@stopIfExists filepath
	@templateAndOpen 'block.styl', filepath

Generator::styles = ->
	filename = 'styles/index.styl'
	return  unless (fs.existsSync filename)

	stylus = @readFileAsString filename
	importStr = "@import \"blocks/#{@name}\";"
	stylus = stylus.replace /(@import ['"]blocks\/[-\w]+['"];?)(\s$)/, '$1\n' + importStr + '$2'
	@writeFile filename, stylus

	@log.update filename
