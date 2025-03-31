````markdown
# Commit Wizard 🧙♂️

A modern, interactive Git workflow assistant and real-time feedback.

## Features ✨

- **Hybrid Navigation System**  
  `1-9` for direct selection + `s/a/p/r/q` quick-access letters
- **Smart File Handling**  
  Stage/commit individual files or all changes
- **Auto-Refresh Status**  
  Real-time repository state tracking
- **Color-Coded UI**  
  Visual feedback with intuitive symbols
- **Error Prevention**  
  Input validation & operation confirmation
- **Cross-Platform**  
  Works on Linux/macOS/WSL

## Installation ⚡

```bash
# Download script
curl -O https://raw.githubusercontent.com/injustice-x/commit-wizard/main/commit-wizard.sh

# Make executable
chmod +x commit-wizard.sh

# Run (from Git repo)
./commit-wizard.sh
```
````

## Usage 🕹️

### Main Menu

```
[1-9] Select file number
[s] Stage files    [a] Commit All
[p] Push           [r] Refresh
[q] Quit
```

### Key Shortcuts

| Key | Action               | Context   |
| --- | -------------------- | --------- |
| `s` | Stage specific files | Main menu |
| `a` | Commit all changes   | Main menu |
| `p` | Push to remote       | Main menu |
| `c` | Confirm selection    | File menu |
| `b` | Back                 | Sub-menus |

## Example Workflow 📋

1. **Stage files**

```bash
Press s → Select files with 1-9 → c to confirm
```

2. **Write commit message**

```
? Commit message: Add new user auth flow
```

3. **Push changes**

```
Press p → Pushing to main...
```

## Technical Requirements ⚙️

- Bash 4.0+
- Git 2.20+
- Unix-like environment (Linux/macOS/WSL)

## Contributing 🤝

Found a bug? Want new features?

1. [Open Issue](https://github.com/yourusername/git-wizard/issues)
2. Discuss proposal
3. Submit PR

## License 📜

MIT License - See [LICENSE](LICENSE)

