'use strict'

path = require 'path'
fs = require 'fs'
gfc = require 'gruntfile-construct'
types = require 'ast-types'
util = require 'util'
chalk = require 'chalk'

module.exports = TamiaGruntfile = (filename='Gruntfile.js') ->
	# Copy template if file don’t exist
	if not fs.existsSync(filename)
		template = fs.readFileSync(path.join(__dirname, 'templates', filename), encoding: 'utf-8')
		fs.writeFileSync(filename, template)
		@writeln "created"

	gfc.Gruntfile.call(this, filename, autosave: false)

# `class TamiaGruntfile extends gfc.Gruntfile` doesn’t work for some reason
util.inherits(TamiaGruntfile, gfc.Gruntfile)

TamiaGruntfile::detectInitCall = () ->
	initCalls = []
	types.visit(@tree, {
		visitCallExpression: (path) ->
			node = path.node
			if node.callee.name is 'require' and node.arguments[0].value is 'tamia-grunt'
				initCalls.push([node, path])
			@traverse(path)
	})

	throw new Error('Invocation of require("tamia-grunt")() not found')  if not initCalls.length
	throw new Error('Too many invocations of require("tamia-grunt")()')  if initCalls.length > 1

	@_initCall = initCalls[0][0]
	@_initCallPath = initCalls[0][1]

TamiaGruntfile::detectConfig = ->
	callExpression = @parentPath(@_initCallPath, 'CallExpression').node
	throw new Error('require("tamia-grunt")() has no arguments')  if not callExpression.arguments or not callExpression.arguments.length

	configObject = callExpression.arguments[1]
	throw new Error('No config object passed to require("tamia-grunt")()')  if not types.namedTypes.ObjectExpression.check(configObject)

	@_configObject = configObject

TamiaGruntfile::writeln = (text) ->
	console.log (chalk.green 'Gruntfile:') + " #{text}"

TamiaGruntfile::addTask = (task, config) ->
	added = !@tasks[task]
	gfc.Gruntfile::addTask.call(this, task, config)
	@writeln "task '#{task}' added"  if added

TamiaGruntfile::registerTask = (name, tasks) ->
	registered = true
	gfc.Gruntfile::registerTask.call(this, name, tasks)
	@writeln tasks.join(', ') + " added to '#{name}' alias"  if registered
