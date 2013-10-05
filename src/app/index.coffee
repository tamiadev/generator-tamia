'use strict'

util = require 'util'
path = require 'path'
base = require '../base'

module.exports = class Generator extends base
	constructor: (args, options) ->
		super(args, options)

Generator::askFor = ->
	done = @async()
	prompts = [
		{
			name: 'styles'
			type: 'confirm'
			message: 'Would you like to use Stylus?'
			default: 'Y/n'
			warning: 'Yes: Tâmia and base Stylus files will be placed into the tamia and styles directories.'
		}
	]

	@prompt prompts, (err, props) =>
		return (@emit 'error', err)  if err

		@styles = @ifYes props.styles

		done()


Generator::all = ->
	args = @args
	(@hookFor 'tamia:styles', args)  if @styles

