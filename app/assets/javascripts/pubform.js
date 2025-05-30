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

    var relatedDataCheck = relatedDataValidation();
    console.log(relatedDataCheck);

    var finalPubVerCheck = finalPubVerValidation();
    console.log(finalPubVerCheck);

    var dateIssuedCheck = dateIssuedValidation();
    console.log(dateIssuedCheck);

    var primaryFile = primaryFileNewPublication();
    console.log(primaryFile);

    if (!orcidCheck || !relatedDataCheck || !finalPubVerCheck || !dateIssuedCheck || !primaryFile) {
        return false;
    }

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
            console.log('validate default');
            removeModal();
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
    var orcidIDs = document.getElementsByClassName("publication_creators_orcid_id");

    for (var orcidID of orcidIDs) {
        var orcidVal = orcidID.children[1].value;
        var orcidIDBool = isOrcidIdValid(orcidVal, orcidID);
        console.log(orcidID);
        var orcidIDError = '<p>Please enter only the ID section of your ORCID id, starting after <a href="https://orcid.org/" target="_blank">https://orcid.org/</a>. <br>Examples: <ul><li><a href="https://orcid.org/0000-0002-2771-9344" target="_blank">https://orcid.org/0000-0002-2771-9344</a></li><li>0000-0002-2771-9344</li></ul></p>';

        if (orcidVal !== "" && !orcidIDBool) {
            validateModal(orcidIDError);
            return false;
        }
    }
    return true;
}

function relatedDataValidation() {
    console.log("relatedData URL Validation");

    var relatedDatas = document.getElementsByClassName("publication_related_datasets");
    var relatedDataTitle = 'The Supplemental Material field requires a full URL entry (starting with http://, https:// etc)';

    for (var i = 1; i < relatedDatas.length; i++) {
        // console.log(relatedDatas);
        var relatedData = relatedDatas[i].value;
        // console.log(relatedData);
        var relatedDataBool = isUrlValid(relatedData);

        if (relatedData !== "" && !relatedDataBool) {
            validateModal(relatedDataTitle);
            return false;
        }
    } return true;
}

function finalPubVerValidation() {
    console.log("finalPubVer URL Validation");
    var finalPubVers = document.getElementsByClassName("publication_final_published_versions");
    var finalPubVerTitle = 'The Final Published Version field requires a full URL entry (starting with http://, https:// etc). <br>You can find this field under Publication Information.';
    // console.log(finalPubVers);

    for (var i = 1; i < finalPubVers.length; i++) {
        var finalPubVerValue = finalPubVers[i].value;
        // console.log(finalPubVerValue);
        var finalPubVerBool = isUrlValid(finalPubVerValue);

        if (finalPubVerValue !== "" && !finalPubVerBool) {
            validateModal(finalPubVerTitle);
            return false;
        }
    } return true;
}

function isOrcidIdValid(orcidVal, orcidID) {
    var orcidIdRegex = /^\d{4}\-\d{4}\-\d{4}\-\d{4}$/;
    var orcidIdRegex2 = /https:\/\/orcid\.org\/[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{4}$/; // with url

    if (orcidIdRegex.test(orcidVal)) {
        return true;
    } else if (orcidIdRegex2.test(orcidVal)) {
        var orcidURL = new URL("", orcidVal);
        var orcidPath = orcidURL.pathname.substring(1);
        orcidID.children[1].value = orcidPath;
        return true;
    } else return false;
}

function isUrlValid(url) {
    try {
        // new URL(url);
        const newUrl = new URL(url);
        // console.log(newUrl.protocol);
        return newUrl.protocol === 'http:' || newUrl.protocol === 'https:';
        // return true;
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