# Script delete old log uninstall 7zip
$NewestVersion = "24.09"

# Define the registry path for installed applications
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"

# Search for all applications that have a DisplayName starting with '7zip'
$appsToUninstall = Get-ChildItem -Path $regPath | ForEach-Object {
    $app = Get-ItemProperty -Path $_.PSPath

    if ($app.DisplayName -like "7-Zip*" -and $app.DisplayVersion -notlike "$($NewestVersion)*") {
        # Return the application's DisplayName and Uninstall string
        [PSCustomObject]@{
            DisplayName    = $app.DisplayName
            UninstallString = $app.UninstallString
            DisplayVersion = $app.DisplayVersion
            PSChildName = $app.PSChildName
        }
    }
}


# If any apps are found, proceed with uninstallation
if ($appsToUninstall) {
    foreach ($app in $appsToUninstall) {
        Write-Host "Found application: $($app.DisplayName)"
        Write-Host "Uninstalling..."

        # Execute the uninstall command for each application
        # Using Start-Process to run the uninstall command
        try {
            $cmd = "cmd.exe"
            $args = "/c $($app.UninstallString) /quiet"
            #Start-Process -FilePath $cmd -ArgumentList $args -Wait
            Write-Host "$($app.DisplayName) uninstalled successfully."
            $pathRemove = "$($regPath)\$($app.PSChildName)"
            Remove-Item -Path $pathRemove -Recurse -Force
        } catch {
            Write-Host "Error uninstalling $($app.DisplayName): $_"
        }
    }
} else {
    Write-Host "No applications found matching '7-Zip*'."
}
