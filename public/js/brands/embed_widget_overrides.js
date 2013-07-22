$(document).ready(function() {
	$("#back-to-top").remove();
	$("#btnRedeemDisplay").click(function () {
		$(this).fadeOut();
		$("#lblRedeemCodeDisplay").delay(450).fadeIn();
	});
});