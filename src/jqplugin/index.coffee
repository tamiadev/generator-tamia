# Creates new jQuery plugin.

'use strict'

base = require '../base'

module.exports = class Generator extends base

Generator::askFor = ->
	done = @async()
	prompts = [
		name: 'name'
		message: 'Plugin name'
	]

	@prompt prompts, (props) =>
		@name = @_.capitalize props.name
		@filename = (props.name.replace /[^a-z]/ig, '').toLowerCase()
		@cls = @_.classify props.name
		@method = (@cls.charAt 0).toLowerCase() + @cls.slice(1)
		done()

Generator::files = ->
	filepath = "jquery.#{@filename}.js"
	@stopIfExists filepath
	@template 'jqplugin.js', filepath
