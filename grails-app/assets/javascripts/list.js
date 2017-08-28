//= require jquery
//= require amplify
//= require facets
//= require getQueryParam
//= require jquery-ui
//= require jquery.doubleScroll
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
