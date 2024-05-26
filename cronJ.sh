#!/bin/bash


prompt_for_input() {
  read -p "Enter minute (0-59): " minute
  read -p "Enter hour (0-23): " hour
  read -p "Enter day of month (1-31): " day_of_month
  read -p "Enter month (1-12): " month
  read -p "Enter day of week (0-6, Sunday=0): " day_of_week
  read -p "Enter command to execute: " command

  cron_job="$minute $hour $day_of_month $month $day_of_week $command"
}


prompt_for_input


echo "The cron job you entered is: $cron_job"
read -p "Do you want to add this cron job? (y/n): " confirm

if [ "$confirm" = "y" ]; then
  # Check if the cron job already exists and add it if it doesn't
  (crontab -l | grep -Fxq "$cron_job") || (crontab -l; echo "$cron_job") | crontab -
  echo "Cron job added successfully."
else
  echo "Cron job not added."
fi
