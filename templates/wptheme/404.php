<?php 
/**
 * The template for displaying 404 pages (not found).
 */

get_header();
?>

<article class="post post_notfound">
	<h1 class="post-title"><?php _e('Page not found', 'squirrelpress') ?></h1>

	<div class="post-content text">

		<p><?php _e('It looks like nothing was found at this location. Maybe try a search?', 'squirrelpress') ?></p>

		<?php get_search_form() ?>

	</div>
</article>

<?php get_footer() ?>
