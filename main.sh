#!/usr/bin/env bash

# Color Definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Symbols
CHECK="✔"
CROSS="✖"
ARROW="➤"
INDICATOR="●"

# Configuration
MAX_BRANCH_DISPLAY=10

# Initialize Git Checks
init_git_checks() {
    if ! git rev-parse --is-inside-work-tree &> /dev/null; then
        echo -e "${RED}${CROSS} Error: Not a Git repository${NC}"
        exit 1
    fi
}

current_branch() {
    git branch --show-current
}

fetch_changed_files() {
    mapfile -t changed_files < <(git status --porcelain | awk '{if ($1 != "??") print $2}')
}

show_header() {
    clear
    echo -e "${CYAN}════════════════════════════════════"
    echo -e " GIT WIZARD - $(current_branch)"
    echo -e "════════════════════════════════════${NC}"
}

show_files_status() {
    if [[ ${#changed_files[@]} -gt 0 ]]; then
        echo -e "\n${CYAN}Changed files:${NC}"
        for file in "${changed_files[@]}"; do
            echo -e "  ${MAGENTA}${file}${NC}"
        done
    else
        echo -e "\n${GREEN}${CHECK} No uncommitted changes${NC}"
    fi
}

main_menu() {
    show_header
    show_files_status
    
    echo -e "\n${BLUE}Quick Actions:${NC}"
    echo -e "  ${YELLOW}[s]${NC} Stage & commit specific files"
    echo -e "  ${YELLOW}[a]${NC} Commit all changes"
    echo -e "  ${YELLOW}[p]${NC} Push commits"
    echo -e "  ${YELLOW}[r]${NC} Refresh status"
    echo -e "  ${YELLOW}[q]${NC} Quit"
    
    echo -e "\n${YELLOW}${ARROW} Select action (s/a/p/r/q): ${NC}"
}

commit_file() {
    local file="$1"
    git add "$file" || return 1
    echo -e "${BLUE}${INDICATOR} Staged: ${MAGENTA}${file}${NC}"
    
    while true; do
        read -rp "$(echo -e "${YELLOW}${ARROW} Commit message (q to cancel): ${NC}")" msg
        [[ "$msg" == "q" ]] && return 2
        [ -n "$msg" ] && break
        echo -e "${RED}${CROSS} Message cannot be empty${NC}"
    done
    
    if git commit -m "$msg" "$file"; then
        echo -e "${GREEN}${CHECK} Committed successfully${NC}"
        return 0
    else
        echo -e "${RED}${CROSS} Commit failed${NC}"
        return 1
    fi
}

file_selection_menu() {
    while true; do
        show_header
        echo -e "${CYAN}Select files:${NC}"
        echo -e "${YELLOW}[1-9]${NC} Select file number"
        echo -e "${YELLOW}[c]${NC} Confirm selection"
        echo -e "${YELLOW}[b]${NC} Back to main\n"
        
        for i in "${!changed_files[@]}"; do
            printf "  ${YELLOW}%d)${NC} %s\n" "$((i+1))" "${changed_files[i]}"
        done
        
        read -p "$(echo -e "\n${YELLOW}${ARROW} Select files: ${NC}")" selection
        
        case $selection in
            [1-9])
                index=$((selection-1))
                if [[ -n "${changed_files[$index]}" ]]; then
                    commit_file "${changed_files[$index]}"
                    read -n1 -p "Press any key to continue..."
                fi
                ;;
            c|C)
                return 0
                ;;
            b|B)
                return 1
                ;;
            *)
                echo -e "${RED}Invalid selection${NC}"
                sleep 1
                ;;
        esac
    done
}

push_handler() {
    local target_branch
    target_branch=$(current_branch)
    echo -e "\n${CYAN}${INDICATOR} Pushing to ${MAGENTA}${target_branch}${CYAN}...${NC}"
    
    if git push origin "${target_branch}"; then
        echo -e "${GREEN}${CHECK} Push successful${NC}"
    else
        echo -e "${RED}${CROSS} Push failed${NC}"
    fi
    sleep 2
}

init_git_checks
trap 'echo -e "\n${RED}${CROSS} Operation cancelled${NC}"; exit 1' SIGINT

while true; do
    fetch_changed_files
    main_menu
    
    read -n1 action
    echo  # Add newline after input
    
    case $action in
        s|S)
            if [[ ${#changed_files[@]} -eq 0 ]]; then
                echo -e "${YELLOW}No files to commit${NC}"
                sleep 1
                continue
            fi
            file_selection_menu
            ;;
            
        a|A)
            [[ ${#changed_files[@]} -eq 0 ]] && continue
            echo -e "\n${CYAN}Committing all changes...${NC}"
            git add -A
            
            while true; do
                read -rp "$(echo -e "${YELLOW}${ARROW} Commit message (q to cancel): ${NC}")" msg
                [[ "$msg" == "q" ]] && { git reset; break; }
                [ -n "$msg" ] && break
                echo -e "${RED}Message cannot be empty${NC}"
            done
            
            git commit -m "$msg" && echo -e "${GREEN}All changes committed${NC}"
            sleep 1
            ;;
            
        p|P)
            if ! git remote | grep -q 'origin'; then
                echo -e "${RED}No remote 'origin' configured${NC}"
                sleep 2
                continue
            fi
            push_handler
            ;;
            
        r|R)
            fetch_changed_files
            echo -e "\n${GREEN}Status refreshed${NC}"
            sleep 1
            ;;
            
        q|Q)
            echo -e "\n${CYAN}Exiting... Happy coding! 🚀${NC}"
            exit 0
            ;;
            
        *)
            echo -e "${RED}Invalid option${NC}"
            sleep 1
            ;;
    esac
done
