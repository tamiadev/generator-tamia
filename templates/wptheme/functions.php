<?php
/* Author: <%= authorName %>, <%= authorUrl %>, <%= (new Date).getFullYear() %> */

// SquirrelPress
// add_theme_support('sq-gallery-rss');
// add_theme_support('sq-twitter', 'TWITTER');
include 'squirrelpress.php';


function theme_setup() {
	// Featured images
	add_theme_support('post-thumbnails');

	// This theme can use wp_nav_menu() in two locations
	register_nav_menus(array(
		'primary' => 'Primary Menu',
		'social' => 'Social Links Menu',
	));
}

?>
