window.fbAsyncInit = function() {
  // init the FB JS SDK
  FB.init({
    appId      : '404234572989713', // App ID from the App Dashboard
    channelUrl : '//www.applecrateseo.com/bb-invite-app/channel.html', // Channel File for x-domain communication
    status     : true, // check the login status upon init?
    cookie     : true, // set sessions cookies to allow your server to access the session?
    frictionlessRequests : true, // enable frictionless requests
    xfbml      : true  // parse XFBML tags on this page?
  }); // FB.init()
  
  // Additional initialization code such as adding an event listener goes here
  
  // Next, find out if the user is logged in:
  FB.getLoginStatus(function(response) {
  	if (response.status === 'connected') {
  		var uid = response.authResponse.userID;
  		var accessToken = response.authResponse.accessToken;
  		FB.api('/me', function(info) {
  			//console.log(info);
  			// $('#welcome').html("Hello " + info.first_name + ", welcome to brandbuddee invite app");
  		});
  	} else if (response.status === 'not_authorized') {
  		// the user is logged in to Facebook, but has not authenticated your app
  		var oauth_url = 'https://www.facebook.com/dialog/oauth/';
  		oauth_url += '?client_id=404234572989713'; // Your client id
  		oauth_url += '&redirect_uri=' + 'http://brandbuddee.com/'; // Send them here if they're not logged in
  		oauth_url += '&scope=user_about_me,email,user_location,user_photos,publish_actions,user_birthday,user_likes,read_friendlists';
  		//window.top.location = oauth_url;
  	} else {
  		// the user isn't logged in to Facebook.
  		//window.top.location = 'https://www.facebook.com/index.php';
  	} // End else
  }); // getLoginStatus
}; // fbAsyncInit

function invitePerson(sendto, name) {
	FB.ui({
		'method': 'send',
		'to': sendto,
		'link': 'http://brandbuddee.com/',
		//'picture': 'http://brandbuddee.com/assets/brandbuddee-logo-3b7c5781760de7cc02c093991efd0bfd.png',
		'name': 'Check out brandbuddee.com!',
		'caption': 'brandbuddee.com',
		'description': name + ', check out brandbuddee.com! You can discover cool things in your city, score points for sharing, and earn rewards.'
	}, function(response) {
		if (response) {
      $('#insertbeforeme').before('<div class="row" style="margin-top:2%;"><div class="alert alert-success fade in"><button type="button" class="close" data-dismiss="alert">&times;</button><strong>Success!</strong> ' + name + ' has been invited.</div></div>');
		} else {
      // This code gets called if the user cancels the dialog before sending the message.
		} //Response from send attempt
	}); // Call to FB.ui
} // End invitePerson()

function requestCallback(response) {
  // Handle callback here
}

// Load the SDK's source Asynchronously
// Note that the debug version is being actively developed and might
// contain some type checks that are overly strict. 
// Please report such bugs using the bugs tool.
(function(d, debug){
	var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
	if (d.getElementById(id)) {return;}
	js = d.createElement('script'); js.id = id; js.async = true;
	js.src = "//connect.facebook.net/en_US/all" + (debug ? "/debug" : "") + ".js";
	ref.parentNode.insertBefore(js, ref);
}(document, /*debug*/ false));