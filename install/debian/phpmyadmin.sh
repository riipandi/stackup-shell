#!/bin/bash
if [[ $EUID -ne 0 ]]; then echo 'This script must be run as root' ; exit 1 ; fi
[ -z $ROOTDIR ] && PWD=$(dirname `dirname $(dirname $(readlink -f $0))`) || PWD=$ROOTDIR
source "$PWD/common.sh"

#-----------------------------------------------------------------------------------------
msgSuccess "\n--- Installing phpMyAdmin"
#-----------------------------------------------------------------------------------------
[[ ! -d /var/www/myadmin ]] || rm -fr /var/www/myadmin

pmaUrl="https://phpmyadmin.net/downloads/phpMyAdmin-latest-english.zip"
curl -fsSL ${pmaUrl} | bsdtar -xvf- -C /tmp &>${logInstall}
mv /tmp/phpMyAdmin*english /var/www/myadmin

cat > /var/www/myadmin/config.inc.php <<EOF
<?php
\$cfg['blowfish_secret'] = '`openssl rand -hex 16`';
\$i = 0; \$i++;
\$cfg['Servers'][\$i]['auth_type']       = 'cookie';
\$cfg['Servers'][\$i]['host']            = '127.0.0.1';
\$cfg['Servers'][\$i]['connect_type']    = 'tcp';
\$cfg['Servers'][\$i]['AllowNoPassword'] = false;
\$cfg['Servers'][\$i]['hide_db']         = '^(information_schema|performance_schema|mysql|phpmyadmin|sys)\$';
\$cfg['MaxRows']                         = 100;
\$cfg['SendErrorReports']                = 'never';
\$cfg['ShowDatabasesNavigationAsTree']   = false;
EOF

chmod 0755 /var/www/myadmin
find /var/www/myadmin/. -type d -exec chmod 0777 {} \;
find /var/www/myadmin/. -type f -exec chmod 0644 {} \;
chown -R webmaster:webmaster /var/www/myadmin
