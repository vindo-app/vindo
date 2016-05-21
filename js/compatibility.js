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
    if (results != null && results.length == 0)
        $("#no-results").show();
    else
        $("#no-results").hide();
    for (var i = 0; i < results.length && i < 10; i++) {
        $results.append($(results[i].html));
    }
    $(".label").tooltip();
    $("body").scrollspy("refresh");
}

$(document).ready(function() {
    $results = $("#compatibility-results");
    if ($results.length == 0)
        return;
    
    $(".js-only").removeClass("js-only");

    buildDatabase();
    
    $("#search-box").keyup(function(event) {
        if ($(this).val() == "") {
            results = null;
            loadEntries();
            return;
        }
        var fuse = new Fuse(db, {
            keys: ["name", "keywords"]
        });
        results = fuse.search($(this).val());
        console.log(results);
        loadEntries();
    });
    loadEntries();
});
