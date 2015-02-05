# Creates dotfiles: .jshintrc, coffeelint.json, .jscs.json, .travis.yml.

'use strict'

base = require '../base'

module.exports = class Generator extends base

Generator::askFor = ->
	done = @async()

	files = [
		{
			name: '.jshintrc'
		},
		{
			name: 'coffeelint.json'
		},
		{
			name: '.jscs.json'
		},
		{
			name: '.travis.yml'
		},
		{
			name: '.editorconfig'
		}
	]
	newFiles = []

	# Do not ask about already created files
	for file in files
		unless @exists file.name
			newFiles.push file

	@stop 'All dotfiles are already created in this project.'  unless newFiles.length

	prompts = [
		{
			type: 'checkbox'
			name: 'files'
			message: 'Which files do you want to create:'
			choices: newFiles
		}
	]

	@prompt prompts, (props) =>
		@files = props.files
		done()

Generator::copy = ->
	for file in @files
		@templateIfNot file

	# Add Travis CI badge to Readme
	if '.travis.yml' in @files
		readme = @read 'Readme.md'
		travis = @process 'Readme_travis.md'
		lines = readme.split '\n'
		lines[0] = @_.trim "#{lines[0]} #{travis}"
		readme = lines.join '\n'
		@write 'Readme.md', readme
		@log.update 'Readme.md'
