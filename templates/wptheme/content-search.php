<?php
/**
 * The template part for displaying results in search pages.
 *
 * Learn more: {@link https://codex.wordpress.org/Template_Hierarchy}
 */
?>

<article id="post-<?php the_ID() ?>" class="post post_search">

	<h1 class="post-title">
		<a href="<?php the_permalink() ?>" rel="bookmark"><?php the_title() ?></a>
		<?php edit_post_link('Edit', '<span class="admin-action">', '</span>') ?>
	</h1>

	<div class="post-content text">
		<?php the_content() ?>
	</div>

	<?php if (get_post_type() == 'post') { ?>
		<div class="post-tags">
			<?php the_category(', ') ?>
		</div>

		<div class="post-meta">
			<?php sq_posted_on() ?>
		</div>
	<?php } ?>

</article>
