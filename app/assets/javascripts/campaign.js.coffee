# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
	expression = /\b((http(s?):\/\/)([a-z0-9\-]+\.)+(MUSEUM|TRAVEL|AERO|ARPA|ASIA|EDU|GOV|MIL|MOBI|COOP|INFO|NAME|BIZ|CAT|COM|INT|JOBS|NET|ORG|PRO|TEL|A[CDEFGILMNOQRSTUWXZ]|B[ABDEFGHIJLMNORSTVWYZ]|C[ACDFGHIKLMNORUVXYZ]|D[EJKMOZ]|E[CEGHRSTU]|F[IJKMOR]|G[ABDEFGHILMNPQRSTUWY]|H[KMNRTU]|I[DELMNOQRST]|J[EMOP]|K[EGHIMNPRWYZ]|L[ABCIKRSTUVY]|M[ACDEFGHKLMNOPQRSTUVWXYZ]|N[ACEFGILOPRUZ]|OM|P[AEFGHKLMNRSTWY]|QA|R[EOSUW]|S[ABCDEGHIJKLMNORTUVYZ]|T[CDFGHJKLMNOPRTVWZ]|U[AGKMSYZ]|V[ACEGINU]|W[FS]|Y[ETU]|Z[AMW])(:[0-9]{1,5})?((\/([a-z0-9_\-\.~]*)*)?((\/)?\?[a-z0-9+_\-\.%=&amp;]*)?)?(#[a-zA-Z0-9!$&'()*+.=-_~:@\/?]*)?)/i
	url_regex = new RegExp(expression)
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
			else
				if !$("#txtBlogAddress").val().match(url_regex)
					event.preventDefault()
					$(this).parent().parent().parent().append('<div class="alert alert-error fade in"><a href="#" class="close" data-dismiss="alert">&times;</a>Please make sure your URL is valid, and starts with http:// or https://</div>')
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
			else
				if !$("#txtYelpAddress").val().match(url_regex)
					event.preventDefault()
					$(this).parent().parent().parent().append('<div class="alert alert-error fade in"><a href="#" class="close" data-dismiss="alert">&times;</a>Please make sure your URL is valid, and starts with http:// or https://</div>')
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