/*-----------------------------------------------------------------------------------*/
/*	Start Custom jQuery
/*-----------------------------------------------------------------------------------*/

// Start slider on load not ready

$(window).load(function(){
	
	$('.flexslider').flexslider({
		slideshow: true,            //Boolean: Animate slider automatically
		slideshowSpeed: 7000,       //Integer: Set the speed of the slideshow cycling, in milliseconds
		animationSpeed: 600,        //Integer: Set the speed of animations, in milliseconds
		keyboard: true,                 //Boolean: Allow slider navigating via keyboard left/right keys
		useCSS: true,               //{NEW} Boolean: Slider will use CSS3 transitions if available
		touch: true,                //{NEW} Boolean: Allow touch swipe navigation of the slider on touch-enabled devices
		video: false,               //{NEW} Boolean: If using video in the slider, will prevent CSS3 3D Transforms to avoid graphical glitches
	});
	
});

/*-----------------------------------------------------------------------------------*/
/*	Once Page Loaded
/*-----------------------------------------------------------------------------------*/

$(document).ready(function(){
	
	setupFeedback(5); // Change 5 to number of seconds between feedback / quotes
			
/*-----------------------------------------------------------------------------------*/
/*	Responsive Video Setup
/*-----------------------------------------------------------------------------------*/

	if( jQuery().fitVids ){
		$(".flex-video").fitVids();
	}

/*-----------------------------------------------------------------------------------*/
/*	Start Lightbox
/*-----------------------------------------------------------------------------------*/

	if(window.innerWidth > 500 && window.innerHeight > 500){
		$(".various").fancybox({
			padding:0,
			openEffect:'elastic',
			closeEffect:'elastic',
			fitToView:true,
			width:560,
			height:315
		});
	}	
	
/*-----------------------------------------------------------------------------------*/
/*	Top Scroll
/*-----------------------------------------------------------------------------------*/

	$('a[href=#top]').click(function(e){
		
		e.stopPropagation();
		e.preventDefault();
		e.stopImmediatePropagation();
		$('html, body').animate({scrollTop:0}, 'slow');
        return false;
		
	});

/*-----------------------------------------------------------------------------------*/
/*	Fade Effects
/*-----------------------------------------------------------------------------------*/

	$('.social img').hover(function(){
		
		$(this).stop().animate( {"opacity": "0"}, 400);
		
	}, function(){
		
		$(this).stop().animate( {"opacity": "1"}, 400);

	});

	$('#store-button img').hover(function(){
		
		$(this).stop().animate( {"opacity": "0"}, 400);
		
	}, function(){
		
		$(this).stop().animate( {"opacity": "1"}, 400);

	});
	
/*-----------------------------------------------------------------------------------*/
/*	Thats all folks!
/*-----------------------------------------------------------------------------------*/

});

/*-----------------------------------------------------------------------------------*/
/*	Plugins
/*-----------------------------------------------------------------------------------*/

/*
	function setupFeedback(seconds){
		var speed = seconds * 1000;
		if( $('div.feedback div').length > 1 ){
			$('div.feedback div:first').addClass('current').fadeIn(1000);
			 setInterval('feedbackator()', speed);
		}
	}
	
	function feedbackator(){
					
		var current = $('div.feedback > .current');
		if(current.next().length == 0){
			current.removeClass('current').fadeOut('slow', function(){
				$('div.feedback div:first').addClass('current').fadeIn('slow');
			});
		} else {
			current.removeClass('current').fadeOut('slow', function(){
				current.next().addClass('current').fadeIn('slow');	
			});
		}
				
	}
*/

// Feedback Cycle
function setupFeedback(a){a*=1E3;1<$("div.feedback div").length&&($("div.feedback div:first").addClass("current").fadeIn(1E3),setInterval("feedbackator()",a))}function feedbackator(){var a=$("div.feedback > .current");0==a.next().length?a.removeClass("current").fadeOut("slow",function(){$("div.feedback div:first").addClass("current").fadeIn("slow")}):a.removeClass("current").fadeOut("slow",function(){a.next().addClass("current").fadeIn("slow")})};

// jQuery.ScrollTo 1.4.2
;(function(d){var k=d.scrollTo=function(a,i,e){d(window).scrollTo(a,i,e)};k.defaults={axis:'xy',duration:parseFloat(d.fn.jquery)>=1.3?0:1};k.window=function(a){return d(window)._scrollable()};d.fn._scrollable=function(){return this.map(function(){var a=this,i=!a.nodeName||d.inArray(a.nodeName.toLowerCase(),['iframe','#document','html','body'])!=-1;if(!i)return a;var e=(a.contentWindow||a).document||a.ownerDocument||a;return d.browser.safari||e.compatMode=='BackCompat'?e.body:e.documentElement})};d.fn.scrollTo=function(n,j,b){if(typeof j=='object'){b=j;j=0}if(typeof b=='function')b={onAfter:b};if(n=='max')n=9e9;b=d.extend({},k.defaults,b);j=j||b.speed||b.duration;b.queue=b.queue&&b.axis.length>1;if(b.queue)j/=2;b.offset=p(b.offset);b.over=p(b.over);return this._scrollable().each(function(){var q=this,r=d(q),f=n,s,g={},u=r.is('html,body');switch(typeof f){case'number':case'string':if(/^([+-]=)?\d+(\.\d+)?(px|%)?$/.test(f)){f=p(f);break}f=d(f,this);case'object':if(f.is||f.style)s=(f=d(f)).offset()}d.each(b.axis.split(''),function(a,i){var e=i=='x'?'Left':'Top',h=e.toLowerCase(),c='scroll'+e,l=q[c],m=k.max(q,i);if(s){g[c]=s[h]+(u?0:l-r.offset()[h]);if(b.margin){g[c]-=parseInt(f.css('margin'+e))||0;g[c]-=parseInt(f.css('border'+e+'Width'))||0}g[c]+=b.offset[h]||0;if(b.over[h])g[c]+=f[i=='x'?'width':'height']()*b.over[h]}else{var o=f[h];g[c]=o.slice&&o.slice(-1)=='%'?parseFloat(o)/100*m:o}if(/^\d+$/.test(g[c]))g[c]=g[c]<=0?0:Math.min(g[c],m);if(!a&&b.queue){if(l!=g[c])t(b.onAfterFirst);delete g[c]}});t(b.onAfter);function t(a){r.animate(g,j,b.easing,a&&function(){a.call(this,n,b)})}}).end()};k.max=function(a,i){var e=i=='x'?'Width':'Height',h='scroll'+e;if(!d(a).is('html,body'))return a[h]-d(a)[e.toLowerCase()]();var c='client'+e,l=a.ownerDocument.documentElement,m=a.ownerDocument.body;return Math.max(l[h],m[h])-Math.min(l[c],m[c])};function p(a){return typeof a=='object'?a:{top:a,left:a}}})(jQuery);