# backup-vscodium

[![Project Status: Development](https://img.shields.io/badge/Project%20Status-Development-blueviolet)](https://github.com/knowoneactual/backup-vscodium)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ask Me Anything !](https://img.shields.io/badge/Ask%20me-anything-1abc9c.svg)](https://GitHub.com/knowoneactual/backup-vscodium/issues)

A simple set of shell scripts to back up and restore VSCodium settings on **macOS** and **Linux**.

VSCodium is a fantastic, fully open-source build of VS Code. Its one missing piece is the built-in Settings Sync, which requires a Microsoft account. This project provides a simple, local-first alternative.

---

## ⚠️ Early Development

**Warning:** This project is in its early stages. The scripts have not been thoroughly tested and could have unexpected issues. Please **use at your own risk** and always back up your backups!

---

## What it Backs Up

This tool finds your VSCodium configuration and copies:
* `settings.json` (Your settings)
* `keybindings.json` (Your custom shortcuts)
* `snippets/` (All your user snippets)
* A list of your installed extensions (saved to `extensions.txt`)

## Requirements

1.  VSCodium must be installed.
2.  The `codium` command must be available in your system's `PATH`. This is how the script lists your extensions.

## How to Use

1.  **Clone or Download**
    ```sh
    git clone https://github.com/knowoneactual/backup-vscodium.git
    cd backup-vscodium
    ```

2.  **Make the Scripts Executable**
    ```sh
    chmod +x backup-codium.sh
    chmod +x restore-codium.sh
    ```

3.  **Run the Backup**
    ```sh
    ./backup-codium.sh
    ```
    This will create a `VSCodium_Backup` folder in your `~/Documents` directory.

4.  **Run the Restore**
    To restore on a new machine, move your `VSCodium_Backup` folder over and run:
    ```sh
    ./restore-codium.sh
    ```
    This will copy all your settings back and reinstall your extensions. You'll need to restart VSCodium.

## How It Works

These scripts automatically detect your operating system (`uname`) to find the correct VSCodium configuration directory.

* **macOS Path:** `~/Library/Application Support/VSCodium`
* **Linux Path:** `~/.config/VSCodium`

This allows the same scripts to work on both platforms without any changes.

## 🤝 Contributing

Contributions are welcome! If you have a suggestion or find a bug, please [open an issue](https://github.com/knowoneactual/backup-vscodium/issues) to discuss it.

See the [CONTRIBUTING.md](CONTRIBUTING.md) file for more details.

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
