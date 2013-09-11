window.fbAsyncInit = function() {
  // init the FB JS SDK
  FB.init({
    appId      : '278238152312772', // App ID from the App Dashboard
    channelUrl : '/fbapp/channel.html', // Channel File for x-domain communication
    status     : true, // check the login status upon init?
    cookie     : true, // set sessions cookies to allow your server to access the session?
    frictionlessRequests : true, // enable frictionless requests
    xfbml      : true  // parse XFBML tags on this page?
  }); // FB.init()
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

function fbInvitePerson(sendto, name) {
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
      $('#insertbeforeme').before('<div class="alert alert-success fade in" style="margin-top:2%; width:82%; margin-left:2%;"><button type="button" class="close" data-dismiss="alert">&times;</button><strong>Success!</strong> ' + name + ' has been invited.</div>');
    } else {
      // This code gets called if the user cancels the dialog before sending the message.
    } //Response from send attempt
  }); // Call to FB.ui
} // End fbInvitePerson()

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