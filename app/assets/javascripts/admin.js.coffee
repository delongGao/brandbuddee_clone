# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
	$("#task_blog_post_0").click ->
		if $(this).attr("checked")=="checked"
			$("#lblEnableTask1").removeClass "muted"
			$("#task_blog_post_1").removeAttr("disabled").parent().slideDown()
			$("#task_blog_post_2").removeAttr("disabled").parent().slideDown()
			$("#task_blog_post_3").removeAttr("disabled").parent().slideDown()
		else
			$("#lblEnableTask1").addClass "muted"
			$("#task_blog_post_1").attr("disabled", "disabled").parent().slideUp()
			$("#task_blog_post_2").attr("disabled", "disabled").parent().slideUp()
			$("#task_blog_post_3").attr("disabled", "disabled").parent().slideUp()
	$("#task_yelp_0").click ->
		if $(this).attr("checked")=="checked"
			$("#lblEnableTask9").removeClass "muted"
			$("#task_yelp_1").removeAttr("disabled").parent().slideDown()
			$("#task_yelp_2").removeAttr("disabled").parent().slideDown()
			$("#task_yelp_3").removeAttr("disabled").parent().slideDown()
		else
			$("#lblEnableTask9").addClass "muted"
			$("#task_yelp_1").attr("disabled", "disabled").parent().slideUp()
			$("#task_yelp_2").attr("disabled", "disabled").parent().slideUp()
			$("#task_yelp_3").attr("disabled", "disabled").parent().slideUp()
	$("#task_facebook_0").click ->
		if $(this).attr("checked")=="checked"
			$("#lblEnableTask2").removeClass "muted"
			$("#task_facebook_1").removeAttr("disabled").parent().slideDown()
			$("#task_facebook_2").removeAttr("disabled").parent().slideDown()
			$("#task_facebook_3").removeAttr("disabled").parent().slideDown()
			$("#task_facebook_4").removeAttr("disabled").parent().slideDown()
			$("#chkEngageLeftFacebook").parent().parent().parent().parent().slideDown()
		else
			$("#lblEnableTask2").addClass "muted"
			$("#task_facebook_1").attr("disabled", "disabled").parent().slideUp()
			$("#task_facebook_2").attr("disabled", "disabled").parent().slideUp()
			$("#task_facebook_3").attr("disabled", "disabled").parent().slideUp()
			$("#task_facebook_4").attr("disabled", "disabled").parent().slideUp()
			$("#chkEngageLeftFacebook").parent().parent().parent().parent().slideUp()
	$("#task_twitter_0").click ->
		if $(this).attr("checked")=="checked"
			$("#lblEnableTask3").removeClass "muted"
			$("#task_twitter_1").removeAttr("disabled").parent().slideDown()
			$("#task_twitter_2").removeAttr("disabled").parent().slideDown()
			$("#task_twitter_3").removeAttr("disabled").parent().slideDown()
			$("#task_twitter_4").removeAttr("disabled").parent().slideDown()
			$("#chkEngageLeftTwitter").parent().parent().parent().parent().slideDown()
		else
			$("#lblEnableTask3").addClass "muted"
			$("#task_twitter_1").attr("disabled", "disabled").parent().slideUp()
			$("#task_twitter_2").attr("disabled", "disabled").parent().slideUp()
			$("#task_twitter_3").attr("disabled", "disabled").parent().slideUp()
			$("#task_twitter_4").attr("disabled", "disabled").parent().slideUp()
			$("#chkEngageLeftTwitter").parent().parent().parent().parent().slideUp()
	$("#task_email_subscription_0").click ->
		if $(this).attr("checked")=="checked"
			$("#lblEnableTask10").removeClass "muted"
			$("#task_email_subscription_1").removeAttr("disabled").parent().slideDown()
			$("#task_email_subscription_2").removeAttr("disabled").parent().slideDown()
			$("#task_email_subscription_3").removeAttr("disabled").parent().slideDown()
		else
			$("#lblEnableTask10").addClass "muted"
			$("#task_email_subscription_1").attr("disabled", "disabled").parent().slideUp()
			$("#task_email_subscription_2").attr("disabled", "disabled").parent().slideUp()
			$("#task_email_subscription_3").attr("disabled", "disabled").parent().slideUp()
	$("#task_custom_1_0").click ->
		if $(this).attr("checked")=="checked"
			$("#lblEnableTask4").removeClass "muted"
			$("#task_custom_1_1").removeAttr("disabled").parent().slideDown()
			$("#task_custom_1_2").removeAttr("disabled").parent().slideDown()
			$("#task_custom_1_3").removeAttr("disabled").parent().slideDown()
			$("#task_custom_1_4").removeAttr("disabled").parent().slideDown()
			$("#chkEngageLeftCustom1").parent().parent().parent().parent().slideDown()
		else
			$("#lblEnableTask4").addClass "muted"
			$("#task_custom_1_1").attr("disabled", "disabled").parent().slideUp()
			$("#task_custom_1_2").attr("disabled", "disabled").parent().slideUp()
			$("#task_custom_1_3").attr("disabled", "disabled").parent().slideUp()
			$("#task_custom_1_4").attr("disabled", "disabled").parent().slideUp()
			$("#chkEngageLeftCustom1").parent().parent().parent().parent().slideUp()
	$("#task_custom_2_0").click ->
		if $(this).attr("checked")=="checked"
			$("#lblEnableTask5").removeClass "muted"
			$("#task_custom_2_1").removeAttr("disabled").parent().slideDown()
			$("#task_custom_2_2").removeAttr("disabled").parent().slideDown()
			$("#task_custom_2_3").removeAttr("disabled").parent().slideDown()
			$("#task_custom_2_4").removeAttr("disabled").parent().slideDown()
			$("#chkEngageLeftCustom2").parent().parent().parent().parent().slideDown()
		else
			$("#lblEnableTask5").addClass "muted"
			$("#task_custom_2_1").attr("disabled", "disabled").parent().slideUp()
			$("#task_custom_2_2").attr("disabled", "disabled").parent().slideUp()
			$("#task_custom_2_3").attr("disabled", "disabled").parent().slideUp()
			$("#task_custom_2_4").attr("disabled", "disabled").parent().slideUp()
			$("#chkEngageLeftCustom2").parent().parent().parent().parent().slideUp()
	$("#task_custom_3_0").click ->
		if $(this).attr("checked")=="checked"
			$("#lblEnableTask6").removeClass "muted"
			$("#task_custom_3_1").removeAttr("disabled").parent().slideDown()
			$("#task_custom_3_2").removeAttr("disabled").parent().slideDown()
			$("#task_custom_3_3").removeAttr("disabled").parent().slideDown()
			$("#task_custom_3_4").removeAttr("disabled").parent().slideDown()
			$("#chkEngageLeftCustom3").parent().parent().parent().parent().slideDown()
		else
			$("#lblEnableTask6").addClass "muted"
			$("#task_custom_3_1").attr("disabled", "disabled").parent().slideUp()
			$("#task_custom_3_2").attr("disabled", "disabled").parent().slideUp()
			$("#task_custom_3_3").attr("disabled", "disabled").parent().slideUp()
			$("#task_custom_3_4").attr("disabled", "disabled").parent().slideUp()
			$("#chkEngageLeftCustom3").parent().parent().parent().parent().slideUp()
	$("#task_custom_4_0").click ->
		if $(this).attr("checked")=="checked"
			$("#lblEnableTask7").removeClass "muted"
			$("#task_custom_4_1").removeAttr("disabled").parent().slideDown()
			$("#task_custom_4_2").removeAttr("disabled").parent().slideDown()
			$("#task_custom_4_3").removeAttr("disabled").parent().slideDown()
			$("#task_custom_4_4").removeAttr("disabled").parent().slideDown()
			$("#chkEngageLeftCustom4").parent().parent().parent().parent().slideDown()
		else
			$("#lblEnableTask7").addClass "muted"
			$("#task_custom_4_1").attr("disabled", "disabled").parent().slideUp()
			$("#task_custom_4_2").attr("disabled", "disabled").parent().slideUp()
			$("#task_custom_4_3").attr("disabled", "disabled").parent().slideUp()
			$("#task_custom_4_4").attr("disabled", "disabled").parent().slideUp()
			$("#chkEngageLeftCustom4").parent().parent().parent().parent().slideUp()
	$("#task_custom_5_0").click ->
		if $(this).attr("checked")=="checked"
			$("#lblEnableTask8").removeClass "muted"
			$("#task_custom_5_1").removeAttr("disabled").parent().slideDown()
			$("#task_custom_5_2").removeAttr("disabled").parent().slideDown()
			$("#task_custom_5_3").removeAttr("disabled").parent().slideDown()
			$("#task_custom_5_4").removeAttr("disabled").parent().slideDown()
			$("#chkEngageLeftCustom5").parent().parent().parent().parent().slideDown()
		else
			$("#lblEnableTask8").addClass "muted"
			$("#task_custom_5_1").attr("disabled", "disabled").parent().slideUp()
			$("#task_custom_5_2").attr("disabled", "disabled").parent().slideUp()
			$("#task_custom_5_3").attr("disabled", "disabled").parent().slideUp()
			$("#task_custom_5_4").attr("disabled", "disabled").parent().slideUp()
			$("#chkEngageLeftCustom5").parent().parent().parent().parent().slideUp()
	# $("#lblEngageLeftBlog").click ->
		# num = $(".chkTrackLeft:checked").length
	$("#campaign_gift_image").change ->
		$("#campaign_gift_image_two").parent().parent().slideDown()
	$("#campaign_gift_image_two").change ->
		$("#campaign_gift_image_three").parent().parent().slideDown()
	$("#chkBlogPost").click ->
		if $(this).attr("checked")=="checked"
			$("#task_blog_post_1").removeAttr("disabled")
			$("#task_blog_post_2").removeAttr("disabled")
			$("#task_blog_post_3").removeAttr("disabled")
		else
			$("#task_blog_post_1").attr("disabled", "disabled")
			$("#task_blog_post_2").attr("disabled", "disabled")
			$("#task_blog_post_3").attr("disabled", "disabled")
	$("#chkYelpReview").click ->
		if $(this).attr("checked")=="checked"
			$("#task_yelp_1").removeAttr("disabled")
			$("#task_yelp_2").removeAttr("disabled")
			$("#task_yelp_3").removeAttr("disabled")
		else
			$("#task_yelp_1").attr("disabled", "disabled")
			$("#task_yelp_2").attr("disabled", "disabled")
			$("#task_yelp_3").attr("disabled", "disabled")
	$("#chkFacebook").click ->
		if $(this).attr("checked")=="checked"
			$("#task_facebook_1").removeAttr("disabled")
			$("#task_facebook_2").removeAttr("disabled")
			$("#task_facebook_3").removeAttr("disabled")
			$("#task_facebook_4").removeAttr("disabled")
		else
			$("#task_facebook_1").attr("disabled", "disabled")
			$("#task_facebook_2").attr("disabled", "disabled")
			$("#task_facebook_3").attr("disabled", "disabled")
			$("#task_facebook_4").attr("disabled", "disabled")
			$("#chkFacebookEngageLeft").prop("checked", false).parent().removeClass("checked")
			$("#chkFacebookEngageRight").prop("checked", false).parent().removeClass("checked")
	$("#chkTwitter").click ->
		if $(this).attr("checked")=="checked"
			$("#task_twitter_1").removeAttr("disabled")
			$("#task_twitter_2").removeAttr("disabled")
			$("#task_twitter_3").removeAttr("disabled")
			$("#task_twitter_4").removeAttr("disabled")
		else
			$("#task_twitter_1").attr("disabled", "disabled")
			$("#task_twitter_2").attr("disabled", "disabled")
			$("#task_twitter_3").attr("disabled", "disabled")
			$("#task_twitter_4").attr("disabled", "disabled")
			$("#chkTwitterEngageLeft").prop("checked", false).parent().removeClass("checked")
			$("#chkTwitterEngageRight").prop("checked", false).parent().removeClass("checked")
	$("#chkEmailSubscription").click ->
		if $(this).attr("checked")=="checked"
			$("#task_email_subscription_1").removeAttr("disabled")
			$("#task_email_subscription_2").removeAttr("disabled")
			$("#task_email_subscription_3").removeAttr("disabled")
		else
			$("#task_email_subscription_1").attr("disabled", "disabled")
			$("#task_email_subscription_2").attr("disabled", "disabled")
			$("#task_email_subscription_3").attr("disabled", "disabled")
	$("#chkCustom1").click ->
		if $(this).attr("checked")=="checked"
			$("#task_custom_1_1").removeAttr("disabled")
			$("#task_custom_1_2").removeAttr("disabled")
			$("#task_custom_1_3").removeAttr("disabled")
			$("#task_custom_1_4").removeAttr("disabled")
		else
			$("#task_custom_1_1").attr("disabled", "disabled")
			$("#task_custom_1_2").attr("disabled", "disabled")
			$("#task_custom_1_3").attr("disabled", "disabled")
			$("#task_custom_1_4").attr("disabled", "disabled")
			$("#chkCustom1EngageLeft").prop("checked", false).parent().removeClass("checked")
			$("#chkCustom1EngageRight").prop("checked", false).parent().removeClass("checked")
	$("#chkCustom2").click ->
		if $(this).attr("checked")=="checked"
			$("#task_custom_2_1").removeAttr("disabled")
			$("#task_custom_2_2").removeAttr("disabled")
			$("#task_custom_2_3").removeAttr("disabled")
			$("#task_custom_2_4").removeAttr("disabled")
		else
			$("#task_custom_2_1").attr("disabled", "disabled")
			$("#task_custom_2_2").attr("disabled", "disabled")
			$("#task_custom_2_3").attr("disabled", "disabled")
			$("#task_custom_2_4").attr("disabled", "disabled")
			$("#chkCustom2EngageLeft").prop("checked", false).parent().removeClass("checked")
			$("#chkCustom2EngageRight").prop("checked", false).parent().removeClass("checked")
	$("#chkCustom3").click ->
		if $(this).attr("checked")=="checked"
			$("#task_custom_3_1").removeAttr("disabled")
			$("#task_custom_3_2").removeAttr("disabled")
			$("#task_custom_3_3").removeAttr("disabled")
			$("#task_custom_3_4").removeAttr("disabled")
		else
			$("#task_custom_3_1").attr("disabled", "disabled")
			$("#task_custom_3_2").attr("disabled", "disabled")
			$("#task_custom_3_3").attr("disabled", "disabled")
			$("#task_custom_3_4").attr("disabled", "disabled")
			$("#chkCustom3EngageLeft").prop("checked", false).parent().removeClass("checked")
			$("#chkCustom3EngageRight").prop("checked", false).parent().removeClass("checked")
	$("#chkCustom4").click ->
		if $(this).attr("checked")=="checked"
			$("#task_custom_4_1").removeAttr("disabled")
			$("#task_custom_4_2").removeAttr("disabled")
			$("#task_custom_4_3").removeAttr("disabled")
			$("#task_custom_4_4").removeAttr("disabled")
		else
			$("#task_custom_4_1").attr("disabled", "disabled")
			$("#task_custom_4_2").attr("disabled", "disabled")
			$("#task_custom_4_3").attr("disabled", "disabled")
			$("#task_custom_4_4").attr("disabled", "disabled")
			$("#chkCustom4EngageLeft").prop("checked", false).parent().removeClass("checked")
			$("#chkCustom4EngageRight").prop("checked", false).parent().removeClass("checked")
	$("#chkCustom5").click ->
		if $(this).attr("checked")=="checked"
			$("#task_custom_5_1").removeAttr("disabled")
			$("#task_custom_5_2").removeAttr("disabled")
			$("#task_custom_5_3").removeAttr("disabled")
			$("#task_custom_5_4").removeAttr("disabled")
		else
			$("#task_custom_5_1").attr("disabled", "disabled")
			$("#task_custom_5_2").attr("disabled", "disabled")
			$("#task_custom_5_3").attr("disabled", "disabled")
			$("#task_custom_5_4").attr("disabled", "disabled")
			$("#chkCustom5EngageLeft").prop("checked", false).parent().removeClass("checked")
			$("#chkCustom5EngageRight").prop("checked", false).parent().removeClass("checked")
	if $('#cropbox').length
		new AvatarCropper()

class AvatarCropper
	constructor: ->
		$('#cropbox').Jcrop
			aspectRatio: 1.444444444
			setSelect: [0, 0, 600, 600]
			onSelect: @update
			onChange: @update

	update: (coords) =>
		$('#campaign_crop_x').val(coords.x)
		$('#campaign_crop_y').val(coords.y)
		$('#campaign_crop_w').val(coords.w)
		$('#campaign_crop_h').val(coords.h)
		@updatePreview(coords)

	updatePreview: (coords) =>
		$('#preview').css
			width: Math.round(260/coords.w * $('#cropbox').width()) + 'px'
			height: Math.round(180/coords.h * $('#cropbox').height()) + 'px'
			marginLeft: '-' + Math.round(260/coords.w * coords.x) + 'px'
			marginTop: '-' + Math.round(180/coords.h * coords.y) + 'px'