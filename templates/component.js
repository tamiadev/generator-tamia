/* Author: <%= authorName %>, <%= authorUrl %>, <%= (new Date).getFullYear() %> */

;(function($) {
	'use strict';

	var <%= cls %> = tamia.extend(tamia.Component, {
		init: function() {
			®
		}
	});

	tamia.initComponents({'<%= name %>': <%= cls %>});

}(jQuery));
