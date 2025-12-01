#!/bin/bash
set -euo pipefail

################################################################
##    MAUTIC: 
##    Clean File & Directory Permissions
##    Created by: raramuridesign
################################################################
##    UPDATE VARIABLES
      # This is where mautic is installed
      # Note: Set PATH_PUBLIC to the root directory of your Mautic installation.
      # If Mautic is installed in the root of your web directory, use the full path to that directory.
      # If installed in a subfolder, use the full path to the subfolder (e.g., /home/user/public_html/mautic).
      PATH_PUBLIC='/home/xxxxxx/public_html'
      OWNER='xxxxxx'
## DO NOT EDIT ANYTHING BELOW THIS LINE
################################################################

# Function to handle errors
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Check if PATH_PUBLIC exists
if [[ ! -d "$PATH_PUBLIC" ]]; then
    error_exit "PATH_PUBLIC directory '$PATH_PUBLIC' does not exist."
fi

# Check if OWNER user exists
if ! id "$OWNER" &>/dev/null; then
    error_exit "OWNER user '$OWNER' does not exist."
fi

echo '------------------------------'
echo 'START MAUTIC CLEANUP'
echo '------------------------------'
cd ${PATH_PUBLIC}
echo '>> Clear cache...'
# php ${PATH_PUBLIC}/bin/console cache:clear
# or execute a delete
rm -rf var/cache/*
echo '>> Done'
echo '------------------------------'
echo '>> Fix File/Folder Permissions & Ownership...'
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
chmod -vR g+w var/cache/
chmod -vR g+w var/logs/
chmod -vR g+w app/config/
chmod -vR g+w media/files/
chmod -vR g+w media/images/
chmod -vR g+w translations/
chown -vR ${OWNER}:${OWNER} .
echo '>> Done'
echo '------------------------------'
echo '>> Cache Warm Up...'
php ${PATH_PUBLIC}/bin/console cache:warmup
echo '>> Done'
echo '------------------------------'
echo '>> Regenerate Mautic assets...'
php ${PATH_PUBLIC}/bin/console mautic:assets:generate
echo '>> Done'
echo '------------------------------'
echo 'MAUTIC CLEANUP COMPLETE'
echo '------------------------------'
echo ''
# END !