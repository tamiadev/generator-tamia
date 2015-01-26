# Creates humans.txt file.

'use strict'

base = require '../base'

module.exports = class Generator extends base

Generator::humans = ->
	@templateIfNot 'humans.txt'

Generator::open = ->
	@openInEditor 'humans.txt'
