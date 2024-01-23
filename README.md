# WordPress Database Setup 🪶 and WP-CLI Configuration

## Prerequisites 🍃
- MariaDB or MySQL installed.
- WP-CLI (WordPress Command Line Interface) installed.

## Usage 💻

1. Set the following variables at the beginning of the script:

    - **$MYSQL_PATH**: Path to MariaDB or MySQL executable.
    - **$DB_USER**: Database user.
    - **$DB_PASSWORD**: Database password.
    - **$DB_NAME**: Database name.
    - **$SQL_PATH**: Path to the SQL script to import.
    - **$ERROR_LOG**: Path to the error log file.

    Replace these variables with your specific values.

2. Configure the search and replace parameters for WP-CLI:

    - **$SEARCH_TARGET**: The target string to search for.
    - **$REPLACE_TARGET**: The string to replace the search target.
    - **$TABLES_PREFIX**: Optional parameter to include only tables with a specified prefix during search and replace.

3. Run the script. The script will:

    - Check if the wp-config.php file exists in the same directory.
    - Attempt to perform a search and replace operation in wp-config.php.
    - Connect to MariaDB or MySQL to check for database existence.
    - Create the database if it doesn't exist.
    - Import the SQL script into the database.
    - Execute WP-CLI search and replace command.

TODO:
- PAGE CHECKSUM removal
- PAGE COMPRESSED removal
