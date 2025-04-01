## SelfDeposit Fedora 3 Objects Export and Extract Metadata Workflow

 1. **Obtain/Create CSV of PIDs**
	The document should be a `.csv` of any filename that contains a header of `ids` and a list of PIDs with the `emory:` beginning sub-string removed. Example:


    ids
    	tvts6
    	tvb58
    	tvttb
    	tvtvg

 2. **Copy the PID CSV document to server operating the script**
	However, the server needs to have a firewall exclusion for the Fedora 3 instance we're importing from. The Test environment has been live the longest (Arch has been recently rebuilt and Production is a newer instance) and has the exclusion set at the time of this tutorial's creation. The staging location for all ingests across every environment is `/mnt/efs/current_batch`. SelfDeposit is hardwired to pull all ingest objects from this folder. This folder is the same storage location across every environment, meaning that an import processed in Test is available in Arch and Prod, as well.

	On Unix-based computers, the `scp` command can be used to copy the PID CSV to the target server. Remember that all server interactions require a VPN connection. Below is an example of that command:

    `scp  /home/your_computer/Downloads/batch_14001_15000.csv deploy@12.34.56.78:/mnt/efs/current_batch/`
3. **Running the Export Script**
`ssh` into the same server the file was copied to and change directory to `/mnt/efs/current_batch`. Once again, this is the main staging area for ingests. If previous exports have occurred on this server, there will be multiple folders and XMLs in this directory using this naming convention: `emory_*****`.

	`migrate_fedora3_objects.rb` is the script used to download the XML that points the code to the available datastreams (files) for each PID, as well as extract the files found in the XML to the folder structure. This script doesn't live in the same folder--it exists in the Rails application folders, but isn't directly tied to the application itself. The explanation of the script call structure can be found in the tutorial found at `dlp-selfdeposit/lib/fedora/MIGRATE_FEDORA3_OBJECTS_TUTORIAL.md`.

	Example of script command:
	`/opt/dlp-selfdeposit/current/lib/fedora/migrate_fedora3_objects.rb batch_14001_15000.csv http://fedora-instance.some.library.edu:8080 fedora_api_username fedora_api_password`

	When run successfully, this will build the files mentioned above, as well as one or two more documents. When the export script finds that there are PIDs that lack operative datastreams, a report file named `pids_with_no_binaries_<date and time>.txt` will download into the same operating folder. A CSV containing all of the PIDs that did have files we can use will also download, using the filename convention `pids_with_binaries_<date and time>.csv`. This file will be passed onto the next script, `extract_mods_metadata_to_csv.rb`.
4. **Running the Extract Metadata Script**
The `pids_with_binaries_<date and time>.csv` file produced from the last script can now be used to build the ingest CSV that Bulkrax (bulk ingest gem in SelfDeposit) needs to read. The details of this script can be found at `dlp-selfdeposit/lib/metadata/EXTRACT_MODS_METADATA_TO_CSV_TUTORIAL.md`

	Example of script command:
`/opt/dlp-selfdeposit/current/lib/metadata/extract_mods_metadata_to_csv.rb /mnt/efs/current_batch/pids_with_binaries_<date and time>.csv`

	The processing should take about a minute or two, and return a CSV with the naming convention of `ingestion_csv_from_<date and time>.csv` This is the sole required document that needs to be passed to the export ticket creator (although the original batch ID CSV and the `pids_with_no_binaries` could also be sent over for record-keeping purposes).
