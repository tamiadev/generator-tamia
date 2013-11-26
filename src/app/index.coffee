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
		},
		{
			name: 'js'
			type: 'confirm'
			message: 'Would you like to use JavaScript?'
			default: 'Y/n'
		}
		{
			name: 'modernizr'
			type: 'confirm'
			message: 'Would you like to use Modernizr?'
			default: 'Y/n'
		}
	]

	@prompt prompts, (props) =>
		@styles = @ifYes props.styles
		@js = @ifYes props.js
		@modernizr = @ifYes props.modernizr
		done()

Generator::all = ->
	args = @args
	(@hookFor 'tamia:framework', args)
	(@hookFor 'tamia:styles', args)  if @styles
	(@hookFor 'tamia:modernizr', args)  if @modernizr

