'use strict'

util = require 'util'
path = require 'path'
base = require '../base'

module.exports = class Generator extends base
	constructor: (args, options) ->
		super(args, options)

		@hookFor 'tamia:framework', args

		# done = @async()
		# prompts = [
		# 	name: 'tamia'
		# 	message: 'Would you like to install Tâmia?'
		# 	default: 'Y/n'
		# 	warning: 'Yes: Tâmia files will be placed into the tamia/tamia and tamia/blocks directories.'
		# ]

		# @prompt prompts, (err, props) =>
		# 	return (@emit 'error', err) if err

		# 	@tamia = @ifYes props.tamia

		# 	@hookFor 'tamia:framework', args if @tamia

		# 	done()

		#@on 'end', ->
			#@installDependencies skipInstall: @options['skip-install']
