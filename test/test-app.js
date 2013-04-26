/*global describe, beforeEach, it*/

var path = require('path');
var helpers = require('yeoman-generator').test;
var assert = require('assert');


describe('Tamia generator test', function () {
	this.timeout(10000);

	it('the generator can be required without throwing', function () {
		// Not testing the actual run of generators yet
		this.app = require('../app');
	});
});
