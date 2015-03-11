<?php
/**
 * The template for displaying search results pages.
 */

get_header();

if (have_posts()) {

	?><h1 class="post-title">Search: <?php echo get_search_query() ?></h1><?php

	the_post();
	get_template_part('content', get_post_format());
	get_template_part('pagination');

} else {

	get_template_part('content', 'none');

}

get_footer();

?>