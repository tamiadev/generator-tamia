# Creates new HTML file.

'use strict'

base = require '../base'
fs = require 'fs'

module.exports = class Generator extends base

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

	@prompt prompts, (err, props) =>
		return (@emit 'error', err)  if err

		@_.extend this, props

		done()

Generator::files = ->
	done = @async()

	filepath = "#{@name}.html"
	@stopIfExists filepath

	write = () =>
		if bowerJson
			bower = @readJsonFile bowerJson
			jqueryVer = bower.version
			if @lang is 'ru'
				@jqueryPath = "http://yandex.st/jquery/#{jqueryVer}/jquery.min.js"
			else
				@jqueryPath = "http://ajax.googleapis.com/ajax/libs/jquery/#{jqueryVer}/jquery.min.js"

		console.log()
		@template 'html.html', filepath
		fs.unlinkSync bowerJson  unless @localJquery
		done()

	bowerJson = 'bower_components/jquery/bower.json'
	if fs.existsSync bowerJson
		@localJquery = true
		write()
	else
		@localJquery = false
		bowerJson = '__bwr.json'
		remoteBowerJson = 'https://raw.github.com/components/jquery/master/bower.json'
		@fetch remoteBowerJson, bowerJson, (err) =>
			@stop "Cannot download #{remoteBowerJson}"  if err
			write()
