/* Author: <%= authorName %>, <%= authorUrl %>, <%= (new Date).getFullYear() %> */

/*global tamia:false */
;(function ($) {
	'use strict';

	function init(elem) {
		// var container = $(elem);
	}

	tamia.initComponents({'<%= name %>': init});

}(jQuery));
