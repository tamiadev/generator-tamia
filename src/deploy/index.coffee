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

	@prompt prompts, (err, props) =>
		return (@emit 'error', err)  if err

		@folder = props.folder

		done()

Generator::files = ->
	@templateIfNot '.shipit'
