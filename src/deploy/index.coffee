# Configures deploy using shipit.

'use strict'

base = require '../base'

module.exports = class Generator extends base

Generator::askFor = ->
	done = @async()
	prompts = [
		name: 'folder'
		message: 'Remote folder name'
	]

	@prompt prompts, (props) =>
		@folder = props.folder
		done()

Generator::files = ->
	@templateIfNot '.shipit'
