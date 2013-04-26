'use strict'

path = require 'path'
util = require 'util'
yeoman = require 'yeoman-generator'

module.exports = class Generator extends yeoman.generators.Base

Generator::ifYes = (prop) ->
	/y/i.test prop
