<?php
/**
 * The template used for displaying page content.
 */
?>

<article id="post-<?php the_ID() ?>" class="post post_single">

	<h1 class="post-title">
		<?php the_title() ?>
		<?php edit_post_link('Edit', '<span class="admin-action">', '</span>') ?>
	</h1>

	<div class="post-content text">
		<?php the_content() ?>
	</div>

</article>
