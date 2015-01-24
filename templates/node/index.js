/**
 * <%= description %>.
 *
 * @author <%= authorName %> (<%= authorUrl %>)
 */

'use strict';

var <%= cls %> = require('./lib/<%= name %>');

module.exports = function() {
	return (new <%= cls %>());
};
