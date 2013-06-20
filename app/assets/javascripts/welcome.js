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
});