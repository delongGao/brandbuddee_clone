// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

addEventListener("load", function() { setTimeout(promo_campaign_wrap, 200); }, false);

function promo_campaign_wrap(){
	//$('.promo-campaign-wrap').fadeIn(600);

	//$('.promo-campaign-wrap').show();

	$("#promo-campaign-wrap").animate({
	       top: '+=100px'
	    }, { duration: 800, queue: false });
    //$(".splash_logo").fadeIn(600);
}


$(document).ready(function () {

	$(".redeem_button").live('click', function(event) {
		$(".redeem_button").hide();
		$(".redeem_code").animate({
		       top: '+=10px'
		    }, { duration: 500, queue: false });
	    $(".redeem_code").fadeIn(200);
	});
	
});