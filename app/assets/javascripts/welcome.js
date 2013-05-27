$(document).ready(function(){
	$("#homeCarousel").carousel({
		interval: 3000,
		pause: "hover"
	}).hover(
  		function(){
    		$(".carousel-control").fadeIn(500);
  		},
  		function(){
    		$(".carousel-control").fadeOut(500);
  		}
  	);
  	$("#carousel").carousel({
		interval: 5000,
		pause: "hover"
	});
    $('<i id="back-to-top" class="icon-chevron-up"></i>').appendTo($("body"));
	$(window).scroll(function(){
		if($(this).scrollTop()!=0){
			$("#back-to-top").fadeIn()
		}else{
			$("#back-to-top").fadeOut()
		}
	});
	$("#back-to-top").click(function(){
		$("body,html").animate({scrollTop:0},600)
	});
	$('.flexslider').flexslider({
	   	animation: "slide", // or fade
	   	animationLoop: true,
	   	itemWidth: 200,
	   	slideshow: true, 
	   	itemMargin: 1,
	   	minItems: 1,
	   	maxItems: 1,
	   	startAt: 2, // default: 0
	   	slideshowSpeed: 5000, // default: 7000
	   	pauseOnHover: true, // default: false
	   	animationSpeed: 800, // default: 600
	   	touch: true,
	   	directionNav: true // Left right arrows?
  	});
  	$("#triggerSlide1").click(function(){
		$('#layerslider_6').layerSlider(1);
	});
	$("#triggerSlide2").click(function(){
		$('#layerslider_6').layerSlider(2);
	});
	$("#triggerSlide3").click(function(){
		$('#layerslider_6').layerSlider(3);
	});
});
var lsjQuery = jQuery;var curSkin = 'glass';
lsjQuery(document).ready(function() {
	if(typeof lsjQuery.fn.layerSlider == "undefined") { lsShowNotice('layerslider_6','jquery'); }
    else if(typeof lsjQuery.transit == "undefined" || typeof lsjQuery.transit.modifiedForLayerSlider == "undefined") { lsShowNotice('layerslider_6', 'transit');
	}
    else {
        lsjQuery("#layerslider_6").layerSlider({
            width : '1280px',
            height : '540px',
            responsive : true,
            responsiveUnder : 0,
            sublayerContainer : 0,
            autoStart : true,
            pauseOnHover : true,
            firstLayer : 1,
            animateFirstLayer : true,
            randomSlideshow : false,
            twoWaySlideshow : false,
            loops : 0,
            forceLoopNum : true,
            autoPlayVideos : false,
            autoPauseSlideshow : 'auto',
            youtubePreview : 'maxresdefault.jpg',
            keybNav : true,
            touchNav : true,
            skin : 'glass',
            skinsPath : 'assets/',
            globalBGColor : 'transparent',
            navPrevNext : true,
            navStartStop : true,
            navButtons : true,
            hoverPrevNext : true,
            hoverBottomNav : true,
            showBarTimer : true,
            showCircleTimer : false,
            thumbnailNavigation : 'hover',
            tnWidth : 100,
            tnHeight : 60,
            tnContainerWidth : '60%',
            tnActiveOpacity : 35,
            tnInactiveOpacity : 100,
            imgPreload : true,
    		yourLogo : false,
            yourLogoStyle : 'left: 10px; top: 10px;',
            yourLogoLink : false,
            yourLogoTarget : '_self',
            cbInit : function(element) { },
            cbStart : function(data) { },
            cbStop : function(data) { },
            cbPause : function(data) { },
            cbAnimStart : function(data) { // Called when the slide is first loaded
            	if(data.nextLayerIndex == 1) {
            		$("#triggerSlide1").css({
						"border-color": "#7EC1E1",
						"top": "-30px"
					});
					$("#triggerSlide2").css({
						"border-color": "#FFFFFF",
						"top": "0"
					});
					$("#triggerSlide3").css({
						"border-color": "#FFFFFF",
						"top": "0"
					});
					$("#textSlide1").css("color", "#7EC1E1");
					$("#textSlide2").css("color", "#000000");
					$("#textSlide3").css("color", "#000000");
            	} else if(data.nextLayerIndex == 2) {
            		$("#triggerSlide2").css({
						"border-color": "#C7E478",
						"top": "-30px"
					});
					$("#triggerSlide1").css({
						"border-color": "#FFFFFF",
						"top": "-0"
					});
					$("#triggerSlide3").css({
						"border-color": "#FFFFFF",
						"top": "0"
					});
					$("#textSlide2").css("color", "#C7E478");
					$("#textSlide1").css("color", "#000000");
					$("#textSlide3").css("color", "#000000");
            	} else { // 3
            		$("#triggerSlide3").css({
						"border-color": "#7EC1E1",
						"top": "-30px"
					});
					$("#triggerSlide1").css({
						"border-color": "#FFFFFF",
						"top": "-0"
					});
					$("#triggerSlide2").css({
						"border-color": "#FFFFFF",
						"top": "0"
					});
					$("#textSlide3").css("color", "#7EC1E1");
					$("#textSlide1").css("color", "#000000");
					$("#textSlide2").css("color", "#000000");
            	} // End else
            },
            cbAnimStop : function(data) { },
            cbPrev : function(data) { },
            cbNext : function(data) { }
        }); // For slide numbers, use: data.curLayerIndex & data.nextLayerIndex These are ints
    }
});