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
    echo -e "${YELLOW}1)${NC} Commit specific file(s)"
    echo -e "${YELLOW}2)${NC} Commit all files"
    echo -e "${YELLOW}3)${NC} Refresh file list"
    echo -e "${YELLOW}4)${NC} Push commits"
    echo -e "${YELLOW}5)${NC} Exit"
    read -p "$(echo -e ${BLUE}Enter your choice [1-5]: ${NC})" choice

    case "$choice" in
        1)
            # List files with numbers for selection.
            echo -e "${CYAN}Select files to commit (separate multiple with spaces or commas):${NC}"
            for i in "${!changed_files[@]}"; do
                printf "${YELLOW}%d)${NC} %s\n" "$((i+1))" "${changed_files[i]}"
            done
            read -p "$(echo -e ${BLUE}Enter file numbers: ${NC})" file_choice_input

            # Process input into array of indices
            IFS=', ' read -ra selected_indices <<< "$file_choice_input"
            valid_files=()
            for index in "${selected_indices[@]}"; do
                if [[ "$index" =~ ^[0-9]+$ ]] && (( index >= 1 && index <= ${#changed_files[@]} )); then
                    valid_files+=("${changed_files[$((index-1))]}")
                else
                    echo -e "${RED}${WARNING_ICON} Invalid file number: $index. Skipping.${NC}"
                fi
            done

            if [ ${#valid_files[@]} -eq 0 ]; then
                echo -e "${RED}${WARNING_ICON} No valid files selected.${NC}"
                continue
            fi

            # Commit each selected file
            for file in "${valid_files[@]}"; do
                echo -e "${CYAN}Processing file: ${MAGENTA}$file${NC}"
                commit_file "$file"
                # Refresh the file list after each commit
                fetch_changed_files
                if [ ${#changed_files[@]} -eq 0 ]; then
                    echo -e "${GREEN}${CHECK_MARK} All changes have been committed.${NC}"
                    exit 0
                fi
            done
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
            # Check if remote 'origin' exists
            if ! git remote get-url origin > /dev/null 2>&1; then
                echo -e "${RED}${CROSS_MARK} Error: No remote 'origin' configured.${NC}"
                continue
            fi

            # Confirm with user
            read -p "$(echo -e ${YELLOW}Are you sure you want to push commits to the remote repository? [y/N]: ${NC})" confirm_push
            if [[ "$confirm_push" =~ ^[Yy]$ ]]; then
                echo -e "${CYAN}Pushing commits to remote...${NC}"
                git push
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}${CHECK_MARK} Successfully pushed commits.${NC}"
                else
                    echo -e "${RED}${CROSS_MARK} Failed to push commits. Check your network or permissions.${NC}"
                fi
            else
                echo -e "${CYAN}Pushing canceled.${NC}"
            fi
            ;;
        5)
            echo -e "${CYAN}Exiting the interactive commit tool. Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}${WARNING_ICON} Invalid choice. Please try again.${NC}"
            ;;
    esac
done
