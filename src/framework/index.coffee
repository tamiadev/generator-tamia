# Installs/updates latest version of the Tâmia Stylus framework.
# Also installs jQuery.
# https://github.com/tamiadev/tamia

'use strict'

base = require '../base'

module.exports = class Generator extends base

Generator::checkUpdate = ->
	@update = @exists 'tamia'

Generator::tamia = ->
	done = @async()
	tempPath = @templatePath('tamia')
	distUrl = 'https://github.com/tamiadev/tamia/archive/master.tar.gz'
	@delete tempPath, {force: true}  if @exists tempPath
	@tarball distUrl, tempPath, =>
		@delete 'tamia'  if @exists 'tamia'
		@directory 'tamia/tamia-master/tamia', 'tamia/tamia'
		@directory 'tamia/tamia-master/modules', 'tamia/modules'
		@directory 'tamia/tamia-master/vendor', 'tamia/vendor'
		done()

Generator::dependencies = ->
	@installFromBower ['jquery'], @update
