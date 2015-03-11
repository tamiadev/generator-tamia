<?php
/**
 * The template for displaying сategory archive pages.
 */

get_header();

if (have_posts()) { ?>

	<h1 class="page-title"><?php single_cat_title() ?></h1>

	<div class="posts">
		<?php

	while (have_posts()) {
		the_post();
		get_template_part('content', get_post_format());
	}

	?>
	</div><?php

	theme_content_nav();

}
else {

	get_template_part('content', 'none');

}

get_footer();

?>
