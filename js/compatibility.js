var db = [];
var $results;
var $search_box;
var results;

function buildDatabase() {
    $(".compatibility-entry").each(function() {
        $entry = $(this);
        db.push({
            "name": $entry.data("name"),
            "keywords": $entry.data("keywords"),
            "html": $entry[0].outerHTML
        });
    });
}

function loadEntries() {
    $results.empty();
    for (var i = 0; i < results.length && i < 10; i++) {
        $results.append($(results[i].html));
    }
}

$(document).ready(function() {
    $results = $("#compatibility-results");
    if ($results.length == 0)
        return;
    
    $(".js-only").removeClass("js-only");

    buildDatabase();
    
    $("#search-box").keyup(function(event) {
        var fuse = new Fuse(db, {
            keys: ["name", "keywords"]
        });
        results = fuse.search($(this).val());
        console.log(results);
        loadEntries();
    });
});
