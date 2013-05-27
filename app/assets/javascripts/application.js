// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require bootstro
//= require flexslider
//= require layerslider
//= require jquery-easing
//= require jquerytransit
//= require layerslider-transitions
//= require_tree .

//addEventListener("load", function() { setTimeout(promo_campaign_wrap, 200); }, false);

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

	$(".follow-btn").live('click', function(event) {
		$(this).parent('div').html("<a href='#' class='btn main_followers_follow_btn follow-btn disabled'>Loading...</a>");
	});

	$(".followers_follow_btn").live('click', function(event) {
		$(this).parent('div').html("<a href='#' class='btn pull-right followers_follow_btn disabled'>Loading...</a>");
	});

	$("#following_total_link").live('click', function(event) {
		$('#campaign_tab').removeClass('active');
		$('#follower_tab').removeClass('active');
		$('#following_tab').addClass('active');
	});

	$("#follower_total_link").live('click', function(event) {
		$('#campaign_tab').removeClass('active');
		$('#following_tab').removeClass('active');
		$('#follower_tab').addClass('active');
	});

	$(".location_edit").mouseover(
	  function () {
	    $(".location_edit_bttn").fadeIn();
	  }
	);

	// $(".location_edit").mouseout(
	//   function () {
	//     $(".location_edit_bttn").fadeOut();
	//   }
	// );


	
	
});
