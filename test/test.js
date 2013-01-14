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

})

