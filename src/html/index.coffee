# Creates new HTML file.
#
# Options:
#   --no-js: Do not create links to jQuery and scripts file.

'use strict'

base = require '../base'
fs = require 'fs'

module.exports = class Generator extends base

Generator::options = ->
	@js = @options.js ? true

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
		},
	]

	@prompt prompts, (props) =>
		@_.extend this, props
		done()

Generator::files = ->
	done = @async()

	filepath = "#{@name}.html"
	@stopIfExists filepath

	write = =>
		if @js and bowerJson
			bower = @readJsonFile bowerJson
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
		if fs.existsSync bowerJson
			@localJquery = true
			write()
		else
			@localJquery = false
			bowerJsonDir = '__bwr'
			bowerJson = "#{bowerJsonDir}/bower.json"
			remoteBowerJson = 'https://raw.github.com/components/jquery/master/bower.json'
			@fetch remoteBowerJson, bowerJsonDir, (err) =>
				@stop "Cannot download #{remoteBowerJson}"  if err
				write()
	else
		write()
