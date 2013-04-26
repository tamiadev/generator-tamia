'use strict'

util = require 'util'
path = require 'path'
yeoman = require 'yeoman-generator'

Generator = module.exports = ->
	yeoman.generators.Base.apply this, arguments

util.inherits Generator, yeoman.generators.Base
Generator.name = 'Tâmia project generator'

Generator::tamia = ->
	console.log 'tamia'
	done = @async()
	distUrl = 'https://github.com/sapegin/tamia/archive/master.tar.gz'
	@tarball distUrl, (path.join @sourceRoot(), 'tamia'), =>
		@directory 'tamia/tamia', 'tamia/tamia'
		@directory 'tamia/blocks', 'tamia/blocks'
		done()
