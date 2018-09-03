#!/bin/bash
#
# [PlexGuide Menu]
#
# GitHub:   https://github.com/Admin9705/PlexGuide.com-The-Awesome-Plex-Server
# Author:   Admin9705 & Deiteq
# URL:      https://plexguide.com
#
# PlexGuide Copyright (C) 2018 PlexGuide.com
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#
#################################################################################
export NCURSES_NO_UTF8_ACS=1
downloadpath=$(cat /var/plexguide/server.hd.path)
echo 'INFO - @Unencrypted PG Blitz Menu' > /var/plexguide/pg.log && bash /opt/plexguide/roles/log/log.sh
RCLONE_CONF="/root/.config/rclone/rclone.conf"

#### RECALL VARIABLES START
tdrive=$(grep "tdrive" $RCLONE_CONF)
gdrive=$(grep "gdrive" $RCLONE_CONF)
tcrypt=$(grep "tcrypt" $RCLONE_CONF)
gcrypt=$(grep "gcrypt" $RCLONE_CONF)
#### RECALL VARIABLES END

versioncheck="Version: Unencrypted Edition"
final="unencrypted"

if [ "$gdrive" != "[gdrive]" ]; then
  versioncheck="WARNING: GDrive Not Configured Properly"
  final="gdrive"
fi

if [ "$tdrive" != "[tdrive]" ]; then
  versioncheck="WARNING: TDrive Not Configured Properly"
  final="tdrive"
fi

if [ "$gcrypt" == "[gcrypt]" ]; then
    gflag="on"
    encryption="on"
fi
if [ "$tcrypt" == "[tcrypt]" ]; then
    tflag="on"
    encryption="on"
fi

if [ "$encryption" == "on" ] && [ "$tflag" == "on" ] && [ "$gflag" == "on" ]; then
    versioncheck="Version: Encrypted Edition"
    final="encrypted"
    mkdir -p /opt/appdata/pgblitz/vars
    touch /opt/appdata/pgblitz/vars/encrypted  1>/dev/null 2>&1
    mkdir -p /mnt/gcrypt
    mkdir -p /mnt/tcrypt
elif [ "$gflag" != "on" ] && [ "$encryption" == "on" ]; then
    versioncheck="WARNING: GCrypt Not Configured Properly"
    final="gcrypt"
elif [ "$tflag" != "on" ] && [ "$encryption" == "on" ];then
    versioncheck="WARNING: TCrypt Not Configured Properly"
    final="tcrypt"
fi
################################################################## CORE
HEIGHT=17
WIDTH=55
CHOICE_HEIGHT=10
BACKTITLE="Visit https://PlexGuide.com - Automations Made Simple"
TITLE="PGDrive /w PG Blitz"
MENU="$versioncheck"

OPTIONS=(A "RClone : Config & Establish"
         B "JSON   : Upload for PGBlitz & PGDrive"
         C "E-Mail : Share Generator for PG Blitz"
         D "Process: JSON files for Validation"
         E "Deploy : PG Drive & PG Blitz"
         F "DL Path: Current - $downloadpath"
         G "T-Shoot: Reprocess Bad JSONs"
         H "T-Shoot: Baseline PG Blitz (Fresh Start)"
         I "T-Shoot: Disable PGBlitz"
         Z "Exit")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        A)
