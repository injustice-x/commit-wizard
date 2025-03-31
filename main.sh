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

# Get current branch
current_branch() {
    git branch --show-current
}

# Fetch changed files
fetch_changed_files() {
    mapfile -t changed_files < <(git status --porcelain | awk '{if ($1 != "??") print $2}')
}

# Commit single file
commit_file() {
    local file="$1"
    if ! git add "$file"; then
        echo -e "${RED}${CROSS} Failed to stage file: ${file}${NC}"
        return 1
    fi
    
    echo -e "${BLUE}${INDICATOR} Staged: ${MAGENTA}${file}${NC}"
    
    while true; do
        read -rp "$(echo -e "${YELLOW}${ARROW} Commit message (q to cancel): ${NC}")" msg
        if [[ "$msg" == "q" ]]; then
            git reset -- "$file"
            echo -e "${YELLOW}Operation cancelled${NC}"
            return 2
        fi
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

# Display branch selector
select_branch() {
    local current_branch="$1"
    mapfile -t branches < <(git for-each-ref --format='%(refname:short)' refs/heads/)
    
    # Display to stderr
    echo -e "\n${CYAN}Available branches:${NC}" >&2
    for ((i=0; i<${#branches[@]} && i<MAX_BRANCH_DISPLAY; i++)); do
        if [[ "${branches[i]}" == "$current_branch" ]]; then
            printf "  ${YELLOW}%2d) %s ${BLUE}(current)${NC}\n" "$((i+1))" "${branches[i]}" >&2
        else
            printf "  ${YELLOW}%2d) %s${NC}\n" "$((i+1))" "${branches[i]}" >&2
        fi
    done
    
    while true; do
        read -rp "$(echo -e "${YELLOW}${ARROW} Select branch [1-${#branches[@]}, default=${current_branch}]: ${NC}")" choice
        [[ -z "$choice" ]] && echo "$current_branch" && return 0
        
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#branches[@]} )); then
            echo "${branches[$((choice-1))]}"
            return 0
        fi
        echo -e "${RED}${CROSS} Invalid selection${NC}" >&2
    done
}

# Push handler
push_handler() {
    local target_branch
    if ! target_branch=$(select_branch "$(current_branch)"); then
        echo -e "${RED}${CROSS} Branch selection failed${NC}"
        return 1
    fi
    
    echo -e "\n${CYAN}${INDICATOR} Pushing to ${MAGENTA}${target_branch}${CYAN}...${NC}"
    if git push origin "${target_branch}"; then
        echo -e "${GREEN}${CHECK} Push successful${NC}"
    else
        echo -e "${RED}${CROSS} Push failed${NC}"
        return 1
    fi
}

# Main interface
main_menu() {
    while true; do
        fetch_changed_files
        local current_branch=$(current_branch)
        
        clear
        echo -e "${CYAN}════════════════════════════════════"
        echo -e " GIT WIZARD - ${current_branch}"
        echo -e "════════════════════════════════════${NC}"
        
        if [[ ${#changed_files[@]} -gt 0 ]]; then
            echo -e "\n${CYAN}Changed files:${NC}"
            for file in "${changed_files[@]}"; do
                echo -e "  ${MAGENTA}${file}${NC}"
            done
        else
            echo -e "\n${GREEN}${CHECK} No uncommitted changes${NC}"
        fi
        
        echo -e "\n${BLUE}Options:${NC}"
        echo -e "  ${YELLOW}1${NC}) Stage & commit files"
        echo -e "  ${YELLOW}2${NC}) Commit all changes"
        echo -e "  ${YELLOW}3${NC}) Push commits"
        echo -e "  ${YELLOW}4${NC}) Refresh status"
        echo -e "  ${YELLOW}5${NC}) Exit"
        
        read -rp "$(echo -e "\n${YELLOW}${ARROW} Select option [1-5]: ${NC}")" choice
        
        case $choice in
            1)
                if [[ ${#changed_files[@]} -eq 0 ]]; then
                    echo -e "${YELLOW}${INDICATOR} No files to commit${NC}"
                    sleep 1
                    continue
                fi
                
                echo -e "\n${CYAN}Select files (comma/space separated):${NC}"
                for i in "${!changed_files[@]}"; do
                    printf "  ${YELLOW}%2d${NC}) %s\n" "$((i+1))" "${changed_files[i]}"
                done
                
                read -rp "$(echo -e "${YELLOW}${ARROW} File numbers: ${NC}")" selections
                mapfile -t selected < <(tr ', ' '\n' <<< "$selections" | grep -v '^$')
                
                for selection in "${selected[@]}"; do
                    if [[ "$selection" =~ ^[0-9]+$ ]] && (( selection >= 1 && selection <= ${#changed_files[@]} )); then
                        commit_file "${changed_files[$((selection-1))]}"
                        sleep 1
                    else
                        echo -e "${RED}${CROSS} Invalid file number: ${selection}${NC}"
                    fi
                done
                ;;
            
            2)
                [[ ${#changed_files[@]} -eq 0 ]] && continue
                echo -e "\n${CYAN}Committing all changes...${NC}"
                git add -A || continue
                
                while true; do
                    read -rp "$(echo -e "${YELLOW}${ARROW} Commit message (q to cancel): ${NC}")" msg
                    [[ "$msg" == "q" ]] && { git reset; break; }
                    [ -n "$msg" ] && break
                    echo -e "${RED}${CROSS} Message cannot be empty${NC}"
                done
                
                git commit -m "$msg" && echo -e "${GREEN}${CHECK} All changes committed${NC}"
                sleep 1
                ;;
            
            3)
                if ! git remote | grep -q 'origin'; then
                    echo -e "${RED}${CROSS} No remote 'origin' configured${NC}"
                    sleep 2
                    continue
                fi
                push_handler
                sleep 2
                ;;
            
            4)
                fetch_changed_files
                echo -e "\n${GREEN}${CHECK} Status refreshed${NC}"
                sleep 1
                ;;
            
            5)
                echo -e "\n${CYAN}Exiting... Happy coding! 🚀${NC}"
                exit 0
                ;;
            
            *)
                echo -e "${RED}${CROSS} Invalid option${NC}"
                sleep 1
                ;;
        esac
    done
}

# Main execution
init_git_checks
trap 'echo -e "\n${RED}${CROSS} Operation cancelled${NC}"; exit 1' SIGINT
main_menu
