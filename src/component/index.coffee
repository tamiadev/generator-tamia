# Creates new JS component.

'use strict'

base = require '../base'

module.exports = class Generator extends base

Generator::askFor = ->
	done = @async()
	prompts = [
		name: 'name'
		message: 'Component name'
		default: 'main'
	]

	@prompt prompts, (err, props) =>
		return (@emit 'error', err)  if err

		@name = @_.dasherize props.name

		done()

Generator::files = ->
	# TODO: check existance
	@template 'component.js', "js/components/#{@name}.js"