//= require jquery
//= require amplify
//= require facets
//= require getQueryParam
//= require jquery-ui
//= require jquery.doubleScroll
//= require ekko-lightbox-5.2.0
//= require common

if (typeof jQuery !== 'undefined') {
	(function($) {
		$('#spinner').ajaxStart(function() {
			$(this).fadeIn();
		}).ajaxStop(function() {
			$(this).fadeOut();
		});
	})(jQuery);
}
