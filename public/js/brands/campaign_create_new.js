$(document).ready(function() {
	// brands#campaign_create

	// step tabs
	$('#step_tab li a').click(function(event) {
		// check story chosen
		if ($(this).attr("disabled")) {
			var stepDisable = noty({
				text: 'PLease finish the current step first.', 
				type: 'warning'
			});
		}
		else {
			return $(this).tab("show");
		}
	});
	$('#step_tab_content .nav_buttons a').click(function(event) {
		// check story chosen
		if ($(this).attr("disabled")) {
			var navDisable = noty({
				text: 'Please finish the current step first.',
				type: 'warning'
			});
		}
		else {
			$('#step_tab li.active').removeClass("active");
			var tabItemId = $(this).attr("href") + "_tabItem";
			$(tabItemId).addClass("active");
			return $(this).tab("show");
		}
	});
	$('#step_tab li a, #step_tab_content .nav_buttons a').tooltip();

	// story options
	$('#story_fb label').click(function() {
		if ($(this).hasClass("muted")) {
			$(this).removeClass("muted");
			$('#wrapper_fb').fadeIn();
			$('#story_customize label').addClass("muted");
			$('#wrapper_customize_story').fadeOut();
			$(this).parent().addClass("focused");
			$('#story_customize').removeClass("focused");
		}
		else {
			$(this).addClass("muted");
			$('#wrapper_fb').fadeOut();
			$(this).parent().removeClass("focused");	
		}
	});
	$('#story_customize label').click(function() {
		if ($(this).hasClass("muted")) {
			$(this).removeClass("muted");
			$('#wrapper_customize_story').fadeIn();
			$('#story_fb label').addClass("muted");
			$('#wrapper_fb').fadeOut();
			$(this).parent().addClass("focused");
			$('#story_fb').removeClass("focused");
		}
		else {
			$(this).addClass("muted");
			$('#wrapper_customize_story').fadeOut();
			$(this).parent().removeClass("focused");	
		}
	});

	// ajax fb story select
	$('.select_fb_page').click(function() {
		var acctok = $(this).attr("data-acctok");
		var url = "/brands/campaigns/story-page-chosen?&acctok=" + acctok;
		// console.log(url);
		$( document ).ajaxStart(function() {
		  	$('#page_select_buttons').fadeOut();
			$('#fb_page_loading').fadeIn();
		});

		$.getJSON( url )
			.done( function(data) {
				// console.log(data);
				// seperate data
				var page_detail = data.page_detail;
				var page_profile_img = data.page_profile_img;
				var wall_posts = data.wall_posts;
				
				page_name = page_detail.name;
				page_website = page_detail.website;
				page_profile_img = page_profile_img.source;

				// loop process of creating stories DOMs.
				var counter = 0;
				var group = 1;
				$.each( wall_posts, function( key, val ) {
					if (val.message) {
						var message = $("<p>" + val.message + "</p>");
					}
					else {
						var message = $("<p>" + val.from.name + " has a new announcement</p>");
					}
					if (typeof page_profile_img === "undefined") {
						var page_pic = $("<div class='no_fb_page_pic'>No Image</div>");
					}
					else {
						var page_pic = $("<img src='" + page_profile_img + "' width='80px'/>");
					}
					if (val.picture) {
						var story_pic = $('<img class="span5" src=' + val.picture + ' />');
					}
					else {
						var story_pic = $("<div class='no_fb_story_pic span5'>No Image</div>");
					}
					var leftside = $('<div class="span2 fb_page_pic"></div>');
					var rightSide = $('<div class="fb_story_ar span9"></div>');
					var title_ar = $('<div></div>');
					var content_ar = $('<div></div>');

					$("<h3><a href='" + page_detail.link + "' target='blank'>" + page_name + "</a></h3>").appendTo(title_ar);
					story_pic.appendTo(content_ar);
					$("<div class='story_content span7'><h3>" + page_name + "</h3><p><a href='" + page_website + "' target='blank'>" + page_website + "</a></p></div>").append(message).append($("<p><a href='" + val.actions[0].link + "' target='blank'>Post link</a></p>")).appendTo(content_ar);
					rightSide.append(title_ar);
					rightSide.append(content_ar);
					var li = $("<li class='row story_item'></li>").addClass("group-" + group);
					if (group > 1) {
						li.css("display","none");
					}
					li.append(
						leftside.append(
							page_pic
						)
					)
					li.append(rightSide);

					// construct the hover item and append it to li
					var hoverPrompt = $("<div class='story_item_hoverbox' style='display:none;'><h2 class='story_item_prompt'><a href='#'>Promote this story! <i class='icon-bullhorn icon-2'></i></a></h2><h2 style='display:none;' class='story_chosen_loading'>Loading...please wait. <img src='/images/brands/loading-1.gif' width='30px' /></h2><h2 style='display:none;' class='story_selected'>Story selected! <i class='icon-ok icon-2'></i></h2></div>");
					li.append(hoverPrompt);

					li.insertBefore($('#story-button-box'));
					// $('#story_selection_box').append(li);
					$('#story_selection_box').fadeIn(function() {
						$('#fb_page_loading').fadeOut();
					});
					counter += 1;
					if (counter % 2 == 0 && counter != 0) { // here need to be changed for production
						group += 1;
					};
				});
				$('#totalGroup').prop("value",$('#story_selection_box li').length);

				// bind story item hover function to the story items
				$('.story_item').bind({
					"mouseenter":function() {
						$(this).find(".story_item_hoverbox").fadeIn();
					},
					"mouseleave":function() {
						$(this).find(".story_item_hoverbox").fadeOut();
					}
				});
			})
			.fail(function() {
				alert("Oops! connection failed, please try again later.");
			});
	});

	// load_more function 
	$('#load_more').click(function() {
		var nextGroup = $("#nextGrpToDisplay").val();
		var str = "group-" + nextGroup;
		$("li." + str).fadeIn();
		$("#nextGrpToDisplay").prop("value",nextGroup + 1); 
		// smoothly scroll to the newly added stories --beautiful!!
		$('html, body').animate({
			scrollTop: $("li." + str).offset().top
		}, 2000);

		// check the currently loaded stories, if full give hints, ,aybe change this part to a new notification feature
		if ($('#story_selection_box li').length == $('#totalGroup').val()) {
			$('#selectAnother').removeClass("span3").addClass("span6");
			$('#load_more').remove();
			var nStoriesFull = noty({
				text: 'All stories loaded!',
				type: 'information'
			});
		};
	});
});

function ajaxCheckStoryChosen () {

}

