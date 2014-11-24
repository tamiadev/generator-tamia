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
			default: true
		},
		{
			name: 'js'
			type: 'confirm'
			message: 'Would you like to use JavaScript?'
			default: true
		}
	]

	@prompt prompts, (props) =>
		@_.extend this, props
		done()

Generator::all = ->
	args = @args
	(@hookFor 'tamia:framework', args)
	(@hookFor 'tamia:styles', args)  if @styles

