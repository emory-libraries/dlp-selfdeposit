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

        formSetup();

        //now just watch if select changes
        p.addEventListener("change", function () {
            formSetup();
        });
    }
});

function resetForm() {
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

function formSetup() {
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

    var p = document.getElementById("publication_content_genre");
    var selectedValue = p.selectedOptions[0].label;
    switch (selectedValue) {
        case 'Article': {
            resetForm();
            console.log("Chose: Article");
            confName[0].style.display = "none";
            isbn[0].style.display = "none";
            series[0].style.display = "none";
            edition[0].style.display = "none";
            pubVersionLabel.insertAdjacentHTML("beforeend", '<span id="pubform-pubver" class="badge badge-info required-tag">required</span>');
            parTitleLabel.insertAdjacentHTML("beforeend", '<span id="pubform-partitle" class="badge badge-info required-tag">required</span>');
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
            pubVersionLabel.insertAdjacentHTML("beforeend", '<span id="pubform-pubver" class="badge badge-info required-tag">required</span>');

            break;
        }

        case 'Book Chapter': {
            resetForm();
            console.log('Selected: Book Chapter');

            confName[0].style.display = "none";
            issn[0].style.display = "none";
            volume[0].style.display = "none";
            issue[0].style.display = "none";
            pubVersionLabel.insertAdjacentHTML("beforeend", '<span id="pubform-pubver" class="badge badge-info required-tag">required</span>');
            parTitleLabel.insertAdjacentHTML("beforeend", '<span id="pubform-partitle" class="badge badge-info required-tag">required</span>');

            break;
        }

        case 'Conference Paper': {
            resetForm();
            console.log('Selected: Conference Paper');

            issn[0].style.display = "none";
            isbn[0].style.display = "none";
            series[0].style.display = "none";
            edition[0].style.display = "none";

            pubVersionLabel.insertAdjacentHTML("beforeend", '<span id="pubform-pubver" class="badge badge-info required-tag">required</span>');

            break;
        }

        case 'Poster':
        case 'Presentation': {
            resetForm();
            console.log('Selected: Poster || Presentation');

            issn[0].style.display = "none";
            isbn[0].style.display = "none";
            series[0].style.display = "none";
            edition[0].style.display = "none";
            volume[0].style.display = "none";
            issue[0].style.display = "none";
            pageStart[0].style.display = "none";
            pageEnd[0].style.display = "none";

            break;
        }

        case 'Report': {
            resetForm();
            console.log('Selected: Report');

            confName[0].style.display = "none";
            issn[0].style.display = "none";
            isbn[0].style.display = "none";
            series[0].style.display = "none";
            edition[0].style.display = "none";
            volume[0].style.display = "none";
            issue[0].style.display = "none";
            pageStart[0].style.display = "none";
            pageEnd[0].style.display = "none"

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

function validateForm() {

    var orcidCheck = orcidValidation();
    console.log(orcidCheck);
    if (!orcidCheck) { return false; }

    var relatedDataCheck = relatedDataValidation();
    console.log(relatedDataCheck);
    if (!relatedDataCheck) { return false; }

    var finalPubVerCheck = finalPubVerValidation();
    console.log(finalPubVerCheck);
    if (!finalPubVerCheck) { return false; }

    var dateIssuedCheck = dateIssuedValidation();
    console.log(dateIssuedCheck);
    if (!dateIssuedCheck) { return false; }

    var primaryFile = primaryFileNewPublication();
    console.log(primaryFile);
    if (!primaryFile) { return false; }

    var validationValue = document.getElementById("publication_content_genre").selectedOptions[0].label;
    var pubverValue = document.getElementById("publication_publisher_version").selectedOptions[0].label;
    var parTitleValue = document.getElementById("publication_parent_title").value;

    var publisherVersion = 'The Publication Version field is required. <br> You can find this field under Publication Information.';
    var parentTitle = 'The Title of Journal or Parent Work field is required. <br>You can find this field under Publication Information.'

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

        case 'Book':
        case 'Conference Paper': {

            console.log('Validating: Book || Conference Paper');
            if (pubverValue == ' ') {
                var publisherVersion = "The Publication Version field is required";
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

        case 'Report': {
            console.log('Selected: Report');
            removeModal();
            break;
        }

        case ' ': {
            console.log('Selected: none');
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

    var modalNewPub = document.querySelector('[id^="new_publication_"]');
    var modalEditPub = document.querySelector('[id^="edit_publication_"]');

    var text = '<div class="modal pubform" id="pubvalidatemodal"><div class="modal-dialog mo,dal-dialog-centered"><div class=modal-content><div class=modal-header><h4 class=modal-title>Missing Entries</h4><button class=close data-dismiss=modal type=button>×</button></div><div class=modal-body>' + x + '<br></div><div class=modal-footer><button class="btn btn-danger"data-dismiss=modal type=button>Close</button></div></div></div></div>';

    if (modalNewPub) {
        modalNewPub.insertAdjacentHTML("afterend", text);
    }

    if (modalEditPub) {
        modalEditPub.insertAdjacentHTML("afterend", text);
    }
    return false;

}

function removeModal() {
    console.log("modal remove");
    $(".modal.pubform").remove();
}

function dateIssuedValidation() {
    console.log("Date Issued Validation");

    var dateIssueValue = document.getElementById("publication_date_issued").value;
    var dateIssuedBool = isDateValid(dateIssueValue);
    var dateIssueTitle = 'The Date field must be in a proper format (YYYY-MM-DD, YYYY-MM or YYYY). <br>You can find this field under Publication Information.';

    //check if value is empty
    if (dateIssueValue !== "") {
        console.log('value is not empty, value is: ' + dateIssueValue);
        if (!dateIssuedBool) {
            console.log('dateIssued is: ' + dateIssueTitle);
            validateModal(dateIssueTitle);
            return false;
        }
        console.log('do nothing');
        return true;
    } else {
        console.log('value is empty!');
        return true;
    }
}

function orcidValidation() {
    console.log("orcid id validation");

    var orcidID = document.getElementById("publication_creators_orcid_id").value;
    var orcidIDBool = isOrcidIdValid(orcidID);
    console.log(orcidIDBool);
    var orcidIDValue = 'The orcid ID is not valid.';

    if (orcidID !== "") {
        if (!orcidIDBool) {
            validateModal(orcidIDValue);
            return false;
        } else return true;
    } else return true;
}

function relatedDataValidation() {
    console.log("relatedData URL Validation");

    var relatedData = document.getElementById("publication_related_datasets").value;
    var relatedDataBool = isUrlValid(relatedData);
    var relatedDataTitle = 'The Supplemental Material field requires a full URL entry (starting with http://, https:// etc)';

    //first check if related is not empty
    if (relatedData !== "") {
        console.log('value is not empty, related date: ' + relatedData);
        if (!relatedDataBool) {
            console.log('relatedDataTitle is: ' + relatedDataTitle);
            validateModal(relatedDataTitle);
            return false;
        }

        console.log('do nothing');
        return true;
    } else {
        console.log("value is empty!");
        return true;
    }
}

function finalPubVerValidation() {
    console.log("finalPubVer URL Validation");

    var finalPubVer = document.getElementById("publication_final_published_versions").value;
    var finalPubVerBool = isUrlValid(finalPubVer);
    var finalPubVerTitle = 'The Final Published Version field requires a full URL entry (starting with http://, https:// etc). <br>You can find this field under Publication Information.';

    //first check if related is not empty
    if (finalPubVer !== "") {
        console.log('value is not empty, final published version: ' + finalPubVer);

        if (!finalPubVerBool) {
            console.log('finalPubVerTitle is: ' + finalPubVerTitle);
            validateModal(finalPubVerTitle);
            return false;
        }
        console.log('do nothing');
        return true;
    } else {
        console.log("value is empty!");
        return true;
    }
}

function isOrcidIdValid(orcidID) {
    //no url
    var orcidIdRegex = /^\d{4}\-\d{4}\-\d{4}\-\d{4}$/;
    // with url
    var orcidIdRegex2 = /https:\/\/orcid\.org\/[0-9]+-[0-9]+-[0-9]+-[0-9]+$/;

    if (orcidIdRegex.test(orcidID) || orcidIdRegex2.test(orcidID)) {
        console.log("idk one of these worked lol");
        return true;
    } else return false;
}

function isUrlValid(url) {
    try {
        new URL(url);
        return true;
    } catch (err) {
        return false;
    }
}

function isDateValid(date) {

    var longDateRegex = /^(19|20)\d{2}\-(0[1-9]|1[0-2])\-(0[1-9]|1\d|2\d|3[01])$/; //YYYY-MM-DD 
    var monthYearDateRegex = /^(19|20)\d{2}\-(0[1-9]|1[0-2])$/; //YYYY-MM
    var yearDateRegex = /^(12|13|14|15|16|17|18|19|20)\d{2}$/ //YYYY
    if (longDateRegex.test(date) || monthYearDateRegex.test(date) || yearDateRegex.test(date)) {
        return true;
    } else { return false; }
}

function primaryFileNewPublication() {
    var urlCheck = window.location.pathname;
    console.log(urlCheck);

    if (urlCheck == "/concern/publications/new") {
        return primaryFileValidation();
    } else return true;
}

function primaryFileValidation() {
    console.log("primary file validation");
    var fileUpload = document.getElementById("primary-progress0").value;

    var primary0 = document.getElementById("primary0").value;
    var primaryFileTitle = "The Primary Content File located under the files tab at the top of the page is required to submit.";
    var primaryFileNotLoadedTitle = 'The Primary Content File must be attached before saving this work. <br><br>Please review the Files tab of the form and make sure you have selected a file for upload. Then click the Attach File button and make sure the Upload Status is complete before saving the work.';

    if (primary0 == "" && fileUpload == 0) {
        console.log("file was not uploaded");
        validateModal(primaryFileTitle);
        return false;
    }

    if (primary0 != "" && fileUpload == 0) {
        console.log("file selected but not attached");
        validateModal(primaryFileNotLoadedTitle);
        return false;
    }

    if (primary0 = ! "" && fileUpload != 0) {
        console.log("the file was selected and loaded.");
        return true;
    } else alert("Contact LTDS"); return true;
}