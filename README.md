<p align="center">
<img src="assets/img/backup-vscodium_logo.webp" alt="alt text" width="150">
</p>


# backup-vscodium

[![Project Status: Development](https://img.shields.io/badge/Project%20Status-Development-blueviolet)](https://github.com/knowoneactual/backup-vscodium)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ask Me Anything !](https://img.shields.io/badge/Ask%20me-anything-1abc9c.svg)](https://GitHub.com/knowoneactual/backup-vscodium/issues)

A simple set of shell scripts to back up and restore VSCodium settings on **macOS** and **Linux**.

VSCodium is an open-source build of VS Code. Its one missing piece is the built-in Settings Sync, which requires a Microsoft account. This project provides a simple, local-first alternative.

---

🚨 Heads Up: Still in Early Days!

This project is brand new, and the scripts haven't been exhaustively tested yet. Please be aware that there might be unexpected issues, and we recommend you use it at your own risk. Backup your backups :) If you find any issues, please let us know—we're actively working on it!

---

## 💾 What it Backs Up

This tool finds your VSCodium configuration and copies:
* `settings.json` (Your settings)
* `keybindings.json` (Your custom shortcuts)
* `snippets/` (All your user snippets)
* A list of your installed extensions (saved to `extensions.txt`)

## ⚙️ Requirements

1.  VSCodium must be installed.
2.  The `codium` command must be available in your system's `PATH`. This is how the script lists your extensions.

## 🚀 How to Use

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

## 🧠 Curious How It Works?

We wanted the same scripts to work everywhere. The key is that they automatically detect your operating system by checking uname. That way, the script knows exactly where to find the VSCodium configuration directory on either macOS or Linux, and you don't have to worry about the path!

* **macOS Path:** `~/Library/Application Support/VSCodium`
* **Linux Path:** `~/.config/VSCodium`


## 🤝 Contributing

Contributions are welcome! If you have a suggestion or find a bug, please [open an issue](https://github.com/knowoneactual/backup-vscodium/issues) to discuss it.

See the [CONTRIBUTING.md](CONTRIBUTING.md) file for more details.

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
