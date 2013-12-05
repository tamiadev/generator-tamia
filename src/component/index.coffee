# Creates new JS component.
# USAGE: $ yo tamia:component component-name

'use strict'

base = require '../base'

module.exports = class Generator extends base

Generator::askFor = ->
	return  if @name

	done = @async()
	prompts = [
		name: 'name'
		message: 'Component name:'
	]

	@prompt prompts, (props) =>
		@name = props.name
		done()

Generator::prepare = ->
	name = @name
	@name = @_.dasherize name
	@cls = @_.classify name
	@filename = (name.replace /[^a-z]/ig, '').toLowerCase()

Generator::files = ->
	filepath = "js/components/#{@filename}.js"
	@stopIfExists filepath
	@template 'component.js', filepath
	@openInEditor filepath
