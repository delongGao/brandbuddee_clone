jQuery(document).ready(function($) {

	/* ########## */
	/*  CAROUSEL  */
	/* ########## */

	// Setting variables
	$home_carousel = $('#myCarousel');

	// Setting up homepage carousel
	$home_carousel.carousel({
		interval: false 
	})

	// animate first caption on website load
	$home_carousel.find('.active .caption p').animate({opacity: 1}, 600);
	// animate captions on slide (turn on/off)
	$home_carousel.bind('slid', function() {
		$(this).find('.active .caption p').animate({opacity: 1}, 600);
	}).bind('slide', function() {
		$(this).find('.active .caption p').animate({opacity: 0}, 300);
	});

});
