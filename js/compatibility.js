var db;
var $results;
var $search_box;
var results;

function loadEntries() {
    $results.empty();
    for (var i = 0; i < results.length && i < 10; i++) {
        var entry = results[i];
        var $placeholder = $("<div></div>");
        $results.append($placeholder);
        $placeholder.html(entry.html);
    }
}

$(document).ready(function() {
    $results = $("#compatibility-results");
    if ($results.length == 0)
        return;
    
    $(".js-only").removeClass("js-only");
    
    $.getJSON("/compat.json", function(response) {
        db = response;
        results = db;
        loadEntries();
    });
    
    var $search_box = $("#search-box");
    $search_box.keyup(function(event) {
        var regex = new RegExp($search_box.val(), "i");
        results = db.filter(function(entry) {
            return regex.test(entry.name);
        });
        loadEntries();
    });
});