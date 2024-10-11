
# Extract MODS Metadata to CSV Script

This tool parses the necessary metadata needed to import Publication objects into Emory's SelfDeposit application. Please follow the directions below to get the script operating correctly.


# Prerequisites

This is a Ruby script which has been authored and tested with Ruby v3.2.2. Please use the same version. The `dlp-selfdeposit` repository must also be cloned on any computer or server this is to be called from.

Since this script uses the `pids_with_binaries_<date and time of processing>.csv` and the `descMetadata.xml`  file for each PID produced by the Migrate Fedora 3 Objects Script, access to where the migration script saved these files is required.

# Usage

This script can be used in two different ways: the default fashion that is optimized to use on deployed servers that accepts one argument and the developer option that accepts two arguments.

## *Deployed Server*

When running on a deployed server and utilizing the `/mnt/efs/current_batch` storage location for the PID binary folders, the script can be called using one argument in the format below:

    <complete path to the script on computer/server that ends with>/extract_mods_metadata_to_csv.rb <full path to the pids_with_binaries_***.csv>
This option assumes that all of the folders that contain binaries and XMLs associated to the PIDs listed within the passed CSV live within the mounted folder structure above. If those folders are stored outside of that structure or the folder structure isn't mounted correctly, running this script will produce errors.

## *Developer Option*

Because of the server assumption that the script makes, developing enhancements to the script requires an additional argument pointing to a developer's desired folder structure. This allows the script to process outside of the server default structure on both local machines and deployed servers. Run the script in the following structure:

    <complete path to the script on computer/server that ends with>/extract_mods_metadata_to_csv.rb <full path to the pids_with_binaries_***.csv> <full path to developer's desired directory containing PID storage folders>

# Expected Results
When all prerequisites are met, the script will return a single file into the same directory that the script was ran from with the following naming format: `ingestion_csv_from_<date and time of processing>.csv`. That file can be downloaded and passed to the personnel that will run Bulkrax importers (or SelfDeposit's Product Owner).

The only missing CSV column within this document would be for the `parent` field. In order for the Publications resulting from this CSV document to be associated to a desired Collection, advise the Bulkrax importing personnel that the `parent` field must be filled with the Collection's ID string value for each line.

# Possible Causes of Errors

 - Wrong Storage Locations: remember, the directory housing the `emory_<PID>` folders must be either `/mnt/efs/current_batch` (deployed server mode) or the full path specified in the second argument (developer option mode).
 - Folder Permissions: make sure that the directory the script is being processed in has write permissions.

