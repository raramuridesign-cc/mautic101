################################################################
##    MAUTIC: 
##    Clean File & Directory Permissions
##    Created by: raramuridesign
################################################################
##    UPDATE VARIABLES
      # This is where mautic is installed
      PATH_PUBLIC='/home/xxxxxx/public_html'
      OWNER='xxxxxx'
## DO NOT EDIT ANYTHING BELOW THIS LINE
################################################################
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
echo 'MAUTIC CLEANUP COMPLETE'
echo '------------------------------'
echo ''
# END !
