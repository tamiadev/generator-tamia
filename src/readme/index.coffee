# Creates Readme, License and Changelog files.

'use strict'

base = require '../base'

module.exports = class Generator extends base

filepath_readme = 'Readme.md'

Generator::askFor = ->
	done = @async()

	@author = true
	@license = false
	@changelog = false
	@contributing = false
	@travis = false

	prompts = []
	unless @exists 'License.md'
		prompts.push {
			type: 'confirm'
			name: 'license'
			message: 'Do you need license?'
			default: true
		}
	unless @exists 'Changelog.md'
		prompts.push {
			type: 'confirm'
			name: 'changelog'
			message: 'Do you need changelog?'
			default: true
		}
	unless @exists 'Contributing.md'
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
	@author = @process 'Readme_author.md'  if @author
	@license = @process 'Readme_license.md'  if @license
	@changelog = @process 'Readme_changelog.md'  if @changelog
	@contributing = @process 'Readme_contributing.md'  if @contributing
	@travis = @process 'Readme_travis.md'  if @exists '.travis.yml'

	unless @exists filepath_readme
		readme = @process filepath_readme

		if @travis
			lines = readme.split '\n'
			lines[0] = @_.trim "#{lines[0]}\n\n#{@travis}\n"
			readme = lines.join '\n'

		@log.create filepath_readme
	else
		readme = @read filepath_readme

		if @license
			readme += @license

		if @changelog
			if /## License/.test readme
				readme = readme.replace /\-\-\-\n\n## License/, "#{@changelog}\n---\n\n## License"
			else
				readme += @changelog

		@log.update filepath_readme

	@write filepath_readme, (@_.trim readme)

Generator::rest = ->
	@templateIfNot 'License.md'  if @license
	@templateIfNot 'Changelog.md'  if @changelog
	@templateIfNot 'Contributing.md'  if @contributing

Generator::open = ->
	@openInEditor filepath_readme
