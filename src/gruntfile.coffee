'use strict'

path = require 'path'
fs = require 'fs'
gfc = require 'gruntfile-construct'
gfcUtil = require 'gruntfile-construct/util'
types = require 'ast-types'
util = require 'util'
chalk = require 'chalk'

module.exports = TamiaGruntfile = (filename='Gruntfile.js') ->
	gfc.Gruntfile.call(this, filename, autosave: false)

# `class TamiaGruntfile extends gfc.Gruntfile` doesn’t work for some reason
util.inherits(TamiaGruntfile, gfc.Gruntfile)

TamiaGruntfile::detectInitCall = ->
	initCalls = []
	types.visit(@tree, {
		visitCallExpression: (path) ->
			node = path.node
			if node.callee.name is 'require' and node.arguments[0].value is 'tamia-grunt'
				initCalls.push(path)
			@traverse(path)
	})

	throw new Error('Invocation of require("tamia-grunt")() not found')  if not initCalls.length
	throw new Error('Too many invocations of require("tamia-grunt")()')  if initCalls.length > 1

	@_initCallPath = initCalls[0]

TamiaGruntfile::detectConfig = ->
	callExpression = gfcUtil.parentPath(@_initCallPath, 'CallExpression').node
	throw new Error('require("tamia-grunt")() has no arguments')  if not callExpression.arguments or not callExpression.arguments.length

	configObject = callExpression.arguments[1]
	throw new Error('No config object passed to require("tamia-grunt")()')  if not types.namedTypes.ObjectExpression.check(configObject)

	@_configObject = configObject

TamiaGruntfile::writeln = (msg) ->
	msg = msg.replace(/`(.*?)`/g, (m, str) -> chalk.cyan(str))
	console.log (chalk.green 'Gruntfile:') + " #{msg}"

TamiaGruntfile::addTask = (task, config) ->
	added = !@tasks[task]
	gfc.Gruntfile::addTask.call(this, task, config)
	@writeln "task `#{task}` added"  if added

TamiaGruntfile::registerTask = (name, tasks) ->
	registered = true
	gfc.Gruntfile::registerTask.call(this, name, tasks)
	@writeln '`' + tasks.join('`, `') + "` added to `#{name}` alias"  if registered
