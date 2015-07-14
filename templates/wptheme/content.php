<?php
/**
 * The default template for displaying content.
 *
 * Used for both single and index/archive/search.
 */
?>

<article id="post-<?php the_ID() ?>" class="post post_single">
	<h2 class="post__title">
		<a href="<?php the_permalink() ?>"><?php the_title() ?></a>
		<?php edit_post_link('Edit', '<span class="admin-action">', '</span>') ?>
	</h2>
	<div class="post__excerpt">
		<?php the_excerpt() ?>
	</div>
</article>
