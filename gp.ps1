# Check Internet Connectivity
Try {
    Test-Connection ipgvpn.domain.com -Count 2 -ErrorAction Stop | Out-Null
    Write-Host "Internet connectivity check passed." -ForegroundColor Green
} Catch {
    Write-Host "Internet connectivity check failed. Please check your network connection." -ForegroundColor Red
    Exit
}

# Restart GlobalProtect Service
Try {
    Restart-Service -Name "PanGPS" -Force -ErrorAction Stop
    Start-Sleep -Seconds 5 # Wait for the service to restart
    Write-Host "GlobalProtect service restarted successfully." -ForegroundColor Green
} Catch {
    Write-Host "Failed to restart GlobalProtect service. Please restart the service manually." -ForegroundColor Red
}

# Check GlobalProtect Version (Simplified Example)
# Note: This step assumes you know the latest version number, which in real-world scenarios, might require dynamic checking from an official source.
$latestVersion = "6.1.2-83" # Example version
$currentVersion = (Get-Item "C:\Program Files\Palo Alto Networks\GlobalProtect\PanGPA.exe").VersionInfo.ProductVersion
If ($currentVersion -eq $latestVersion) {
    Write-Host "GlobalProtect is up to date." -ForegroundColor Green
} Else {
    Write-Host "GlobalProtect is not up to date. Current version: $currentVersion, Latest version: $latestVersion" -ForegroundColor Yellow
}

# Updated part to search the entire GlobalProtect log

$logPath = "C:\Program Files\Palo Alto Networks\GlobalProtect\PanGPS.log"
#$issuerCheckString = "DomainAndUsername " # Replace with the actual issuer string you're looking for
$failedAuthString = "portal status is User authentication failed." # This is another string to check for
$twoDaysAgo = (Get-Date).AddDays(-2)

If (Test-Path $logPath) {
    $logEntries = Get-Content $logPath | Where-Object {
        # Use regex to extract the date and time part directly
        if ($_ -match '\d{2}/\d{2}/\d{2} \d{2}:\d{2}:\d{2}') {
            $dateString = $Matches[0]
            try {
                # Adjust the format string to match the date and time format in your logs
                $parsedDate = [datetime]::ParseExact($dateString, "MM/dd/yy HH:mm:ss", $null)
                return $parsedDate -ge $twoDaysAgo
            } catch {
                return $false # Skip entries that cannot be parsed into a date
            }
        } else {
            return $false # Skip entries that don't match the expected pattern
        }
    }
    # Now $logEntries contains only the log lines from the last 2 days
    
    # Search for "Failed to GetPortalCcCert"
    $failedCertErrors = $logEntries | Select-String "Failed to GetPortalCcCert" -SimpleMatch
    If ($failedCertErrors) {
        Write-Host "Found issues with portal certificate retrieval in the last 2 days:" -ForegroundColor Red
        $failedCertErrors | ForEach-Object { Write-Host $_.Line }
    } Else {
        Write-Host "No issues with portal certificate retrieval found in the last 2 days." -ForegroundColor Green
    }
    
    # Check for issuer match - example check, adjust logic as needed
    #$issuerErrors = $logEntries | Where-Object { $_ -like "*$issuerCheckString*" }
    #If ($issuerErrors) {
    #    Write-Host "Found issues with certificate issuer in the last 2 days:" -ForegroundColor Red
     #   $issuerErrors | ForEach-Object { Write-Host $_ }
   # }
    
    # Check for failed authentication
    $authErrors = $logEntries | Select-String $failedAuthString -SimpleMatch
    If ($authErrors) {
        Write-Host "Found failed authentication attempts in the last 2 days:" -ForegroundColor Red
        $authErrors | ForEach-Object { Write-Host $_.Line }
    } Else {
        Write-Host "No failed authentication attempts found in the last 2 days." -ForegroundColor Green
    }
    
} Else {
    Write-Host "GlobalProtect log file not found." -ForegroundColor Yellow
}
# Additional check for "pan_gp_event.log" for unauthorized access errors
$eventLogPath = "C:\Program Files\Palo Alto Networks\GlobalProtect\pan_gp_event.log" # Adjust the path as necessary
$unauthorizedAccessError = "You are not authorized to connect to GlobalProtect Portal"
$twoDaysAgo = (Get-Date).AddDays(-2)

If (Test-Path $eventLogPath) {
    $eventLogEntries = Get-Content $eventLogPath | Where-Object {
        # Adjusting regex to match the new date format and including milliseconds
        if ($_ -match '\d{1,2}/\d{2}/\d{4} \d{2}:\d{2}:\d{2}:\d{3}') {
            $dateString = $Matches[0]
            try {
                # Adjusting the format string to match the date and time format in "pan_gp_event.log"
                $parsedDate = [datetime]::ParseExact($dateString, "M/dd/yyyy HH:mm:ss:fff", $null)
                return $parsedDate -ge $twoDaysAgo
            } catch {
                return $false # Skip entries that cannot be parsed into a date
            }
        } else {
            return $false # Skip entries that don't match the expected pattern
        }
    }

    # Search for unauthorized access errors in the last 2 days
    $unauthorizedErrors = $eventLogEntries | Select-String -Pattern $unauthorizedAccessError -SimpleMatch
    If ($unauthorizedErrors) {
        Write-Host "Found unauthorized access errors in the last 2 days in `pan_gp_event.log`:" -ForegroundColor Red
        $unauthorizedErrors | ForEach-Object { Write-Host $_.Line }
    } Else {
        Write-Host "No unauthorized access errors found in the last 2 days in `pan_gp_event.log`." -ForegroundColor Green
    }
} Else {
    Write-Host "`pan_gp_event.log` file not found." -ForegroundColor Yellow
}