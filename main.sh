#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Symbols
CHECK_MARK="✔"
CROSS_MARK="✖"
INFO_ICON="ℹ️"
WARNING_ICON="⚠️"

# Fancy banner
echo -e "${CYAN}======================================"
echo -e " Commit Wizard"
echo -e "======================================${NC}"
echo ""

# Check if the current directory is inside a Git repository.
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${RED}${CROSS_MARK} Error: This script must be run inside a Git repository.${NC}"
    exit 1
fi

# Function to fetch the list of changed files.
fetch_changed_files() {
    mapfile -t changed_files < <(git status --porcelain | sed 's/^...//')
}

# Function to commit a single file interactively.
commit_file() {
    local file="$1"
    git add "$file"
    echo -e "${BLUE}${INFO_ICON} File staged: ${MAGENTA}$file${NC}"
    read -p "$(echo -e ${YELLOW}Enter commit message for '${file}': ${NC})" commit_msg
    if [ -n "$commit_msg" ]; then
        git commit -m "$commit_msg" "$file"
        echo -e "${GREEN}${CHECK_MARK} Committed: ${MAGENTA}$file${NC}"
    else
        echo -e "${RED}${WARNING_ICON} No commit message provided. Skipping commit for ${MAGENTA}$file${NC}."
    fi
    echo ""
}

# Initial file list retrieval.
fetch_changed_files

# Check if there are any changes to process.
if [ ${#changed_files[@]} -eq 0 ]; then
    echo -e "${GREEN}${CHECK_MARK} No changes found to commit.${NC}"
    exit 0
fi

# Display the list of changed files.
echo -e "${CYAN}Detected changed files:${NC}"
for file in "${changed_files[@]}"; do
    echo -e " - ${MAGENTA}$file${NC}"
done

# Main interactive menu loop.
while true; do
    echo ""
    echo -e "${CYAN}Choose an option:${NC}"
    echo -e "${YELLOW}1)${NC} Commit a specific file"
    echo -e "${YELLOW}2)${NC} Commit all files"
    echo -e "${YELLOW}3)${NC} Refresh file list"
    echo -e "${YELLOW}4)${NC} Exit"
    read -p "$(echo -e ${BLUE}Enter your choice [1-4]: ${NC})" choice

    case "$choice" in
        1)
            # List files with numbers for selection.
            echo -e "${CYAN}Select a file to commit:${NC}"
            for i in "${!changed_files[@]}"; do
                printf "${YELLOW}%d)${NC} %s\n" "$((i+1))" "${changed_files[i]}"
            done
            read -p "$(echo -e ${BLUE}Enter file number: ${NC})" file_choice
            if [[ "$file_choice" =~ ^[0-9]+$ ]] && (( file_choice >= 1 && file_choice <= ${#changed_files[@]} )); then
                selected_file="${changed_files[$((file_choice-1))]}"
                echo -e "${CYAN}You selected: ${MAGENTA}$selected_file${NC}"
                commit_file "$selected_file"
                # Refresh the file list after commit.
                fetch_changed_files
                if [ ${#changed_files[@]} -eq 0 ]; then
                    echo -e "${GREEN}${CHECK_MARK} All changes have been committed.${NC}"
                    exit 0
                fi
            else
                echo -e "${RED}${WARNING_ICON} Invalid selection. Please try again.${NC}"
            fi
            ;;
        2)
            # Commit all files one by one.
            for file in "${changed_files[@]}"; do
                echo -e "${CYAN}Processing file: ${MAGENTA}$file${NC}"
                commit_file "$file"
            done
            echo -e "${GREEN}${CHECK_MARK} All files processed.${NC}"
            exit 0
            ;;
        3)
            # Refresh and display the current file list.
            fetch_changed_files
            if [ ${#changed_files[@]} -eq 0 ]; then
                echo -e "${GREEN}${CHECK_MARK} No pending changes. Exiting.${NC}"
                exit 0
            else
                echo -e "${CYAN}Updated file list:${NC}"
                for file in "${changed_files[@]}"; do
                    echo -e " - ${MAGENTA}$file${NC}"
                done
            fi
            ;;
        4)
            echo -e "${CYAN}Exiting the interactive commit tool. Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}${WARNING_ICON} Invalid choice. Please try again.${NC}"
            ;;
    esac
done

