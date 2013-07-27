# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
	$(".accordion-heading.alt-accordion").click ->
		if $(this).next().height()==0 || $(this).next().is(':hidden')
			$(this).addClass('active')
		else if $(this).next().height()!=0
			$(this).removeClass('active')
	$("#btnDoItTaskBlog").click (event) ->
		if $(this).attr("disabled") == "disabled"
			event.preventDefault()
		else
			$("#btnDoneTaskBlog").removeClass("disabled").removeAttr("disabled")
			$("#txtBlogAddress").removeAttr("disabled").focus()
	$("#btnDoneTaskBlog").click (event) ->
		if $(this).attr("disabled") == "disabled"
			event.preventDefault()
		else
			if $("#txtBlogAddress").val().length < 1
				event.preventDefault()
				$(this).parent().parent().parent().append('<div class="alert alert-error fade in"><a href="#" class="close" data-dismiss="alert">&times;</a>Please make sure you enter a URL for the blog post.</div>')
	$("#btnDoItTaskYelp").click (event) ->
		if $(this).attr("disabled") == "disabled"
			event.preventDefault()
		else
			$("#btnDoneTaskYelp").removeClass("disabled").removeAttr("disabled")
			$("#txtYelpAddress").removeAttr("disabled").focus()
	$("#btnDoneTaskYelp").click (event) ->
		if $(this).attr("disabled") == "disabled"
			event.preventDefault()
		else
			if $("#txtYelpAddress").val().length < 1
				event.preventDefault()
				$(this).parent().parent().parent().append('<div class="alert alert-error fade in"><a href="#" class="close" data-dismiss="alert">&times;</a>Please make sure you enter a URL for the web address.</div>')
	$("#btnDoItTaskFacebook").click ->
		$("#btnDoneTaskFacebook").removeClass("disabled").removeAttr("disabled")
	$("#btnDoneTaskFacebook").click (event) ->
		if $(this).attr("disabled") == "disabled"
			event.preventDefault()
	$("#btnDoItTaskTwitter").click ->
		$("#btnDoneTaskTwitter").removeClass("disabled").removeAttr("disabled")
	$("#btnDoneTaskTwitter").click (event) ->
		if $(this).attr("disabled") == "disabled"
			event.preventDefault()
	$("#btnDoItTaskCustom1").click ->
		$("#btnDoneTaskCustom1").removeClass("disabled").removeAttr("disabled")
	$("#btnDoneTaskCustom1").click (event) ->
		if $(this).attr("disabled") == "disabled"
			event.preventDefault()
	$("#btnDoItTaskCustom2").click ->
		$("#btnDoneTaskCustom2").removeClass("disabled").removeAttr("disabled")
	$("#btnDoneTaskCustom2").click (event) ->
		if $(this).attr("disabled") == "disabled"
			event.preventDefault()
	$("#btnDoItTaskCustom3").click ->
		$("#btnDoneTaskCustom3").removeClass("disabled").removeAttr("disabled")
	$("#btnDoneTaskCustom3").click (event) ->
		if $(this).attr("disabled") == "disabled"
			event.preventDefault()
	$("#btnDoItTaskCustom4").click ->
		$("#btnDoneTaskCustom4").removeClass("disabled").removeAttr("disabled")
	$("#btnDoneTaskCustom4").click (event) ->
		if $(this).attr("disabled") == "disabled"
			event.preventDefault()
	$("#btnDoItTaskCustom5").click ->
		$("#btnDoneTaskCustom5").removeClass("disabled").removeAttr("disabled")
	$("#btnDoneTaskCustom5").click (event) ->
		if $(this).attr("disabled") == "disabled"
			event.preventDefault()