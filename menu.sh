#!/bin/bash

# 5/26/2024 WROG208 \ N4ASS
# www.lonewolfsystem.org

show_menu() {
    dialog --clear --backtitle "" \
       --title "WROG208 / N4ASS"\
       --menu "Extras Menu Choose an option:" \
       20 60 10 \
       1 "Script to make sound files from Text" \
       2 "Script to make CRON jobs" \
       3 "Script to update Database" \
       4 "Script to Current CPU stats" \
       5 "Script to Reboot the Pi" \
       6 "Script to Run the First Time script" \
       7 "Exit" \
       3>&1 1>&2 2>&3
}

confirm_choice() {
    dialog --clear --title "Confirmation" --yesno "Are you sure about what you are doing?" 7 60
    return $?
}

display_info() {
    local choice=$1
    case $choice in
        1)
            dialog --msgbox "This script will use Text to create sound files based on the specified parameters. In English Or Spanish" 7 60
            ;;
        2)
            dialog --msgbox "This script will create CRON jobs to automate tasks. DON'T USE IT IF YOU DON'T KNOW WHAT YOU ARE DOING!!!!" 7 60
            ;;
        3)
            dialog --msgbox "This script will update the database with the latest NODE data. Use when you have the NODE not in the database on your Supermon." 7 60
            ;;
        4)
            dialog --msgbox "This script will tell you the Current CPU stats." 7 60
            ;;
        5)
            dialog --msgbox "This script will Reboot the Pi." 7 60
            ;;
        6)
            dialog --msgbox "This script will run the First Time script that was used to set up the node the first time." 7 60
            ;;
        7)
            dialog --msgbox "Goodbye..." 5 40
            exit 0  
            ;;
        *)
            dialog --msgbox "Invalid choice, please select a valid option." 7 60
            ;;
    esac
}

execute_choice() {
    local choice=$1
    case $choice in
        1)
            dialog --infobox "Running Script to make sound files..." 5 50
            gsmbi.py
            ;;
        2)
            dialog --infobox "Running Script to make CRON jobs..." 5 50
            cronJ.sh
            ;;
        3)
            dialog --infobox "Running Script to update the database..." 5 50
            astdb.php
            ;;
        4)
            dialog --infobox "Running Script Current CPU stats..." 5 50
            cpu_stats.sh
            ;;
        5)
            dialog --infobox "Running Script to Reboot the Pi..." 5 50
            reboot.sh
            ;;
        6)
            dialog --infobox "Running Script First Time..." 5 50
            firsttime.sh
            ;;
        7)
            dialog --infobox "Goodbye..." 5 40
            exit 0 
            ;;
        *)
            dialog --msgbox "Invalid choice, please select a valid option." 7 60
            ;;
    esac
}

while true; do
    CHOICE=$(show_menu)
    if [[ -n $CHOICE ]]; then
        display_info $CHOICE
        if [[ $CHOICE -eq 2 ]]; then
            if confirm_choice; then
                execute_choice $CHOICE
            else
                dialog --msgbox "Returning to menu..." 5 40
            fi
        else
            execute_choice $CHOICE
        fi
    else
        clear
        exit 0
    fi
done
