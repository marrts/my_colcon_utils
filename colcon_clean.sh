function colcon_clean() {
    # ANSI color codes
    yellow='\033[1;33m'
    light_blue='\033[1;34m'
    red='\033[1;31m'
    reset='\033[0m'

    patterns=("$@")
    missing=()
    dirs_to_remove=()

    for pattern in "${patterns[@]}"; do
        build_dirs=$(find build -maxdepth 1 -type d -name "$pattern" -print 2>/dev/null)
        install_dirs=$(find install -maxdepth 1 -type d -name "$pattern" -print 2>/dev/null)
        if [[ -z "$build_dirs" && -z "$install_dirs" ]]; then
            echo -e "${yellow}Warning:${reset} The following patterns did not match any directories: ${light_blue}$pattern${reset}"
            missing+=("$pattern")
        else
            dirs_to_remove+=("$pattern")
        fi
    done

    if [[ "${#patterns[@]}" -gt "${#missing[@]}" ]]; then
        echo -e "The following directories will be ${red}deleted${reset}:"

        for dir_type in "build" "install"; do
            echo -e "  $dir_type/"
            for pattern in "${dirs_to_remove[@]}"; do
                dirs=$(find $dir_type -maxdepth 1 -type d -name "$pattern" -print 2>/dev/null)
                for dir in $dirs; do
                    echo -e "\t${light_blue}$(basename $dir)${reset}"
                done
            done
        done

        read -p "Are you sure you want to remove these directories in build and install? (y/n) " -n 1 -r; echo ""
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            for pattern in "${dirs_to_remove[@]}"; do
                find build -maxdepth 1 -type d -name "$pattern" -exec rm -r {} +
                find install -maxdepth 1 -type d -name "$pattern" -exec rm -r {} +
            done
        fi
    elif [[ "${#patterns[@]}" -eq "${#missing[@]}" && "${#patterns[@]}" -gt 0 ]]; then
        echo -e "${yellow}No packages were found. Nothing will be deleted.${reset}"
    else
        echo -e "Both the ${light_blue}build${reset} and ${light_blue}install${reset} directories will be fully ${red}deleted${reset}."
        read -p "Are you sure you want to remove these? (y/n) " -n 1 -r; echo ""
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -r build install
        fi
    fi
}
