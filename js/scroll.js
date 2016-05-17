$(document).ready(function() {
    $("a[href^=\"#\"]").click(function(event) {
        event.preventDefault();
        $("html, body").animate({
            scrollTop: $($(this).attr("href")).offset().top - 50 // 50 for the navbar
        }, 1000);
    });
});
