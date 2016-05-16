$(document).ready(function() {
    $("a[href^=\"#\"]").click(function(event) {
        event.preventDefault();
        $("html, body").animate({
            scrollTop: $(".page").next().offset().top
        }, 1000);
    });
});
