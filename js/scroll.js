$(document).ready(function() {
    $("a[href^=\"#\"]").click(function(event) {
        event.preventDefault();
        var $dest;
        var target = $(this).attr("href").substring(1);
        if (target == "")
            $dest = $("body");
        else
            $dest = $("#" + target);
        console.log($dest);
        $("html, body").animate({
            scrollTop: $dest.offset().top - 50 // 50 for navbar
        }, 1000);
    });
});
