# Mautic Cleanup Script

This repository contains a Bash script (`3_mautic_cleanup.sh`) designed to clean up and optimize a Mautic installation by fixing file permissions, clearing cache, and regenerating assets.

## Overview

The script performs the following operations:
- Clears the Mautic cache
- Fixes file and directory permissions
- Sets proper ownership
- Warms up the cache
- Regenerates Mautic assets

## Prerequisites

- SSH access to your server
- Bash shell
- Mautic installation (version compatible with the commands used)
- PHP CLI available in PATH
- Proper user permissions to execute the script and modify Mautic files

## Configuration

Before running the script, you must update the variables at the top of the file:

### Variables

- `PATH_PUBLIC`: The absolute path to your Mautic installation root directory.
  - **Note**: Set this to the root directory of your Mautic installation.
  - If Mautic is installed in the root of your web directory (e.g., `public_html`), use the full path to that directory (e.g., `/home/username/public_html`).
  - If Mautic is installed in a subfolder (e.g., `public_html/mautic`), use the full path to the subfolder (e.g., `/home/username/public_html/mautic`).
- `OWNER`: The system user that should own the Mautic files (usually your web server user or the user that runs PHP).

### Example Configurations

#### Root Installation
```bash
PATH_PUBLIC='/home/username/public_html'
OWNER='username'
```

#### Subfolder Installation
```bash
PATH_PUBLIC='/home/username/public_html/mautic'
OWNER='username'
```

## Usage

1. Connect to your server via SSH:
   ```bash
   ssh username@your-server.com
   ```

2. Navigate to the directory containing the script:
   ```bash
   cd /path/to/shell-scripts
   ```

3. Make the script executable (if not already):
   ```bash
   chmod +x 3_mautic_cleanup.sh
   ```

4. Edit the script to set your variables:
   ```bash
   nano 3_mautic_cleanup.sh
   ```
   Update `PATH_PUBLIC` and `OWNER` as described above.

5. Run the script:
   ```bash
   ./3_mautic_cleanup.sh
   ```

## What the Script Does

### 1. Cache Clearing
- Removes all files in `var/cache/` directory
- Alternative: The script includes a commented line for using `php bin/console cache:clear` if preferred

### 2. Permission Fixes
- Sets directories to 755 permissions
- Sets files to 644 permissions
- Grants group write permissions to:
  - `var/cache/`
  - `var/logs/`
  - `app/config/`
  - `media/files/`
  - `media/images/`
  - `translations/`

### 3. Ownership
- Changes ownership of all files and directories to `${OWNER}:${OWNER}`

### 4. Cache Warmup
- Runs `php bin/console cache:warmup` to rebuild the cache

### 5. Asset Generation
- Runs `php bin/console mautic:assets:generate` to regenerate Mautic assets

## Safety Precautions

- **Backup First**: Always backup your Mautic installation before running this script
- **Test in Staging**: Run the script in a staging environment first
- **Verify Paths**: Double-check `PATH_PUBLIC` and `OWNER` values
- **Permissions**: Ensure the user running the script has appropriate permissions

## Troubleshooting

### Common Issues

1. **"PATH_PUBLIC directory does not exist"**
   - Verify the path in `PATH_PUBLIC` is correct
   - Check if you're using absolute paths

2. **"OWNER user does not exist"**
   - Verify the username in `OWNER` exists on the system
   - Use `id username` to check

3. **Permission Denied**
   - Ensure you're running the script as a user with sudo access if needed
   - Check file ownership and permissions

4. **PHP Command Not Found**
   - Ensure PHP CLI is installed and in PATH
   - Use full path to PHP if necessary (e.g., `/usr/bin/php`)

5. **Mautic Console Commands Fail**
   - Verify Mautic installation is complete
   - Check PHP version compatibility
   - Ensure you're in the correct directory

### Debug Mode

To run with verbose output, you can modify the script temporarily by removing `set -euo pipefail` or adding debug flags.

## Best Practices

- Run this script after Mautic updates
- Execute periodically for maintenance
- Monitor disk space before and after cache clearing
- Keep the script updated with your Mautic version

## Version History

- Initial version: Basic cleanup script
- Updated: Added error handling, input validation, and improved documentation

## Support

For issues specific to Mautic, refer to the [official Mautic documentation](https://docs.mautic.org/).

## License

This script is provided as-is. Please review and test thoroughly before use in production.