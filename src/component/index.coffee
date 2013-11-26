# Creates new JS component.

'use strict'

base = require '../base'

module.exports = class Generator extends base

Generator::askFor = ->
	done = @async()
	prompts = [
		name: 'name'
		message: 'Component name'
	]

	@prompt prompts, (props) =>
		@name = @_.dasherize props.name
		@cls = @_.classify props.name
		@filename = (props.name.replace /[^a-z]/ig, '').toLowerCase()
		done()

Generator::files = ->
	filepath = "js/components/#{@filename}.js"
	@stopIfExists filepath
	@template 'component.js', filepath
	@openInEditor filepath
