# Creates Readme, License and Changelog files.

'use strict'

base = require '../base'
fs = require 'fs'

module.exports = class Generator extends base

filepath_readme = 'Readme.md'

Generator::askFor = ->
	done = @async()

	@license = false
	@changelog = false
	@contributing = false
	@travis = false

	prompts = []
	unless fs.existsSync 'License.md'
		prompts.push {
			type: 'confirm'
			name: 'license'
			message: 'Do you need license?'
			default: true
		}
	unless fs.existsSync 'Changelog.md'
		prompts.push {
			type: 'confirm'
			name: 'changelog'
			message: 'Do you need changelog?'
			default: true
		}
	unless fs.existsSync 'Contributing.md'
		prompts.push {
			type: 'confirm'
			name: 'contributing'
			message: 'Do you need dontributing guidelines?'
			default: false
		}

	@prompt prompts, (props) =>
		@_.extend this, props
		done()

Generator::readme = ->
	@license = @process 'Readme_license.md'  if @license
	@changelog = @process 'Readme_changelog.md'  if @changelog
	@travis = @process 'Readme_travis.md'  if fs.existsSync '.travis.yml'

	unless fs.existsSync filepath_readme
		readme = @process filepath_readme

		if @travis
			lines = readme.split '\n'
			lines[0] = @_.trim "#{lines[0]} #{@travis}"
			readme = lines.join '\n'

		@log.create filepath_readme
	else
		readme = @readFileAsString filepath_readme

		if @license
			readme += @license

		if @changelog
			if /## License/.test readme
				readme = readme.replace /\-\-\-\n\n## License/, "#{@changelog}\n---\n\n## License"
			else
				readme += @changelog

		@log.update filepath_readme

	@writeFile filepath_readme, (@_.trim readme)

Generator::rest = ->
	@templateIfNot 'License.md'  if @license
	@templateIfNot 'Changelog.md'  if @changelog
	@templateIfNot 'Contributing.md'  if @contributing

Generator::open = ->
	@openInEditor filepath_readme
