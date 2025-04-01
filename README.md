# Git Wizard

Git Wizard is an interactive Bash script designed to streamline your Git workflow. It provides a user-friendly interface to view changed files, inspect diffs before committing, stage specific files, commit changes with custom messages, push commits to a remote repository, and refresh your working status—all with colorful, easy-to-read output.

## Features

- **Interactive Menu:** Quickly choose actions like staging specific files, committing all changes, pushing commits, or refreshing the Git status.
- **Diff Preview:** Before committing a file, view its Git diff to see what changes you are about to commit.
- **Custom Commit Messages:** Prompt for a commit message with the ability to cancel the operation.
- **Colored Output:** Uses colored text and symbols for better readability and clarity.
- **Error Handling:** Checks if the current directory is a valid Git repository and handles common Git errors.

## Prerequisites

- **Git:** Ensure Git is installed and available in your system's PATH.
- **Bash:** The script is written for Bash. Make sure you're running it in an environment that supports Bash scripts.

## Installation

1. **Clone the repository:**

   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Make the script executable:**

   ```bash
   chmod +x git-wizard.sh
   ```

3. **Run the script:**

   ```bash
   ./git-wizard.sh
   ```

## Usage

When you run the script inside a Git repository, you will see an interactive menu:

- **Main Menu Options:**

  - **[s] Stage & Commit Specific Files:**  
    Select this option to choose individual files for staging and committing. The script will display the Git diff for the selected file before prompting for a commit message.
  - **[a] Commit All Changes:**  
    This option stages and commits all uncommitted changes in one go.
  - **[p] Push Commits:**  
    Pushes your commits to the remote repository on the current branch. The script checks if the remote `origin` is configured.
  - **[r] Refresh Status:**  
    Refreshes the current Git status to display the latest changes.
  - **[q] Quit:**  
    Exits the Git Wizard script.

- **File Selection Menu:**
  - When selecting specific files (option **s**), you can choose files by their displayed number.
  - After a file is selected, its changes are shown using `git diff`.
  - You will then be prompted to enter a commit message. You can cancel this process by entering `q`.

## Customization

- **Color and Symbol Settings:**  
  Modify the color variables (`RED`, `GREEN`, etc.) and symbols (`CHECK`, `CROSS`, etc.) at the beginning of the script to customize the look and feel.
- **Branch Display Limit:**  
  Change the `MAX_BRANCH_DISPLAY` variable if you need to adjust how many branches are shown.

## Troubleshooting

- **Not a Git Repository:**  
  If you run the script outside a Git repository, it will display an error and exit.
- **Push Failures:**  
  Ensure that the remote `origin` is correctly set up if you encounter issues when pushing commits.
- **Empty Commit Messages:**  
  The script does not allow empty commit messages. Make sure to provide a meaningful message when prompted.

## Contributing

Contributions are welcome! Feel free to fork the repository and submit pull requests for improvements or bug fixes.
