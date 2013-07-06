function setCurrentPageLinksActive() {
	var baseUrl = location.protocol + "//" + location.host;
	var curPage = document.URL.substring(baseUrl.length);
	
	$(".nav > li > a[href='" + curPage + "']").each(function() {
		$(this).parent().addClass('active');
	});
}

$(document).ready(function() {
	setCurrentPageLinksActive();
});