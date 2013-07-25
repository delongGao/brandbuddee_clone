$(document).ready(function() {
	$("#back-to-top").remove();
	$("#btnRedeemDisplay").click(function () {
		$(this).fadeOut();
		$("#lblRedeemCodeDisplay").delay(450).fadeIn();
	});
});

function enableBtnRefresh() {
	if($("#btnRefreshThisPage").attr("disabled")=="disabled") {
		$("#btnRefreshThisPage").removeAttr("disabled").removeClass("disabled");
	} // End if
} // End enableBtnRefresh()
