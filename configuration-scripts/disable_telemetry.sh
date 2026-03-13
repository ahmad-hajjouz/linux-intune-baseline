#!/bin/bash

# Define the new privacy setting
NEW_PRIVACY_SETTING="Disabled"

# Opt out of Ubuntu telemetry reporting
if command -v ubuntu-report >/dev/null 2>&1; then
    ubuntu-report send no
fi

# Check if the Whoopsie configuration file exists
if [ -f /etc/default/whoopsie ]; then
    # Disable crash reporting
    sed -i 's/^report_crashes=.*/report_crashes=false/' /etc/default/whoopsie

    # Disable metrics reporting
    sed -i 's/^report_metrics=.*/report_metrics=false/' /etc/default/whoopsie
fi

# Check if the Whoopsie service exists
if systemctl list-unit-files | grep -q '^whoopsie.service'; then
    # Stop the Whoopsie service
    systemctl stop whoopsie.service

    # Disable the Whoopsie service
    systemctl disable whoopsie.service
fi

# Show the change
echo "Ubuntu telemetry and crash reporting have been disabled"