# Creates humans.txt file.

'use strict'

base = require '../base'
fs = require 'fs'

module.exports = class Generator extends base

Generator::humans = ->
	@templateIfNot 'humans.txt'

Generator::open = ->
	@openInEditor 'humans.txt'
