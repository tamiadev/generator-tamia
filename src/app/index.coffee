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
		name: 'tamia'
		message: 'Would you like to install Tâmia?'
		default: 'Y/n'
		warning: 'Yes: Tâmia files will be placed into the tamia/tamia and tamia/blocks directories.'
	]

	@prompt prompts, (err, props) =>
		return (@emit 'error', err) if err

		@tamia = @ifYes props.tamia

		done()


Generator::all = ->
	args = @args
	(@hookFor 'tamia:framework', args) if @tamia
