#!/bin/bash
#
# Title:      PlexGuide (Reference Title File)
# Author(s):  Admin9705 - Deiteq
# URL:        https://plexguide.com - http://github.plexguide.com
# GNU:        General Public License v3.0
################################################################################

######################################################## Declare Variables
sname="PG Installer: Set PG Edition"
pg_edition=$( cat /var/plexguide/pg.edition )
pg_edition_stored=$( cat /var/plexguide/pg.edition.stored )
######################################################## START: PG Log
sudo echo "INFO - Start of Script: $sname" > /var/plexguide/pg.log
sudo bash /opt/plexguide/roles/log/log.sh
######################################################## START: Main Script
if [ "$pg_edition" == "$pg_edition_stored" ]; then
  echo "" 1>/dev/null 2>&1
else
  bash /opt/plexguide/menu/editions/editions.sh
fi
######################################################## END: Main Script
#
#
######################################################## END: PG Log
sudo echo "INFO - END of Script: $sname" > /var/plexguide/pg.log
sudo bash /opt/plexguide/roles/log/log.sh
