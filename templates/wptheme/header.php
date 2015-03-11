<!doctype html>
<html <?php language_attributes() ?>>
<head>
	<meta charset="<?php bloginfo('charset') ?>">
	<title><?php sq_title() ?></title>
	<?php
	sq_js('build/modernizr.js');
	sq_css();
	?>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<link rel="pingback" href="<?php bloginfo('pingback_url') ?>">
	<?php wp_head() ?>
</head>

<body class="<?php sq_page_classes() ?>">

<header class="header">
	<div class="header__logo">
		<?php sq_logo(array(200, 100), $svg=true) ?>
	</div>
	<nav class="header__menu">
		<?php sq_menu('primary', $wrap=false) ?>
	</nav>
</header>
