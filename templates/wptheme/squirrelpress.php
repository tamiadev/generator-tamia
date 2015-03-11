<?php
/**
 * SquirrelPress: Wordpress Bootstrap
 * Author: Artem Sapegin, http://sapegin.me
 */

/**
 * Installation and configuration:
 *
 * // functions.php
 * // Populate post’s gallery to RSS feed
 * add_theme_support('sq-gallery-rss');
 * // Retina logo
 * add_theme_support('sq-retina');
 * // Twitter
 * add_theme_support('sq-twitter', 'creator_twitter', 'site_twitter');
 * include 'squirrelpress.php';
 */

// Useful shortcuts
$sq_uri = $_SERVER['REQUEST_URI'];

// Grunt Fingerprint
file_exists('fingerprint.php') && include 'fingerprint.php';

// Debug mode: set WP_THEME_DEBUG in wp-config.php
!defined('WP_THEME_DEBUG') && define('WP_THEME_DEBUG', false);


// Fix sticky footer
function theme_admin_bar($x) {
	?><style>
html { padding-top:28px; }
</style><?php
}


/**
 * Filters
 */

// Head extras
function _sq_head() {
	// JS retina helper
	if (get_theme_support('sq-retina')) { ?><script>
var retina = (function(w) {
	if (w.devicePixelRatio > 1) return true;
	if (w.matchMedia && w.matchMedia('(-webkit-min-device-pixel-ratio:1.5),(min-resolution:144dpi)').matches) return true;
	return false;
})(window);
function retinify(html) {
	if (retina) html = html.replace('.png', '@2x.png');
	document.write(html);
}
</script><?php
	}

	?>
<meta name="description" content="<?php sq_description() ?>">
	<?php

	// Nice title, description and image for Facebook and Twitter
	if (is_single() || is_page()) {
	?>
<meta property="og:type" content="article">
<meta property="og:url" content="<?php echo get_permalink() ?>">
<meta property="og:title" content="<?php the_title() ?>">
<meta property="og:description" content="<?php echo sq_description() ?>">
<meta property="og:image" content="<?php echo sq_get_post_cover_url() ?>">
<meta name="twitter:card" content="summary"><?php
		$twitters = get_theme_support('sq-twitter');
		if ($twitters[0]) {
			echo "<meta name=\"twitter:creator\" content=\"@{$twitters[0]}\">\n";
		}
		if ($twitters[1]) {
			echo "<meta name=\"twitter:site\" content=\"@{$twitters[1]}\">\n";
		}
	}
}
add_action('wp_head', '_sq_head');

// Setup theme
function sq_theme_setup() {
	// This theme styles the visual editor with editor-style.css to match the theme style.
	add_editor_style('css/editor-style.css');

	// Add default posts and comments RSS feed links to <head>.
	add_theme_support('automatic-feed-links');

	// Admin bar
	add_theme_support('admin-bar', array('callback' => 'theme_admin_bar'));

	/*
	 * Let WordPress manage the document title.
	 * By adding theme support, we declare that this theme does not use a
	 * hard-coded <title> tag in the document head, and expect WordPress to
	 * provide it for us.
	 */
	// ??? add_theme_support( 'title-tag' );

	// Remove some shit
	remove_action('wp_head', 'index_rel_link');
	remove_action('wp_head', 'parent_post_rel_link');
	remove_action('wp_head', 'start_post_rel_link');
	remove_action('wp_head', 'adjacent_posts_rel_link');

	// Make theme available for translation.
	// Translations can be filed in the /languages/ directory.
	load_theme_textdomain('squirrelpress', get_template_directory() . '/languages');

	if (function_exists('theme_setup')) {
		theme_setup();
	}
}
add_action('after_setup_theme', 'sq_theme_setup' );

// Generator
function sq_generator($generator) {
	return str_replace(' ' . get_bloginfo('version'), '/SquirrelPress', $generator);
}
add_filter('the_generator', 'sq_generator');



/**
 * BEM printer: prints opening tag for BEM block.
 *
 * @param {Array} $args:
 * - {String} $block Block name.
 * - {String} [$elem] Element name.
 * - {Array} [$mods] Modifiers.
 * - {Array} [$attrs] Attributes (attr => value).
 * - {Array} [$data] Data attributes (attr => value).
 * - {String} [$tag] Tag name (default: 'div').
 */
