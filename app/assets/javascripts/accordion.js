// wait for page to load (ruby seems to act weird if we don't)
document.addEventListener('DOMContentLoaded', function (event) {

    // get accordion elements
    var x = document.getElementsByClassName("pub-form-header");

    for (i = 0; i < x.length; i++) {
        x[i].addEventListener("click", function () {
            var child = this.nextElementSibling;
            if (child.className == "card-body open") {
                child.className = "card-body"
            } else {
                child.className = "card-body open"
            }
        })
    }

    //article fields
    var confName = document.getElementsByClassName("form-group string optional publication_conference_name");
    var isbn = document.getElementsByClassName("form-group string optional publication_isbn");
    var series = document.getElementsByClassName("form-group string optional publication_series_title");
    var edition = document.getElementsByClassName("form-group string optional publication_edition");
    var publisherVersion = document.getElementsByClassName("form-group select optional publication_publisher_version")[0].firstChild;
    var parTitle = document.getElementsByClassName("form-group string optional publication_parent_title")[0].firstChild;
    console.log(parTitle);

    //initial check on load for existing works
    var p = document.getElementById("publication_content_genre");
    if (p != null) {
        var selectedValue = p.selectedOptions[0].label;
        switch (selectedValue) {
            case 'Article':
                resetForm();
                console.log("Chose: Article");
                confName[0].style.display = "none";
                isbn[0].style.display = "none";
                series[0].style.display = "none";
                edition[0].style.display = "none";
                publisherVersion.insertAdjacentHTML("afterend", '&nbsp;<span id="pubform-pubver" class="badge badge-info required-tag">required</span>');
                parTitle.insertAdjacentHTML("afterend", '&nbsp;<span id="pubform-partitle" class="badge badge-info required-tag">required</span>');

                // validateForm();

                break;

            case 'Book':
                resetForm();
                console.log("Chose: Book");
                break;

            case 'Book Chapter':
                resetForm();
                console.log('Selected: Book Chapter');
                break;

            case 'Conference Paper':
                resetForm();
                console.log('Selected: Conference Paper');
                break;

            case 'Poster':
                resetForm();
                console.log('Selected: Poster');
                break;

            case 'Presentation':
                resetForm();
                console.log('Selected: Presentation');
                break;

            case 'Report':
                resetForm();
                console.log('Selected: Report');
                break;

            case ' ':
                resetForm();
                console.log('none selected');
                break;
        }
    }

    //get select element and watch if it changes
    var e = document.getElementById("publication_content_genre");
    e.addEventListener("change", function () {
        var selectedValue = e.selectedOptions[0].label;

        switch (selectedValue) {
            case 'Article':
                resetForm();
                console.log("Chose: Article");
                confName[0].style.display = "none";
                isbn[0].style.display = "none";
                series[0].style.display = "none";
                edition[0].style.display = "none";
                publisherVersion.insertAdjacentHTML("afterend", '&nbsp;<span id="pubform-pubver" class="badge badge-info required-tag">required</span>');

                // validateForm();

                break;

            case 'Book':
                resetForm();
                console.log("Chose: Book");
                break;

            case 'Book Chapter':
                resetForm();
                console.log('Selected: Book Chapter');
                break;

            case 'Conference Paper':
                resetForm();
                console.log('Selected: Conference Paper');
                break;

            case 'Poster':
                resetForm();
                console.log('Selected: Poster');
                break;

            case 'Presentation':
                resetForm();
                console.log('Selected: Presentation');
                break;

            case 'Report':
                resetForm();
                console.log('Selected: Report');
                break;

            case ' ':
                resetForm();
                console.log('none selected');
                break;
        }

    });


    function resetForm() {
        //reset the form at the beginning every time we switch

        //article reset
        console.log('RESET FORM!');
        confName[0].style.display = "block";
        isbn[0].style.display = "block";
        series[0].style.display = "block";
        edition[0].style.display = "block";
        var pubformPubver = document.getElementById("pubform-pubver");
        if (pubformPubver) { pubformPubver.remove(); }
        var pubformPubTitle = document.getElementById("pubform-partitle");
        if (pubformPubTitle) { pubformPubTitle.remove(); }


    }
});
