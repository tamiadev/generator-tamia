<footer class="footer">
	<span class="footer__copyright">
		© <%= copyright %>, <?php echo date('Y') ?>. Site hand coded by <a href="<%= authorUrl %>"><%= authorName %></a>
	</span>
</footer>

<?php
wp_footer();
sq_theme_js($jquery_ver='2.1.3');
?>

</body>
</html>
