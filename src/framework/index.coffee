# Installs/updates latest version of the Tâmia Stylus framework.
# Also installs jQuery.
# https://github.com/sapegin/tamia

'use strict'

fs = require 'fs'
util = require 'util'
path = require 'path'
base = require '../base'

module.exports = class Generator extends base

Generator::checkUpdate = ->
	@update = fs.existsSync 'tamia'

Generator::tamia = ->
	done = @async()
	tempPath = path.join @sourceRoot(), 'tamia'
	distUrl = 'https://github.com/sapegin/tamia/archive/master.tar.gz'
	@delete tempPath, {force: true}  if fs.existsSync tempPath
	@tarball distUrl, tempPath, =>
		@delete 'tamia'  if fs.existsSync 'tamia'
		@directory 'tamia/tamia-master/tamia', 'tamia/tamia'
		@directory 'tamia/tamia-master/modules', 'tamia/modules'
		@directory 'tamia/tamia-master/vendor', 'tamia/vendor'
		done()

Generator::dependencies = ->
	@installFromBower ['jquery'], @update
