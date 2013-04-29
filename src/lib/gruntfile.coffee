'use strict'

fs = require 'fs'
path = require 'path'
_ = require 'lodash'

module.exports = class Gruntfile
	constructor: (@filename='Gruntfile.coffee') ->
		@sections = []
		@tasks = {}
		if fs.existsSync @filename
			@gf = fs.readFileSync @filename, encoding: 'utf8'
			@parse()
		else
			@gf = _template

Gruntfile::parse = ->
	# Sections
	section_re = /^\t\t(\w+):$/mg
	@sections = (m[1] while m = section_re.exec @gf)

	# Tasks
	task_re = /'(\w+)'/g
	@gf.replace /grunt.registerTask '(\w+)', \[([^\]]*)\]/g, (s, name, tasks) =>
		tasks = (m[1] while m = task_re.exec tasks)
		@tasks[name] = tasks

Gruntfile::save = ->
	fs.writeFileSync @filename, @gf, encoding: 'utf8'

Gruntfile::addSection = (name, config) ->
	return  if name in @sections
	section = {}
	section[name] = config
	section = @toCoffee section
	@gf = @gf.replace /^\tgrunt.initConfig$/m, "\tgrunt.initConfig\n#{section}"

Gruntfile::addWatcher = (name, config) ->
	subsection = {}
	subsection[name] = config
	if 'watch' in @sections
		subsection = @toCoffee subsection, 3
		@gf = @gf.replace /^\t\twatch:$/m, "\twatch:\n#{subsection}"
	else
		@addSection 'watch', subsection

Gruntfile::addTask = (group, task) ->
	if @tasks[group]
		@gf = @gf.replace /(grunt.registerTask '', \[[^\]]*)(\])/g, "$1, '#{task}'$2"
	else
		@gf += "\tgrunt.registerTask '#{group}', ['#{task}']\n"

Gruntfile::toCoffee = (js, level=2) ->
	cs = _jsToCoffeString js, 2
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
	array = _.isArray js
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
				console.log "jsToString: unknown type: #{type}"
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

	require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks)

	debug = !!grunt.option('debug')

	grunt.initConfig

"""