function b($args) {
	$block = $args['block'];
	$elem = $args['elem'] ? $args['elem'] : false;
	$mods = $args['mods'] ? $args['mods'] : array();
	$attrs = $args['attrs'] ? $args['attrs'] : array();
	$data = $args['data'] ? $args['data'] : array();
	$tag = $args['tag'] ? $args['tag'] : 'div';

	if (!is_array($mods)) {
		if (empty($mods)) $mods = array();
		else $mods = array($mods);
	}

	$base = $elem ? "{$block}__{$elem}" : $block;
	$classes = array($base);
	foreach ($mods as $m) {
		$classes[] = "{$base}_{$m}";
	}
	$classes = implode(' ', $classes);

	if (!empty($attrs['href'])) $tag = 'a';
	foreach ($data as $k => $v) {
		$attrs["data-$k"] = $v;
	}

	$html = "<$tag class=\"$classes\"";

	foreach ($attrs as $k => $v) {
		$html .= " $k=\"$v\"";
	}

	$html .= ">";

	echo $html;

	return $tag;
}


/**
 * BEM printer: prints closing tag for BEM block.
 *
 * @param {String} [$tag] Tag name (default: 'div').
 */
function bc($tag='div') {
	echo "</$tag>";
}


/**
 * Is we’re on WordPress root page? It’s folder where WordPress is installed, can be differ from is_home().
 *
 * TODO: is_front_page() && is_home() ???
 *
 * @return {Boolean}
 */
function sq_is_wp_root() {
	return $sq_uri == preg_replace('%^https?://' . $_SERVER['HTTP_HOST'] . '%', '', get_bloginfo('wpurl')) . '/';
}


/**
 * Prints site logo: PNG, SVG or text with link to homepage.
 *
 * Assumes that logo is located in `img/logo.png` or `img/logo.svg` file.
 *
 * Generates markup:
 * h1.logo>img.logo__img+span.logo__inner
 * h1.logo>object.logo__img+span.logo__inner
 * h2.logo>img.logo__img+a.logo__inner.logo__inner_link
 * h2.logo>a.logo__inner.logo__inner_link
 *
 * @param {Array|Boolean} [$img] PNG sizes array. true for SVG.
 * @param {Boolean} [$svg] Include SVG file (default: false).
 */
function sq_logo($img=false, $svg=false) {
	if (sq_is_wp_root()) {
		$h_tag = 'h1';
		$a_tag = 'span';
		$a_mods = array();
		$attrs = array();
	}
	else {
		$h_tag = 'h2';
		$a_tag = 'a';
		$a_mods = array('link');
		$attrs = array('href' => home_url('/'), 'rel' => 'home');
	}

	b(array('block'=>'logo', 'tag'=>$h_tag));
		if ($svg) {
			sq_svg('logo.svg', $title, $class='logo__img');
		}
		b(array('block'=>'logo', 'elem'=>'inner', 'mods'=>$a_mods, 'tag'=>$a_tag, 'attrs'=>$attrs));
			$title = get_bloginfo('name');
			if ($img) {
				if (!$svg) {
					sq_img('logo.png', $img, $title, $class='logo__img');
				}
			}
			else {
				echo $title;
			}
		bc($a_tag);
	bc($h_tag);
}


/**
 * Prints <img> tag.
 *
 * Supports retina. Assumes retina images have `@2x` suffix.
 *
 * @param {String} $src Image file path (relative to theme’s `img` folder).
 * @param {Array} $size Images sizes array.
 * @param {String} [$alt] Alternative text (default: '').
 * @param {String} [$class] CSS class name (default: none).
 */
function sq_img($src, $size, $alt='', $class=false) {
	$src = sq_get_img_path($src);
	$attrs = '';
	if ($class) $attrs .= " class=\"$class\"";
	$width = $size[0];
	$height = $size[1];
	$img_tag = "<img src=\"$src\" width=\"$width\" height=\"$height\" alt=\"$alt\"$attrs>";

	if (get_theme_support('sq-retina')) {
		echo "<script>retinify('$img_tag');</script><noscript>";
	}
	echo $img_tag;
	if (get_theme_support('sq-retina')) {
		echo '</noscript>';
	}
}


/**
 * Prints SVG image.
 *
 * @param {String} $src Image file path (relative to theme’s `img` folder).
 * @param {String} [$alt] Alternative text (default: '').
 * @param {String} [$class] CSS class name (default: none).
 */
function sq_svg($src, $alt, $class=false) {
	$src = sq_get_img_path($src);
	$attrs = '';
	if ($class) $attrs .= " class=\"$class\"";
	echo "<object data=\"$src\" type=\"image/svg+xml\" title=\"$alt\"$attrs></object>";
}


/**
 * List of modifiers for menu item.
 *
 * Define `theme_menu_item_mods()` function to add theme specific modifiers.
 *
 * @param {Object} $item Menu item.
 * @return {Array}
 */
