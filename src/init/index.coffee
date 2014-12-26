# Creates config for Tâmia generator.

'use strict'

base = require '../base'

module.exports = class Generator extends base

Generator::askConfig = () ->
	done = @async()
	prompts = [
		{
			name: 'authorName'
			message: 'Author name:'
		}
		{
			name: 'authorUrl'
			message: 'Author URL:'
		}
	]

	@prompt prompts, (props) =>
		for name, value of props
			@userConfig.set(name, value)
		@ok "Config saved to #{@userConfig.path}"
		done()
