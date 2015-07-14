# Scaffolds basic WordPress theme.

'use strict'

path = require 'path'
_ = require 'lodash'
base = require '../base'

module.exports = class Generator extends base

Generator::init = ->
	@stopIfExists 'functions.php'  # Theme already exists

	if @exists 'wp-config.php'
		@themeDir = "wp-content/themes/#{@project}"
	else
		@themeDir = @project

Generator::askFor = ->
	done = @async()
	prompts = [
		{
			name: 'copyright'
			message: 'Copyright',
			default: @authorName
		},
		{
			name: 'designer'
			message: 'Theme designer',
			default: @authorName
		},
	]

	@prompt prompts, (props) =>
		_.extend this, props
		done()

Generator::theme = ->
	@template 'wptheme/**/*.php', @themeDir
	@template 'wptheme/css/*.css', path.join(@themeDir, 'css')
	@template 'wptheme/readme.txt', path.join(@themeDir, 'readme.txt')
	@template 'wptheme/css/theme-head.css', path.join(@themeDir, 'style.css')
	@copy 'wptheme/screenshot.png', path.join(@themeDir, 'screenshot.png')

Generator::configs = ->
	@templateIfNot 'humans.txt', path.join(@themeDir, 'humans.txt')
	@templateIfNot '.editorconfig', path.join(@themeDir, '.editorconfig')