function _sq_menu_item_mods($item) {
	$item_url = preg_replace('%^https?://' . $_SERVER['HTTP_HOST'] . '%', '', $item->url);
	$mods = array();

	if (!sq_is_wp_root()) {
		if (strrpos($item_url, $sq_uri) > 1)
			$mods[] = 'active';
		if ($item_url == $sq_uri)
			$mods[] = 'current';
	}

	// Theme specific modifiers
	if (function_exists('theme_menu_item_mods')) {
		$mods = theme_menu_item_mods($mods, $sq_uri, $item_url);
	}

	return $mods;
}


/**
 * Prints menu.
 *
 * Generates markup:
 * div.menu.menu_primary>div.menu__item.menu__item_active>a.menu__link.menu__link_active...
 *
 * @param {String} $id Menu ID.
 * @param {Bool} $wrap Wrap in .menu block?
 */
function sq_menu($id, $wrap=true) {
	if ($wrap) {
		$mod = ($id == 'primary') ? '' : $id;
		b(array('block'=>'menu', 'mods'=>$mod));
	}
	foreach (wp_get_nav_menu_items($id) as $item) {
		$mods = _sq_menu_item_mods($item);
		b(array('block'=>'menu', 'elem'=>'item', 'mods'=>$mods));
			b(array('block'=>'menu', 'elem'=>'link', 'mods'=>$mods, 'attrs'=>array('href'=>$item->url)));
				echo $item->title;
			bc('a');
		bc();
	}
	if ($wrap) {
		bc();
	}
}


/**
 * Prints HTML with meta information for the current post-date/time.
 */
function sq_posted_on() {
	printf('<a href="%1$s" title="%2$s" rel="bookmark" class="time"><time datetime="%3$s" pubdate>%4$s</time></a>',
		esc_url(get_permalink()),
		esc_attr(get_the_time()),
		esc_attr(get_the_date('c')),
		esc_html(get_the_date())
	);
}


/**
 * Prints all theme <script> tags.
 *
 * @param {String} [$jquery_version] jQuery version if needed.
 *
 * Depends on `WP_THEME_DEBUG`.
 */
function sq_theme_js($jquery_version=false) {
	if ($jquery_version) { ?>
<script src="http://yandex.st/jquery/<?php echo $jquery_version ?>/jquery.min.js"></script>
<script>!window.jQuery && document.write(unescape('%3Cscript src="<?php echo get_template_directory_uri(); ?>/js/libs/jquery-<?php echo $jquery_version ?>.min.js"%3E%3C/script%3E'))</script>
	<?php }
	sq_js('build/scripts' . (WP_THEME_DEBUG ? '' : '.min') . '.js');
}


/**
 * Prints <script> tag with fingerprint.
 *
 * @param {String} $filepath Filepath (relative to theme directory).
 * @param {String} [$attrs] Additional attributes for <script> tag.
 *
 * Depends on `WP_THEME_DEBUG` and `V` consts.
 */
function sq_js($filepath, $attrs=false) {
	$filepath = sq_versioned($filepath);
	echo "<script src=\"", get_template_directory_uri(), "/$filepath\"", ($attrs ? " $attrs" : ""), "></script>\n";
}


/**
 * Prints <link rel=stylesheet> tag with fingerprint.
 *
 * @param {String} [$filepath] Filepath, relative to theme directory (default: theme stylesheet).
 * @param {String} [$ie] Condition for IE’s conditional comment.
 *
 * Depends on `WP_THEME_DEBUG` and `V` consts.
 */
function sq_css($filepath=false, $ie=false) {
	if ($filepath && strpos($filepath, 'http://') !== 0) $filepath = get_template_directory_uri() . '/' . $filepath;
	else if (!$filepath) $filepath = get_bloginfo('stylesheet_url');
	$filepath = sq_versioned($filepath);
	if ($ie) echo "<!--[if $ie]>";
	echo "<link rel=\"stylesheet\" href=\"$filepath\">";
	if ($ie) echo "<![endif]-->";
	echo "\n";
}


/**
 * Adds version or random number to URL.
 *
 * @param {String} $filepath
 * @return {String}
 */
function sq_versioned($url) {
	if (WP_THEME_DEBUG)
		return "$url?" . rand();
	elseif (defined('V'))
		return "$url?" . V;
	return $url;
}


/**
 * Returns path of an image.
 *
 * @param {String} $filepath Filepath (relative to theme directory).
 * @return {String}
 */
function sq_get_img_path($filepath) {
	return get_template_directory_uri() . '/img/' . $filepath;
}


