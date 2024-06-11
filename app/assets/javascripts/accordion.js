// TO DO: Remove console.log statements

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


    //initial check on load for existing works
    var p = document.getElementById("publication_content_genre");
    if (p != null) {

        //fields
        var parTitle = document.getElementsByClassName("form-group string optional publication_parent_title");
        var confName = document.getElementsByClassName("form-group string optional publication_conference_name");
        var isbn = document.getElementsByClassName("form-group string optional publication_isbn");
        var series = document.getElementsByClassName("form-group string optional publication_series_title");
        var edition = document.getElementsByClassName("form-group string optional publication_edition");
        var issn = document.getElementsByClassName("form-group string optional publication_issn");
        var volume = document.getElementsByClassName("form-group string optional publication_volume");
        var issue = document.getElementsByClassName("form-group string optional publication_issue");
        var pageStart = document.getElementsByClassName("form-group string optional publication_page_range_start");
        var pageEnd = document.getElementsByClassName("form-group string optional publication_page_range_end");

        //labels (for required badged)
        var pubVersionLabel = document.getElementsByClassName("form-group select optional publication_publisher_version")[0].firstChild;
        var parTitleLabel = document.getElementsByClassName("form-group string optional publication_parent_title")[0].firstChild;

        formSetup();

        //get select element and watch if it changes
        p.addEventListener("change", function () {
            formSetup();
        });

        function formSetup() {
            var selectedValue = p.selectedOptions[0].label;
            switch (selectedValue) {
                case 'Article': {
                    resetForm();
                    console.log("Chose: Article");
                    confName[0].style.display = "none";
                    isbn[0].style.display = "none";
                    series[0].style.display = "none";
                    edition[0].style.display = "none";
                    pubVersionLabel.insertAdjacentHTML("afterend", '&nbsp;<span id="pubform-pubver" class="badge badge-info required-tag">required</span>');
                    parTitleLabel.insertAdjacentHTML("afterend", '&nbsp;<span id="pubform-partitle" class="badge badge-info required-tag">required</span>');
                    break;
                }

                case 'Book': {
                    resetForm();
                    console.log("Chose: Book");
                    parTitle[0].style.display = "none";
                    confName[0].style.display = "none";
                    issn[0].style.display = "none";
                    volume[0].style.display = "none";
                    issue[0].style.display = "none";
                    pageStart[0].style.display = "none";
                    pageEnd[0].style.display = "none";
                    pubVersionLabel.insertAdjacentHTML("afterend", '&nbsp;<span id="pubform-pubver" class="badge badge-info required-tag">required</span>');

                    break;
                }

                case 'Book Chapter': {
                    resetForm();
                    console.log('Selected: Book Chapter');

                    confName[0].style.display = "none";
                    issn[0].style.display = "none";
                    volume[0].style.display = "none";
                    issue[0].style.display = "none";
                    pubVersionLabel.insertAdjacentHTML("afterend", '&nbsp;<span id="pubform-pubver" class="badge badge-info required-tag">required</span>');
                    parTitleLabel.insertAdjacentHTML("afterend", '&nbsp;<span id="pubform-partitle" class="badge badge-info required-tag">required</span>');

                    break;
                }

                case 'Conference Paper': {
                    resetForm();
                    console.log('Selected: Conference Paper');
                    break;
                }

                case 'Poster': {
                    resetForm();
                    console.log('Selected: Poster');
                    break;

                }

                case 'Presentation': {
                    resetForm();
                    console.log('Selected: Presentation');
                    break;
                }

                case 'Report': {
                    resetForm();
                    console.log('Selected: Report');
                    break;
                }

                case ' ': {
                    resetForm();
                    console.log('none selected');
                    break;
                }
                default: {
                    resetForm();
                    console.log('default selected');
                    break;
                }

            }
        }


        function resetForm() {
            console.log('RESET FORM!');
            parTitle[0].style.display = "block";
            confName[0].style.display = "block";
            isbn[0].style.display = "block";
            series[0].style.display = "block";
            edition[0].style.display = "block";
            issn[0].style.display = "block";
            volume[0].style.display = "block";
            issue[0].style.display = "block";
            pageStart[0].style.display = "block";
            pageEnd[0].style.display = "block";
            var pubformPubver = document.getElementById("pubform-pubver");
            if (pubformPubver) { pubformPubver.remove(); }
            var pubformPubTitle = document.getElementById("pubform-partitle");
            if (pubformPubTitle) { pubformPubTitle.remove(); }
        }
    }
});


function validateForm() {
    var validationValue = document.getElementById("publication_content_genre").selectedOptions[0].label;
    var pubverValue = document.getElementById("publication_publisher_version").selectedOptions[0].label;
    var parTitleValue = document.getElementById("publication_parent_title").value;

    var publisherVersion = "Publisher Version";
    var parentTitle = "Parent Title";

    // console.log("validating " + validationValue);

    switch (validationValue) {

        case 'Article':
        case 'Book Chapter': {

            console.log('Validating: Article/Book Chapter');
            if (pubverValue == ' ') {
                validateModal(publisherVersion);
                return false;
            }
            if (!parTitleValue) {
                validateModal(parentTitle);
                return false;
            }

            if (pubverValue != ' ' && parTitleValue) {
                removeModal();
                console.log("article/book title filled out correctly");
                return true;
            }

            alert("Please contact LTDS");
            break;
        }

        case 'Book': {

            console.log('Validating: Book');
            if (pubverValue == ' ') {
                var publisherVersion = "Publisher Version";
                validateModal(publisherVersion);
                return false;
            }

            if (pubverValue) {
                removeModal();
                console.log("book filled out correctly");
                return true;
            }

            alert("Please contact LTDS");
            break;
        }

        case 'Conference Paper': {
            console.log('Validating: Conference Paper');
            removeModal();
            break;
        }

        case 'Poster': {
            console.log('Validating: Conference Paper');
            removeModal();
            break;
        }

        case 'Presentation': {
            console.log('Validating: Presentation');
            removeModal();
            break;
        }

        case 'Report': {
            console.log('Selected: Report');
            removeModal();
            break;
        }

        case ' ': {
            console.log('Selected: Report');
            removeModal();
            break;
        }

        default: {
            resetForm();
            console.log('validate default');
            break;
        }
    }
}

function validateModal(x) {
    // console.log("var x is typeof: " + typeof (x) + " var x value: " + x);

    var modal = document.getElementById("publication_content_genre");
    var text = '<div class="modal pubform" id="pubvalidatemodal"><div class="modal-dialog mo,dal-dialog-centered"><div class=modal-content><div class=modal-header><h4 class=modal-title>Missing Entries</h4><button class=close data-dismiss=modal type=button>×</button></div><div class=modal-body>' + x + ' is required.<br>Located under Publication Information.</div><div class=modal-footer><button class="btn btn-danger"data-dismiss=modal type=button>Close</button></div></div></div></div>';
    modal.insertAdjacentHTML("afterend", text);
    return false;

}

function removeModal() {
    console.log("modal remove");
    $(".modal.pubform").remove();
}
