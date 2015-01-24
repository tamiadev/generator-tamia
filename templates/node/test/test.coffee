expect = (require 'chai').expect
<%= cls %> = require '../lib/<%= name %>'
<%= name %> = require '../index'

# DEBUG = false

# log = ->
# 	args = Array.prototype.slice.call(arguments)
# 	args.unshift('<%= cls %>')
# 	console.log.apply(null, args)  if DEBUG


describe 'basic', ->

	it 'exists', (done) ->
		expect(<%= cls %>).to.exists
		expect(<%= name %>).to.exists
		done()
