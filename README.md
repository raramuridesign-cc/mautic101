# Mautic101

A collection of automation scripts and tools to enhance and maintain Mautic installations.

## Project Structure

This repository is organized into the following folders:

- **[shell-scripts](shell-scripts/README.md)** - Bash scripts for Mautic server maintenance, cleanup, and optimization
- **[cloudflare-workers](cloudflare-workers/README.md)** - Cloudflare Worker scripts for integrating with Mautic

Each folder contains its own README with detailed documentation, usage instructions, and configuration guides.

## Important Safety Notice

⚠️ **Always test these scripts in a staging environment before deploying to production.**

These tools can make significant changes to your Mautic installation. Ensure you have:
- Recent backups of your Mautic database and files
- Access to restore functionality
- Understanding of what each script does

## Contributing

We welcome contributions! If you find issues or have improvements:

- Submit an issue report for bugs or feature requests
- Open a pull request for code improvements
- Check individual folder READMEs for specific contribution guidelines

## Requirements

- Mautic installation (version compatibility varies by script)
- Appropriate server access (SSH for shell scripts, Cloudflare account for workers)
- Basic understanding of command-line operations

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Disclaimer

These scripts are provided "as is" without warranty. Use at your own risk. The maintainers are not responsible for any damage or data loss resulting from the use of these tools.

