# Scaffolds `styles` direcotory with base Stylus styles.
# Also creates Gruntfile.

'use strict'

base = require '../base'

module.exports = class Generator extends base

Generator::styles = ->
	@template 'styles/index.styl'
	@template 'styles/styles.styl'

Generator::gruntfile = ->
	gf = @initGruntfile()

	gf.registerTask 'default', ['styles']

	@saveGruntfile gf

Generator::dependencies = ->
	@installFromNpm [
		'grunt'
		'tamia-grunt'
		'grunt-contrib-watch'
		'grunt-contrib-stylus'
		'grunt-modernizr'
		'stylobuild'
	]