/**
 * Prints path of an image.
 *
 * @param {String} $filepath Filepath (relative to theme directory).
 */
function sq_img_path($filepath) {
	echo sq_get_img_path($filepath);
}


/**
 * Prints page title.
 */
function sq_title() {
	// Page title
	wp_title('—', true, 'right');

	// Blog name
	bloginfo('name');

	// Blog description for the home page
	$site_description = get_bloginfo('description', 'display');
	if ($site_description && sq_is_wp_root())
		echo " | $site_description";
}


/**
 * Prints page description.
 */
function sq_description() {
	global $post;
	if ((is_single() || is_page()) && !empty($post->post_excerpt))
		echo strip_tags($post->post_excerpt);
	elseif (is_single() && !empty($post->post_content))
		echo strip_tags($post->post_content);
	else
		echo get_bloginfo('name', 'display') . '. ' . get_bloginfo('description', 'display');
}


/**
 * Prints body class names.
 */
function sq_page_classes() {
	global $post;
	$classes = array();
	if (is_page()) {
		$classes[] = 'page_page';
		$classes[] = "page_{$post->post_name}";
	}
	if (is_category())
		$classes[] = 'page_category';
	if (is_single())
		$classes[] = 'page_single';
	if (is_home())
		$classes[] = 'page_home';
	if (is_archive() || is_search())
		$classes[] = 'page_archive';
	if (is_404())
		$classes[] = 'page_404';
	echo implode(' ', $classes);
}


/**
 * Post cover image URL: thumbnail or first image.
 *
 * @return {String}
 */
function sq_get_post_cover_url() {
	global $post;

	// Post thumbnail
	$thumbnail_id = get_post_thumbnail_id($post->ID);

	// Or first uploaded image
	if (!$thumbnail_id) {
		$images = get_children(array('post_parent' => $post->ID, 'post_type' => 'attachment',
			'post_mime_type' => 'image', 'orderby' => 'menu_order', 'order' => 'ASC', 'numberposts' => 1));
		if ($images) {
			$first_image = array_shift($images);
			if ($first_image) {
				$thumbnail_id = $first_image->ID;
			}
		}
	}

	if ($thumbnail_id) {
		return wp_get_attachment_thumb_url($thumbnail_id);
	}

	return '';
}


/**
 * RSS.
 *
 * Requires `add_theme_support('sq-gallery-rss')`.
 */
if (get_theme_support('sq-gallery-rss')) {
	function sq_rss_gallery($content_original) {
		$content = '';
		$images = get_children( array( 'post_parent' => $post->ID, 'post_type' => 'attachment', 'orderby' => 'menu_order', 'order' => 'ASC', 'numberposts' => 999 ) );
		foreach ($images as $image) {
			$extra = $image->post_content;

			$link = get_post_meta($image->ID, '_big_image_url', true);
			if (strpos($extra, 'http://') !== false) {
				$link = $extra;
			}

			$content .= "<p>";
			if ($link) {
				$content .= "<a href=\"$link\">";
			}

			if (strpos($image->post_mime_type, 'flash') !== false) {
				$url = $image->guid;
				$size_html = '';
				if ($extra) {
					$extra = preg_split("/\D/", $extra);
					if (count($extra) === 2) {
						$size_html = " width=\"$extra[0]\" height=\"$extra[1]\"";
					}
				}
				$content .= "<object type=\"application/x-shockwave-flash\" data=\"$url\" $size_html>" .
					"<param name=\"movie\" value=\"$url\">" .
					"<param name=\"quality\" value=\"high\">" .
				"</object>";
			}
			else {
				$content .= wp_get_attachment_image($image->ID, 'full');
			}

			if ($link) {
				$content .= "</a>";
			}
			if ($image->post_excerpt) {
				$content .= "<div>" . $image->post_excerpt . "</div>";
			}
			$content .= "</p>";
		}
		return $content_original . $content;
	}
	add_filter('the_content_feed', 'sq_rss_gallery');
}


/**
 * Checks if a string starts with another string.
 *
 * @param {String} $haystack The main string being compared.
 * @param {String} $needle The substring to find.
 * @return {Boolean}
 */
function sq_str_starts_with($haystack, $needle) {
	return substr_compare($haystack, $needle, 0, strlen($needle)) === 0;
}


/**
 * Checks if a string starts with another string.
 *
 * @param {String} $haystack The main string being compared.
 * @param {String} $needle The substring to find.
 * @return {Boolean}
 */
function sq_str_ends_with($haystack, $needle) {
	return substr_compare($haystack, $needle, -strlen($needle)) === 0;
}

?>
