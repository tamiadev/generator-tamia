# Creates new Stylus block. Also updates stylus/index.styl.
# USAGE: $ yo tamia:block block-name

'use strict'

fs = require 'fs'
base = require '../base'

module.exports = class Generator extends base

Generator::askFor = ->
	return  if @name

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
	@templateAndOpen 'block.styl', filepath
