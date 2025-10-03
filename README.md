# backup-vscodium
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ask Me Anything !](https://img.shields.io/badge/Ask%20me-anything-1abc9c.svg)](https://GitHub.com/knowoneactual/backup-vscodium/issues)
[![Work in Progress](https://img.shields.io/badge/WIP-Work%20in%20Progress-blue)](https://GitHub.com/knowoneactual/backup-vscodium)


A simple set of shell scripts to back up and restore VSCodium settings on macOS and Linux.

## ⚠️ Early Development

**Warning:** This project is in its early stages. The scripts have not been thoroughly tested and could have unexpected issues. Please use at your own risk and make sure you have backups of your backups. :)

## Method

This tool works by copying the essential VSCodium configuration files and generating a list of your installed extensions. It does not use any cloud services or external accounts.

### What it Backs Up

  * `settings.json`
  * `keybindings.json`
  * All of your snippets
  * A list of your installed extensions

## License

This project is licensed under the MIT License. See the [LICENSE](https://www.google.com/search?q=LICENSE) file for details.