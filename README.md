

# GlobalProtect Connectivity and Log Monitoring Script

## Overview
This PowerShell script performs several tasks related to GlobalProtect, including checking internet connectivity, restarting the GlobalProtect service, verifying the GlobalProtect version, and monitoring log files for specific error messages within the last two days.

## Features
- **Internet Connectivity Check:** Verifies connection to a specified domain.
- **Service Restart:** Restarts the GlobalProtect service.
- **Version Check:** Compares the current version of GlobalProtect against a specified latest version.
- **Log Monitoring:** Searches GlobalProtect logs for specific error messages and authentication failures in the last two days.

## Requirements
- **PowerShell 5.1 or higher**
- **Administrative privileges** (required for restarting services and accessing certain log files)

## Usage

1. **Open PowerShell as Administrator:**
   - Right-click on PowerShell and select "Run as Administrator" to ensure the script has the necessary permissions.

2. **Execute the Script:**
   - Navigate to the directory containing the script and run it by typing:
     ```powershell
     .\gp.ps1
     ```

## Script Details

### Internet Connectivity Check
- The script attempts to connect to `vpn.domain.com` twice.
- If successful, it prints a success message; otherwise, it notifies the user to check the network connection and exits.

### Restart GlobalProtect Service
- The script restarts the `PanGPS` service.
- It waits for 5 seconds after restarting and then prints a success or failure message.

### Check GlobalProtect Version
- Compares the current version of `PanGPA.exe` against a specified latest version (`6.1.2-83` in this example).
- Prints whether the GlobalProtect is up to date or not.

### Log Monitoring

#### GlobalProtect Log
- **Log Path:** `C:\Program Files\Palo Alto Networks\GlobalProtect\PanGPS.log`
- **Error Strings:** `Failed to GetPortalCcCert`, `portal status is User authentication failed.`
- The script reads the log entries from the last two days and checks for these error strings.
- Prints the errors found or a message indicating no issues.

#### GlobalProtect Event Log
- **Log Path:** `C:\Program Files\Palo Alto Networks\GlobalProtect\pan_gp_event.log`
- **Error String:** `You are not authorized to connect to GlobalProtect Portal`
- The script reads the log entries from the last two days and checks for unauthorized access errors.
- Prints the errors found or a message indicating no issues.

## Customization

- **Domain for Connectivity Check:**
  - Modify the domain in the `Test-Connection` command.
- **Latest Version Number:**
  - Change the `$latestVersion` variable to reflect the actual latest version.
- **Log Error Strings:**
  - Adjust the error strings (`$failedAuthString`, etc.) as needed.

## Support
For any issues or questions regarding the script, please contact your IT department or the script maintainer.
