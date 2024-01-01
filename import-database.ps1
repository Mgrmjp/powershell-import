$MYSQL_PATH = "C:\wamp64\bin\mariadb\mariadb11.2.2\bin\mysql.exe"
$DB_USER = ""
$DB_PASSWORD = ""
$DB_NAME = ""
$SQL_PATH = "C:\wamp64\www\site\database\XXXX.sql"
$ERROR_LOG = "$env:USERPROFILE\Desktop\error.log"

$SEARCH_TARGET = 'https://site.fi'
$REPLACE_TARGET = 'http://localhost/site'
$SKIP_COLUMNS = '--skip-columns=guid'
$TABLES_PREFIX = '--all-tables-with-prefix'

$WP_CLI_COMMAND = "wp search-replace '$SEARCH_TARGET' '$REPLACE_TARGET' $SKIP_COLUMNS $TABLES_PREFIX"

function Write-Host-Color {
    param(
        [string]$Message
    )

    $DEFAULT_FOREGROUND_COLOR = $Host.UI.RawUI.ForegroundColor
    $DEFAULT_BACKGROUND_COLOR = $Host.UI.RawUI.BackgroundColor

    $Host.UI.RawUI.ForegroundColor = [System.ConsoleColor]::Black
    $Host.UI.RawUI.BackgroundColor = [System.ConsoleColor]::Cyan

    # List of emojis
    $EMOJIS = '😊 ', '🌟 ', '🚀 ', '💡 ', '👍 ', '🌈 '

    # Select a random emoji
    $RANDOM_EMOJI = $EMOJIS | Get-Random

    # Combine the random emoji and the message
    $MESSAGE_WITH_EMOJI = "$RANDOM_EMOJI $Message"

    Write-Host $MESSAGE_WITH_EMOJI

    $Host.UI.RawUI.ForegroundColor = $DEFAULT_FOREGROUND_COLOR
    $Host.UI.RawUI.BackgroundColor = $DEFAULT_BACKGROUND_COLOR
}

# Define the SEARCH_STRING and REPLACE_STRING in uppercase
$SEARCH_STRING = $SEARCH_TARGET
$REPLACE_STRING = $REPLACE_TARGET

# Get the path to the wp-config.php file in the same folder as the script
$FILE_PATH = Join-Path $PSScriptRoot "wp-config.php"

# Check if the file exists
if (Test-Path $FILE_PATH -PathType Leaf) {
    try {
        # Attempt to read the content of the file
        $CONTENT = Get-Content $FILE_PATH -Raw
        Write-Host-Color "File is accessible. Content: $($CONTENT)"

        # Perform search and replace
        $NEW_CONTENT = $CONTENT -replace $SEARCH_STRING, $REPLACE_STRING

        # Write the modified content back to the file
        Set-Content -Path $FILE_PATH -Value $NEW_CONTENT -Force
        Write-Host-Color "Search and replace completed in $($FILE_PATH)"
    } catch {
        Write-Host-Color "Error accessing the file: $_"
    }
} else {
    Write-Host-Color "File does not exist or is not accessible."
}

Write-Host-Color "Trying to connect to MariaDB..."

# Try to connect to MariaDB
Invoke-Expression "$MYSQL_PATH -u$DB_USER -p$DB_PASSWORD -e 'SELECT 1' 2>$ERROR_LOG"
if ($LASTEXITCODE -eq 0) {
    Write-Host-Color "Connection to MariaDB successful."
} else {
    Write-Host-Color "Error: Unable to connect to MariaDB."
    Pause
}

Write-Host-Color "Checking if the database exists..."

# Check if the database exists
Invoke-Expression "$MYSQL_PATH -u$DB_USER -p$DB_PASSWORD -e 'USE $DB_NAME' 2>$ERROR_LOG"

if ($LASTEXITCODE -eq 0) {
    Write-Host-Color "Error: Database $DB_NAME already exists. Script terminated."
    Read-Host "Press Enter to exit..."
    Exit
} else {
    # The database doesn't exist, so create it
    Invoke-Expression "$MYSQL_PATH -v -u$DB_USER -p$DB_PASSWORD -e 'CREATE DATABASE $DB_NAME' 2>$ERROR_LOG"

    if ($LASTEXITCODE -ne 0) {
        Write-Host-Color "Error: Unable to create the database. Check $ERROR_LOG for details."
        Read-Host "Press Enter to exit..."
        Exit
    }
}

Write-Host-Color "Importing the script..."

# Import the script
$PROCESS = Start-Process -FilePath $MYSQL_PATH -ArgumentList "-u$DB_USER", "-p$DB_PASSWORD", "-D$DB_NAME" -RedirectStandardInput $SQL_PATH -Wait -PassThru

# Wait for the process to finish
$PROCESS.WaitForExit()

# Check the exit code
if ($PROCESS.ExitCode -eq 0) {
    Write-Host-Color "Process completed successfully."

    Write-Host-Color "`n`n   Trying to run WP-CLI...`n`n"

    # Check if wp-config.php file exists (common WordPress configuration file)
    if (Test-Path "wp-config.php") {
        # Directory contains WordPress installation
        Write-Host-Color "Current directory is a WordPress installation."

        # Execute the WP_CLI_COMMAND
        Invoke-Expression $WP_CLI_COMMAND
    } else {
        # Directory does not contain WordPress installation
        Write-Host-Color "Current directory is not a WordPress installation."
    }

    Invoke-Expression $WP_CLI_COMMAND

} else {
    Write-Host-Color "Process failed with exit code $($PROCESS.ExitCode)."
}

# Pause to see the console output before closing
Pause
