### PDF Viewer

Current version: pdf.js v4.4.168 (Prebuilt)

Last updated: July 23, 2024

This application uses [pdf.js](https://mozilla.github.io/pdf.js/) to load the PDF viewer when a PDF fileset is the representative fileset of a particular work.

#### Installation

To add or update pdf.js, download the latest prebuilt version of the library from the official download page: https://mozilla.github.io/pdf.js/. Unzip the folder, rename it to `pdfjs`, and add it to the public folder of the application. To load the PDF viewer, the application relies on the `viewer.html` file, which it currently expects at `public/pdfjs/web/viewer.html`.

#### Customization

You can customize the features of the viewer by overriding the `public/pdfjs/web/viewer.html` file. Currently, the only override added is hiding the editor mode buttons, line 301.

#### Notes

Due to issues installing and loading pdf.js using Yarn and asset management, it is recommended to add the pdf.js library's codebase to this application's codebase as instructed in the installation section above. This method ensures we can easily use the library with Rails and override the `viewer.html` file to disable any unnecessary functionality.
