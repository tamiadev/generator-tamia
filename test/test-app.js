/*global describe, beforeEach, it*/

var path = require('path');
var helpers = require('yeoman-generator').test;
var assert = require('assert');


describe('Tamia generator test', function () {
	this.timeout(10000);

	beforeEach(function (done) {
		helpers.testDirectory(path.join(__dirname, 'temp'), function (err) {
			if (err) {
				return done(err);
			}

			this.tamia = helpers.createGenerator('tamia:app', [
				'../../app', [
					helpers.createDummyGenerator(),
					'mocha:app'
				]
			]);
			done();
		}.bind(this));
	});

	it('the generator can be required without throwing', function () {
		// Not testing the actual run of generators yet
		this.app = require('../app');
	});

	it('creates expected files', function (done) {
		var expected = [
			'tamia/tamia/index.styl',
			'tamia/blocks/media/index.styl'
		];

		this.tamia.run({}, function () {
			helpers.assertFiles(expected);
			done();
		});
	});
});
