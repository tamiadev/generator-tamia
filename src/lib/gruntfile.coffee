'use strict'

fs = require 'fs'
path = require 'path'
util = require 'util'
chalk = require 'chalk'

module.exports = class Gruntfile
	constructor: (@filename='Gruntfile.coffee') ->
		@sections = []
		@tasks = {}
		if fs.existsSync @filename
			@gf = fs.readFileSync @filename, encoding: 'utf8'
			@parse()
		else
			@gf = _template

Gruntfile::writeln = (text) ->
	console.log (chalk.green 'Gruntfile:') + " #{text}"

Gruntfile::parse = ->
	# Sections.
	section_re = /^\t\t(\w+):/mg
	@sections = (m[1] while m = section_re.exec @gf)

	# Tasks
	task_re = /'(\w+)'/g
	@gf.replace /grunt.registerTask '(\w+)', \[([^\]]*)\]/g, (s, name, tasks) =>
		tasks = (m[1] while m = task_re.exec tasks)
		@tasks[name] = tasks

Gruntfile::save = ->
	fs.writeFileSync @filename, @gf, encoding: 'utf8'

Gruntfile::hasSection = (name) ->
	name in @sections

Gruntfile::addSection = (name, config) ->
	return  if @hasSection name
	section = {}
	section[name] = config
	section = @toCoffee section
	@gf = @gf.replace /^\tgrunt.initConfig$/m, "\tgrunt.initConfig\n#{section}"
	@writeln "section '#{name}' added"

Gruntfile::addWatcher = (name, config) ->
	subsection = {}
	config.options = {
		atBegin: true
	}
	subsection[name] = config
	if @hasSection 'watch'
		# TODO: check duplicates
		subsection = @toCoffee subsection, level=3
		@gf = @gf.replace /^\t\twatch:$/m, "\t\twatch:\n\t\t\toptions:\n\t\t\t\tlivereload:true\n#{subsection}"
	else
		@addSection 'watch', subsection
	@writeln "watcher '#{name}' added"

Gruntfile::addTask = (group, tasks) ->
	tasks = [tasks]  if typeof tasks is 'string'
	if @tasks[group]
		m = @gf.match(new RegExp("grunt.registerTask '#{group}', \\\['([^\\\]]*)'"))
		current_tasks = m[1].split "', '"
		for task in tasks
			@gf = @gf.replace new RegExp("(grunt.registerTask '#{group}', \\\[[^\\\]]*)"), "$1, '#{task}'"  unless task in current_tasks
	else
		tasks_str = "'" + (tasks.join "', '") + "'"
		@gf += "\tgrunt.registerTask '#{group}', [#{tasks_str}]\n"
		@writeln "task '#{group}' added"

Gruntfile::addBanner = (data) ->
	@addSection 'banner', "/* Author: #{data.authorName}, #{data.authorUrl}, <%= grunt.template.today(\"yyyy\") %> */\\n"
	@writeln "banner added"

Gruntfile::toCoffee = (js, level=2) ->
	cs = _jsToCoffeString js, level
	cs.replace /\n+$/, ''

Gruntfile::JS = (code) ->
	__JS__: code


###
Returns JS object like JSON but without unnecessary quotes, etc.
CoffeScript syntax.

@param {Object} js
@param {Number} [level] Start level of indentation
@return {String}
###
_jsToCoffeString = (js, level=1, first=true) ->
	array = util.isArray js
	has = false
	hasComma = false
	s = if array then '[\n' else (if first then '' else '\n')
	quote = "'"
	for key of js
		value = js[key]
		type = typeof value
		key = quote + key + quote  unless /^[a-z0-9_]+$/i.test(key)
		s += _stringCopy('\t', level)
		s += key + ': '  unless array
		type = 'js' if value.__JS__ if type is 'object'
		switch type
			when 'number'
				s += value
			when 'boolean'
				s += (if value then 'true' else 'false')
			when 'string'
				value = value.replace(/'/g, "\\'")
				s += quote + value + quote
			when 'array', 'object'
				s += _jsToCoffeString(value, level + 1, false)
			when 'js'
				s += value.__JS__
			else
				console.log chalk.red "jsToString: unknown type: #{type}"
		if type isnt 'array' and type isnt 'object'
			s += '\n'
			hasComma = true
		has = true
	s = s.replace(/,\n$/, '\n')  if hasComma
	return (if array then '[]' else '{}') + (if first then '' else '\n')  unless has
	s += _stringCopy('\t', level - 1) + ']' + (if first then '' else '\n')  if array
	s.replace /\n\t*\n/g, '\n'
	s.replace /\s+\n/g, '\n'

_stringCopy = (s, num) ->
	Array(num+1).join s

_template = """# gruntjs.com

module.exports = (grunt) ->
	'use strict'

	require('load-grunt-tasks')(grunt)

	debug = !!grunt.option('debug')

	grunt.initConfig

"""
