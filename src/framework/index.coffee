# Installs/updates latest version of the Tâmia Stylus framework.
# Also installs jQuery.
# https://github.com/sapegin/tamia

'use strict'

util = require 'util'
path = require 'path'
base = require '../base'

module.exports = class Generator extends base

Generator::tamia = ->
	done = @async()
	distUrl = 'https://github.com/sapegin/tamia/archive/master.tar.gz'
	@tarball distUrl, (path.join @sourceRoot(), 'tamia'), =>
		@directory 'tamia/tamia', 'tamia/tamia'
		@directory 'tamia/blocks', 'tamia/blocks'
		done()

Generator::dependencies = ->
	@installFromBower ['jquery']
