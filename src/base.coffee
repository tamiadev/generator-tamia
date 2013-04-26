'use strict'

path = require 'path'
util = require 'util'
_ = require 'lodash'
yeoman = require 'yeoman-generator'

module.exports = class Generator extends yeoman.generators.Base

Generator::ifYes = (prop) ->
	/y/i.test prop

# @hookFor that doesn’t requre to be invoked from constructor.
# Used to be invoked inside @prompt.
Generator::hookFor = (name, config) ->
	config ?= {}

	# Add the corresponding option to this class, so that we output these hooks in help
	@option name,
		desc: @_.humanize(name) + ' to be invoked'
		defaults: @options[name] or ''

	@_hooks.push (_.defaults config, name: name)

	this
