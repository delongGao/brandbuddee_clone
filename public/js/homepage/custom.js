jQuery(document).ready(function() {
	jQuery('.fullwidthbanner').revolution({
		delay: 12500
	});
	jQuery('#portfolio_hover li a, .portfolio_item').hover(function(){
		jQuery(this).find('.hover').stop(true, true).fadeIn(500);
	},function(){
		jQuery(this).find('.hover').stop(true, true).fadeOut(500);
	});
	jQuery('.hover').hover(function(){
		jQuery(this).find('.iconhover').stop().animate({ 'margin-top' : '80' }, 200, 'easeInCubic');
	},function(){
		jQuery(this).find('.iconhover').stop().animate({ 'margin-top' : '-100' }, 200, 'easeOutCubic');
	});
	jQuery().ready(function() {
	    jQuery(".client").jCarouselLite({
	    visible: 5,
	    auto: 5000,
	    //timeout: 20000,
	    speed: 800, 
	    //responsive: false,
	    //swipe: true,
	    circular: true,
		mouseWheel: false,	
	    btnNext: ".next", 
	    btnPrev: ".prev"
	    });
	});
	!function (jQuery) {
		jQuery(function(){
	  		jQuery('#small_slider').carousel({
	  			interval: 12500
	  		})
		})
	}(window.jQuery)
	jQuery(".test1").cycle({
	    fx: 'scrollLeft',
	    timeout: '2000',
		speed:  2000,
		pause: 0,
		pager:  '#nav'
	});
	jQuery("#slider2").cycle({
    	fx:     'scrollHorz',
	    timeout: 4000,
    	speedIn:  1200,
    	speedOut: 2000,
    	easeIn:  'easeInCirc',
    	easeOut: 'easeOutBounce',
    	delay:   -1500,
    	next:   '#next2',
    	prev:   '#prev2',
		slideExpr: '.slide',
		slideResize: 0,
		pager:  '.nav1'
	});
	jQuery(window).load(function(){
		jQuery('.bwWrapper').BlackAndWhite({
			hoverEffect : true,
			webworkerPath : false,
			responsive:true,
			speed: {
	        	fadeIn: 200,
	        	fadeOut: 800
	    	}
		});
	});
	window.addEvent('load', function() {
		var can = document.getElementById('canvas1');
		var context = can.getContext('2d');
		var percentage = -0.80;
		var degrees = percentage * 360.0;
		var radians = degrees * (Math.PI / 180);
		var x = 100;
		var y = 120;
		var r = 85;
		var s = 1.5 * Math.PI;
		context.beginPath();
		context.lineWidth = 18;
		context.arc(x, y, r, radians+s, s);
		context.strokeStyle = '#6fb554';
		context.stroke();
	});
	window.addEvent('load', function() {
		var can = document.getElementById('canvas2');
		var context = can.getContext('2d');
		var percentage = -0.70;
		var degrees = percentage * 360.0;
		var radians = degrees * (Math.PI / 180);
		var x = 100;
		var y = 120;
		var r = 85;
		var s = 1.5 * Math.PI;
		context.beginPath();
		context.lineWidth = 18;
		context.arc(x, y, r, radians+s, s);
		context.strokeStyle = '#6fb554';
		context.stroke();
	});
	window.addEvent('load', function() {
		var can = document.getElementById('canvas3');
		var context = can.getContext('2d');
		var percentage = -0.50;
		var degrees = percentage * 360.0;
		var radians = degrees * (Math.PI / 180);
		var x = 100;
		var y = 120;
		var r = 85;
		var s = 1.5 * Math.PI;
		context.beginPath();
		context.lineWidth = 18;
		context.arc(x, y, r, radians+s, s);
		context.strokeStyle = '#6fb554';
		context.stroke();
	});
	window.addEvent('load', function() {
		var can = document.getElementById('canvas4');
		var context = can.getContext('2d');
		var percentage = -0.40;
		var degrees = percentage * 360.0;
		var radians = degrees * (Math.PI / 180);
		var x = 100;
		var y = 120;
		var r = 85;
		var s = 1.5 * Math.PI;
		context.beginPath();
		context.lineWidth = 18;
		context.arc(x, y, r, radians+s, s);
		context.strokeStyle = '#6fb554';
		context.stroke();
	});
});
function alertbox_close(id){
	jQuery("#"+id).fadeOut();
	return false;
}
if (Modernizr.csstransitions) {
	function preloadImages(imgs, callback) {
		var cache = [],
			imgsTotal = imgs.length,
			imgsLoaded = 0;
		jQuery(imgs).each(function (i, img) {
			var cacheImage = document.createElement('img');
			cacheImage.onload = function () {
				if (++imgsLoaded == imgsTotal) callback();
			};
			cacheImage.src = jQuery(img).attr('src');
			cache.push(cacheImage);
		});
	};
	jQuery.fn.trans = function () {
		var t = arguments[0],
			d = arguments[1] || '';
		if (t) {
			jQuery.each(this, function (i, e) {
				jQuery(['-webkit-', '-moz-', '-o-', '-ms-', '']).each(function (i, p) {
					jQuery(e).css(p + 'transition' + d, t);
				});
			});
		}
	};
	jQuery(function(){
		//preload images contained within elements that need to animate
		preloadImages(jQuery('.services img, .featured img'), function () {
			jQuery('.services, .featured').appear({
				once: true,
				forEachVisible: function (i, e) {
					jQuery(e).data('delay', i);
				},
				appear: function () {
					var delay = 150,
						stagger = 800,
						sequential_delay = stagger * parseInt(jQuery(this).data('delay')) || 0;

					jQuery(this).children().each(function (i, e) {
						jQuery(e).trans(i * delay + sequential_delay + 'ms', '-delay');
					});
					jQuery(this).removeClass('animationBegin');
				}
			});
		});
	});
}