echo 'INFO - Configured RCLONE for PG Drive' > /var/plexguide/pg.log && bash /opt/plexguide/roles/log/log.sh

            #### RClone Missing Warning - END

            #################### installing dummy file for prep of pgdrive deployment

            ;;
        B)
        ### Checkers

            ;;
        C)
          ### Checkers

          ;;
        D)
          ### Validate Process
          gdsa=`ls -la /opt/appdata/pgblitz/keys/unprocessed | awk '{print $9}' | grep GDSA | wc -l`;
          if [ $gdsa > 2 ]; then
            if [ "$encryption" == "on" ]; then
              dialog --title "SET ENCRYPTION PASSWORD" \
                    --inputbox "Password: " 8 52 2>/opt/appdata/pgblitz/vars/password
              dialog --title "SET ENCRYPTION SALT" \
                    --inputbox "Salt: " 8 52 2>/opt/appdata/pgblitz/vars/salt
            fi
            bash /opt/plexguide/roles/pgblitz/scripts/validator.sh
          else
            dialog --title "WARNING!" --msgbox "\nIt seems like you have no JSON files :(" 0 0
          fi
          ;;
        E)
          ### Checkers
          if [ "$final" == "gdrive" ]; then
            echo 'FAILURE - Must Configure gdrive for RCLONE' > /var/plexguide/pg.log && bash /opt/plexguide/roles/log/log.sh
            dialog --title "WARNING!" --msgbox "\nGDrive for RClone Must be Configured for PG Blitz!\n\nThis is required to BackUp/Restore any PG Data!" 0 0
            bash /opt/plexguide/roles/pgblitz/scripts/main.sh
            exit
          fi

          if [ "$final" == "tdrive" ]; then
            echo 'FAILURE - Must Configure tdrive for RCLONE' > /var/plexguide/pg.log && bash /opt/plexguide/roles/log/log.sh
            dialog --title "WARNING!" --msgbox "\nTDrive for RClone Must be Configured for PG Blitz!\n\nThis is required for TeamDrives to Work!!" 0 0
            bash /opt/plexguide/roles/pgblitz/scripts/main.sh
            exit
          fi
          if [ "$final" == "tcrypt" ] || [ "$final" == "gcrypt" ]; then
            echo 'FAILURE - Must Configure $final for RCLONE for Encrypted Edition' > /var/plexguide/pg.log && bash /opt/plexguide/roles/log/log.sh
            dialog --title "WARNING!" --msgbox "\n$final for RClone Must be Configured for PG Blitz!\n\nThis is required for the Encrypted Edition!!" 0 0
            bash /opt/plexguide/roles/pgblitz/scripts/main.sh
            exit
          fi

          #### BLANK OUT PATH - This Builds For UnionFS
          rm -r /var/plexguide/unionfs.pgpath 1>/dev/null 2>&1
          touch /var/plexguide/unionfs.pgpath 1>/dev/null 2>&1

          ### Build UnionFS Paths Based on Version
          if [ "$final" == "unencrypted" ];then
            echo -n "/mnt/gdrive=RO:/mnt/tdrive=RO:" >> /var/plexguide/unionfs.pgpath
          elif [ "$final" == "encrypted" ];then
            echo -n "/mnt/gcrypt=RO:/mnt/tcrypt=RO:" >> /var/plexguide/unionfs.pgpath
          fi

          ### Add GDSA Paths for UnionFS
          bash /opt/plexguide/roles/pgblitz/scripts/ufbuilder.sh
          temp=$( cat /tmp/pg.gdsa.build )
          echo -n "$temp" >> /var/plexguide/unionfs.pgpath

          ### Execute Playbook Based on Version
          if [ "$final" == "unencrypted" ];then
            ansible-playbook /opt/plexguide/pg.yml --tags menu-pgblitz --skip-tags encrypted
          elif [ "$final" == "encrypted" ];then
            ansible-playbook /opt/plexguide/pg.yml --tags menu-pgblitz
          fi
          echo ""
          read -n 1 -s -r -p "Press any key to continue"
          dialog --title "PGBLitz WebGUI" \
                --yesno "Would you like to deploy the new PGBlitz WebGUI?" 7 60
            response=$?
            case $response in
                0)
                  echo 'INFO - DEPLOYING PGBLITZ WEBGUI' > /var/plexguide/pg.log && bash /opt/plexguide/roles/log/log.sh
                  ansible-playbook /opt/plexguide/pg.yml --tags blitzui
                  ;;
                1)
                  echo 'INFO - NOT DEPLOYING PGBLITZ WEBGUI' > /var/plexguide/pg.log && bash /opt/plexguide/roles/log/log.sh
                  ;;
            esac
          dialog --title "NOTE" --msgbox "\nPG Drive & PG Blitz Deployed!!" 0 0
          ;;
        F)
            bash /opt/plexguide/scripts/baseinstall/harddrive.sh
            ;;
        G)
            dialog --infobox "Reprocessing BAD JSONs (Please Wait)" 3 40
            sleep 2
            clear
            mv /opt/appdata/pgblitz/keys/badjson/* /opt/appdata/pgblitz/keys/unprocessed/ 1>/dev/null 2>&1
            bash /opt/plexguide/roles/pgblitz/scripts/validator.sh;;
        H)
            dialog --infobox "Baselining PGBlitz (Please Wait)" 3 40
            sleep 2
            systemctl stop pgblitz 1>/dev/null 2>&1
            systemctl disable pgblitz 1>/dev/null 2>&1
            #grep -A10 'tdrive' rclone.conf|grep -v "tdrive" > /root/.config/rclone/tdrive.save
            #grep -A10 'gdrive' rclone.conf|grep -v "gdrive" > /root/.config/rclone/gdrive.save
            rm -r /root/.config/rclone/rclone.conf 1>/dev/null 2>&1
            rm -r /opt/appdata/pgblitz/keys/unprocessed/* 1>/dev/null 2>&1
            rm -r /opt/appdata/pgblitz/keys/processed/* 1>/dev/null 2>&1
            rm -r /opt/appdata/pgblitz/keys/badjson/* 1>/dev/null 2>&1

            #echo "[tdrive]" > /root/.config/rclone/rclone.conf
            #cat /root/.config/rclone/tdrive.save > /root/.config/rclone/rclone.conf
            #echo "" > /root/.config/rclone/rclone.conf
            #echo "[gdrive]" > /root/.config/rclone/rclone.conf
            #cat /root/.config/rclone/gdrive.save >> /root/.config/rclone/rclone.conf
            #rm -r /root/.config/rclone/tdrive.save
            #rm -r /root/.config/rclone/gdrive.save
            dialog --title "NOTE" --msgbox "\nKeys Cleared!\n\nYou must reconfigure RClone and Repeat the Process Again!" 0 0
            ;;
         I)
            sudo systemctl stop pgblitz 1>/dev/null 2>&1
            sudo systemctl rm pgblitz 1>/dev/null 2>&1
            dialog --title "NOTE" --msgbox "\nPG Blitz is Disabled!\n\nYou must rerun PGDrives & PGBlitz to Enable Again!" 0 0
            ;;
        Z)
            exit 0 ;;

########## Deploy End
esac

bash /opt/plexguide/roles/pgblitz/scripts/main.sh