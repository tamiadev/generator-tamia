# Installs latest version of WordPress.

'use strict'

path = require 'path'
crypto = require 'crypto'
ncp = require 'ncp'
rimraf = require 'rimraf'
base = require '../base'

module.exports = class Generator extends base

distUrl = 'http://wordpress.org/latest.zip'
# distUrl = 'http://localhost:8000/wordpress-4.1.1.zip'
pluginBaseUrl = 'https://downloads.wordpress.org/plugin/'
ignorePaths = [
	'wp-config.php'
	'wp-config-sample.php'
	'readme.html'
	'license.txt'
	'wp-content/plugins/hello.php'
	'wp-content/themes/'
]

Generator::_randomTokens = (number) ->
	tokens = []
	for i in [1..number]
		tokens.push @_randomString 64
	return tokens

Generator::_randomString = (length) ->
	alphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz!@#$%^&*()_+?<>{}~[]/.,'
	string = ''
	for i in [1..length]
		letterIdx = Math.floor(Math.random() * alphabet.length)
		string += alphabet[letterIdx]
	return string

Generator::_installWordpressPlugin = (name) ->
	done = @async()
	pluginUrl = "#{pluginBaseUrl}#{name}.zip"
	@extract pluginUrl, @destinationPath('wp-content/plugins'), =>
		@ok "WordPress plugin `#{name}` installed"
		done()

Generator::askFor = ->
	done = @async()
	prompts = [
		{
			name: 'lang'
			message: 'Language'
			default: 'en'
		}
	]

	@prompt prompts, (props) =>
		@_.extend this, props
		done()

Generator::wordpress = ->
	@stopIfExists 'wp-config.php'
	@stopIfExists 'functions.php'

	filter = (filepath) ->
		return not ignorePaths.some (mask) ->
			filepath.indexOf(path.join(prefix, mask)) is 0

	done = @async()
	prefix = path.join(process.cwd(), 'wordpress')
	@extract distUrl, @destinationPath(''), =>
		# Move files outside wordpress directory and clean up
		# We do NOT use @fs here
		ncp 'wordpress', '.', {filter: filter}, =>
			rimraf 'wordpress', =>
				@ok "WordPress installed"
				done()

Generator::config = ->
	@mysqlDatabase = 'wp_' + @project
	@mysqlUsername = 'root'
	@mysqlPassword = 'root'
	@keys = @_randomTokens 8
	@template 'wordpress/wp-config.php', 'wp-config.php'

Generator::robotsTxt = ->
	@template 'wordpress/robots.txt', 'robots.txt'

Generator::git = ->
	@gitIgnore '/uploads'
	@gitIgnore '/index.php'
	@gitIgnore '/xmlrpc.php'
	@gitIgnore '/wp-*.php'
	@gitIgnore '/wp-admin'
	@gitIgnore '/wp-includes'

Generator::plugins = ->
	@_installWordpressPlugin 'wp-migrate-db'
