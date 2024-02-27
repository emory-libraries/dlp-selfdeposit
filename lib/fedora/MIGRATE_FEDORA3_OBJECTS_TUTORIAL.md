# Migrate Fedora 3 Objects Script

This tool exports "datastreams" (binary or XML files) when provided with the Fedora instance information and a list of "PIDs" (IDs for each Fedora object). Please follow the directions below to get the script operating correctly.


# Prerequisites

The Migrate Fedora 3 Objects script relies on [Lyrasis' fedora-export CLI script](https://wiki.lyrasis.org/display/FEDORA38/fedora-export). Before running the Emory Library script, this suite of CLI tools must be installed in the computer or server that it will be executed from. Instructions on how to install the "client" level of CLI tools can be found [here](https://wiki.lyrasis.org/display/FEDORA38/Installation+and+Configuration). Please note that, since we only need the CLI scripts from this install, the only prerequisites needed for the installation are to have Java 8 installed, the environment variable of JAVA_HOME set to the home of JAVA 8's bin folder, the FEDORA_HOME environment variable set to where the client version of Fedora 3.8 is installed, and the computer or server's PATH to be updated as described in the installation instructions.

The `dlp-selfdeposit` repository must also be cloned on any computer or server this is to be called from. And since this is a Ruby script, Ruby v3.2.2 must also be installed.

# Usage

When connected to Emory's VPN and working from the command line, change directories into the desired folder that you want the new folders of files to be created in. The script can be run with the following command:

    ./lib/fedora/migrate_fedora3_objects.rb <list of pids separated only by commas> <Fedora 3 server's path with port number> <Fedora 3 API's username> <Fedora 3 API's password>
Please note that the full path to the script must be used if intending to save the files anywhere besides the root folder of the `dlp-selfdeposit` Rails application.

## List of PIDs

When providing the script the PIDs from the Fedora 3 server, please omit the leading `emory:` prefix. These are standard for OpenEmory 1's objects, so providing them in the script would only make the command more difficult to create/edit. Please also separate the list of PIDs with a single comma only (no spaces please). For example:

    q4fd0,fjhxt,dzmbk

## Fedora 3 Server's Path

The Fedora 3 server's path should match the format below:

    http://www.example.com:8080

Be aware that the current version of this script can only process exports from a `http` server. Working with `https` server requires the passing of a Java Certificate with the server communication, which isn't possible with this version.

## Fedora 3 API's Username and Password

The default username and password for Fedora API servers are both `fedoraAdmin`. Please try this first, and if you run into Authentication errors, please reach out to the Software Development for guidance.

# Expected Results
When all prerequisites are met, the script will report back with two lines, resembling

    Exporting emory:XXXXX to ./emory_XXXXX.xml
    Exported emory:XXXXX

When the script fails, the terminal will display errors that can be reported to the Software Development for further guidance.

If the script performs as expected, there should be a new XML file and folder in the directory you called the script from. The XML was used by the script to pull the needed files. This is left in this folder to help diagnose any unexpected behavior with the script. The new folder contains the files downloaded from the Fedora server. Each of the files (except AUDIT.xml) should be properly formatted and produce no errors when opened in a compatible application (XMLs can be opened in any web browser). The `AUDIT.xml` isn't processed in the same fashion as the other XMLs in the folder, so it needs to be opened in a text editor.

Please report to Software Development any issues with the documents/binaries in the folder.
