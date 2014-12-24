# Scaffolds `styles` direcotory with base Stylus styles.
# Also creates Gruntfile.

'use strict'

base = require '../base'

module.exports = class Generator extends base

Generator::styles = ->
	@template 'styles/index.styl'
	@template 'styles/styles.styl'

Generator::dependencies = ->
	@initGrunt()
	@installFromNpm ['grunt-contrib-stylus', 'stylobuild']
