# Creates new HTML file.
#
# Options:
#   --no-js: Do not create links to jQuery and scripts file.
#   --oldie: Include jQuery 1.x for IE8.

'use strict'

_ = require 'lodash'
base = require '../base'

module.exports = class Generator extends base

Generator::options = ->
	@js = @options.js ? true
	@oldie = @options.oldie ? false

Generator::askFor = ->
	done = @async()
	prompts = [
		{
			name: 'name'
			message: 'File name'
			default: 'index'
		},
		{
			name: 'lang'
			message: 'Language'
			default: 'en'
		}
	]

	@prompt prompts, (props) =>
		_.extend this, props
		done()

Generator::files = ->
	done = @async()

	filepath = "#{@name}.html"
	@stopIfExists filepath

	write = =>
		if @js and bowerJson
			bower = @fs.readJSON bowerJson
			jqueryVer = bower.version
			if @lang is 'ru'
				@jqueryPath = "http://yandex.st/jquery/#{jqueryVer}/jquery.min.js"
			else
				@jqueryPath = "http://ajax.googleapis.com/ajax/libs/jquery/#{jqueryVer}/jquery.min.js"
			@delete bowerJsonDir  if bowerJsonDir

		@templateAndOpen 'html.html', filepath
		done()

	if @js
		bowerJson = 'bower_components/jquery/bower.json'
		if @exists bowerJson
			write()
		else
			bowerJsonDir = '__bwr'
			bowerJson = "#{bowerJsonDir}/bower.json"
			remoteBowerJson = 'https://raw.github.com/components/jquery/master/bower.json'
			@fetch remoteBowerJson, bowerJsonDir, (err) =>
				@stop "Cannot download #{remoteBowerJson}"  if err
				write()
	else
		write()
