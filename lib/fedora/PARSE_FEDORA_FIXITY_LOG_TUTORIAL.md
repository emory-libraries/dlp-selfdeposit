# Parse Fedora Fixity Log Script

This tool produces a CSV report when provided with a fixity log outputted by Fedora's fixity tool. Please follow the directions below to get the script operating correctly.

## Prerequisites

The Parse Fedora Fixity Log script relies on Ruby gems that should be included within the standard library. If errors are encountered during processing, please contact Software Development for assistance. The `dlp-selfdeposit` repository must also be cloned on any computer or server this is to be called from. And since this is a Ruby script, Ruby v3.2.2 must also be installed.

## Usage

To operate this script, please run the following command within the directory that the report should be delivered to:

    <complete path to the script on computer/server that ends with>/parse_fedora_fixity_log.rb <complete path to the fixity log file Fedora provided>
Please note that the full path to the script must be used if intending to save the files anywhere besides the root folder of the `dlp-selfdeposit` Rails application.

## Expected Results
When all prerequisites are met, the script will return a CSV file with three headers and one line of results. The headers will include `Total Items Checked` , `Total Items Passed`, and `Total Items Failed`.

## Troubleshooting
When the script fails, the terminal will display errors that can be reported to the Software Development for further guidance. The most likely error that will arise will be `permission denied`. That will occur if the script file hasn't been made executable. Please refer to the operating system's procedures to make the script file executable.
