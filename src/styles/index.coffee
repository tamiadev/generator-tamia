# Scaffolds `styles` direcotory with base Stylus styles.
# Also creates Gruntfile.

'use strict'

base = require '../base'
Gruntfile = require '../gruntfile'

module.exports = class Generator extends base

Generator::styles = ->
	@template 'styles/index.styl'
	@template 'styles/styles.styl'

Generator::gruntfile = ->
	new Gruntfile()

Generator::dependencies = ->
	@installFromNpm ['grunt', 'tamia-grunt', 'grunt-contrib-watch', 'grunt-contrib-stylus', 'stylobuild']
