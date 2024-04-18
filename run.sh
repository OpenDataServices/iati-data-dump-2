#!/bin/bash

# Stop on error
set -e

# Start time tracking
StartTime=$(date +%Y-%m-%dT%H:%M:%SZ)

# Env vars you can pass
[[ -z "${WORKING_DIR}" ]] && WorkingDir='working' || WorkingDir="${WORKING_DIR}"
[[ -z "${DEBUG}" ]] && Debug='false' || Debug="${DEBUG}"

# Clean out existing workingdir files/dirs that may exist already
# Important to do this so if a publisher deletes a file it is deleted from here too!
rm -rf ${WorkingDir}/urls
rm -rf ${WorkingDir}/metadata
rm -rf ${WorkingDir}/metadata.json
rm -rf ${WorkingDir}/data
rm -rf ${WorkingDir}/logs
rm -rf ${WorkingDir}/downloads.curl
rm -rf ${WorkingDir}/debug_downloads.curl
rm -rf ${WorkingDir}/data.zip
rm -rf ${WorkingDir}/errors.txt
rm -rf ${WorkingDir}/iati-data-main

# Make sure dirs exist
mkdir -p ${WorkingDir}
mkdir -p ${WorkingDir}/urls
mkdir -p ${WorkingDir}/logs
mkdir -p ${WorkingDir}/iati-data-main

# Get URLs
echo "Get URLs ...."
GRAB_URLS_WORKING_DIR=${WorkingDir} python3 grab_urls.py

# Change to working dir for rest of script
cd ${WorkingDir}

# Download files
echo "Download ...."
if [[ $Debug = "true" ]]
then
    head -n 100 downloads.curl > debug_downloads.curl
    (cat debug_downloads.curl | sort -R | parallel -j2) || true
else
    (cat downloads.curl | sort -R | parallel -j20) || true
fi

# Errors
# This can error if the logs dir is empty
(cat logs/* > errors.txt) || true
echo "." >> errors.txt

# End time tracking
EndTime=$(date +%Y-%m-%dT%H:%M:%SZ)

# Make meta
echo "{\"created_at\": \"${StartTime}\", \"updated_at\": \"${EndTime}\"}" > metadata.json

# Make Zip
echo "Zip ...."
# Move these ones, as they are big
mv data iati-data-main/data
mv metadata iati-data-main/metadata
# copy these ones, as they are small and we want the original files left as output for other processes to pick up
cp errors.txt iati-data-main/errors.txt
cp metadata.json iati-data-main/metadata.json
# now zip
zip -q -r data.zip iati-data-main/metadata iati-data-main/data iati-data-main/metadata.json iati-data-main/errors.txt

# Finished
echo "Finished!"
