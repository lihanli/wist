// for (var i = 0; i < 5; i++) {
// 	$('<button>foo</button>').attr('id', 'button' + i).prependTo($('body'));
// }

$('#click_test').click(function() {
	$(this).text('clicked');
});

$('#wait_test').click(function() {
	$this = $(this);

	setTimeout(function(){
		$this.text('clicked');
	}, 1000);
});

$('#enable_tweet_button').click(function() {
	!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="http://platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");
});
