GitSearch 🔍

Creator: Max Rodriguez (14 years old)

---

🎯 What This Is

A command-line tool that tracks your Git projects so you can find them later.

---

📦 Installation

Step 1: Download

Get GitSearch-v1-beta.zip from Releases

Step 2: Extract

```bash
unzip GitSearch-v1-beta.zip
cd GitSearch-v1-beta
```

Step 3: Install

```bash
chmod +x install.sh
./install.sh
```

Done! Now gitsearch is available in your terminal.

---

🚀 Quick Start

1. Go to your project:

```bash
cd ~/projects/my-project
```

1. Register it:

```bash
gitsearch init "My Project"
```

1. Find it later:

```bash
gitsearch list
gitsearch search "my project"
gitsearch search --code "function main"
```

---

🔧 Commands

Command What it does
gitsearch init [name] Register current folder
gitsearch list Show all tracked projects
gitsearch search <query> Search project names
gitsearch search --code <pattern> Search inside files
gitsearch remove <name> Remove from tracking
gitsearch scan [path] Auto-find Git projects
gitsearch help Show help

---

💡 How It Works

1. Creates ~/.gitsearch/ folder in your home directory
2. Stores projects in projects.txt (simple text file)
3. Each line: project_name|full_path|date_added
4. Searches are just grep commands on that file

---

📁 Project Structure

```
GitSearch/
├── bin/gitsearch          # Main script
├── lib/                   # All functions
│   ├── init.sh
│   ├── list.sh
│   ├── search.sh
│   ├── help.sh
│   ├── remove.sh
│   └── utils.sh
├── docs/HELP.md          # Documentation
├── install.sh            # Installer
└── README.md             # This file
```

---

🛠️ Manual Install (if install.sh missing)

```bash
# Copy main script
sudo cp bin/gitsearch /usr/local/bin/

# Create library directory
sudo mkdir -p /usr/local/lib/gitsearch

# Copy all libraries
sudo cp lib/*.sh /usr/local/lib/gitsearch/

# Make executable
sudo chmod +x /usr/local/bin/gitsearch
```

---

❓ Need Help?

```bash
gitsearch help           # Basic help
gitsearch help commands  # All commands
gitsearch help examples  # Usage examples
```

Or check docs/HELP.md in the extracted folder.

---

📍 Where Files Go

· Projects database: ~/.gitsearch/projects.txt
· Configuration: ~/.gitsearch/config
· Logs: ~/.gitsearch/logs/ (if enabled)

---

That's it! No complex setup, no dependencies, just a simple tool that works.

Made by Max Rodriguez because losing code sucks.
