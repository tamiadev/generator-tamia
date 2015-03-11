<?php
/**
 * The template part for displaying a message that posts cannot be found.
 */
?>

<article class="post post_notfound">
	<h1 class="post-title"><?php _e('Nothing Found', 'squirrelstrap') ?></h1>

	<div class="post-content text">

<?php

if (is_home() && current_user_can('publish_posts' )) {

	?><p><?php printf(__('Ready to publish your first post? <a href="%1$s">Get started here</a>.', 'squirrelstrap'), esc_url(admin_url('post-new.php'))) ?></p><?php

}
elseif (is_search()) {

	?><p><?php _e('Sorry, but nothing matched your search terms. Please try again with some different keywords.', 'squirrelstrap') ?></p><?php
	get_search_form();

}
else {

	?><p><?php _e('It seems we can’t find what you’re looking for. Perhaps searching can help.', 'squirrelstrap') ?></p><?php
	get_search_form();

}

?>

	</div>
</article>
