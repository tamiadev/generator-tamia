// gruntjs.com
module.exports = function(grunt) {
	'use strict';

	require('tamia-grunt')(grunt, {
		tamia: {
			author: '<%= authorName %>, <%= authorUrl %>'
		},
		// All other Grunt plugins
	});

	grunt.registerTask('default', ['styles', 'images']);
};
