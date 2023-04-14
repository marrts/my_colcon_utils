function ros2_source() {
    # ANSI color codes
    green='\033[1;32m'
    yellow='\033[1;33m'
    red='\033[1;31m'
    reset='\033[0m'

    current_dir=$(pwd)

    while true; do
        # Check for src, build, and install directories in the current directory
        if [[ -d "$current_dir/src" && -d "$current_dir/build" && -d "$current_dir/install" ]]; then
            setup_file="$current_dir/install/setup.bash"

            if [[ -f "$setup_file" ]]; then
                source "$setup_file"
                echo -e "${green}Sourced ROS2 workspace:${reset} $current_dir"
                return 0
            else
                echo -e "${red}Error:${reset} Could not find setup.bash in the install directory."
                return 1
            fi
        fi

        # If we've reached the root directory, stop searching
        if [[ "$current_dir" == "/" ]]; then
            break
        fi

        # Move up to the parent directory
        current_dir=$(dirname "$current_dir")
    done

    echo -e "${yellow}Error:${reset} Could not find a valid ROS2 workspace in any parent directory."
    return 1
}

function ros1_source() {
    # ANSI color codes
    green='\033[1;32m'
    yellow='\033[1;33m'
    red='\033[1;31m'
    reset='\033[0m'

    current_dir=$(pwd)

    while true; do
        # Check for src and devel directories in the current directory
        if [[ -d "$current_dir/src" && -d "$current_dir/devel" ]]; then
            setup_file="$current_dir/devel/setup.bash"

            if [[ -f "$setup_file" ]]; then
                source "$setup_file"
                echo -e "${green}Sourced ROS1 workspace:${reset} $current_dir"
                return 0
            else
                echo -e "${red}Error:${reset} Could not find setup.bash in the devel directory."
                return 1
            fi
        fi

        # If we've reached the root directory, stop searching
        if [[ "$current_dir" == "/" ]]; then
            break
        fi

        # Move up to the parent directory
        current_dir=$(dirname "$current_dir")
    done

    echo -e "${yellow}Error:${reset} Could not find a valid ROS1 workspace in any parent directory."
    return 1
}

function add_workspace_alias() {
    current_dir=$(pwd)

    # Find the workspace directory by searching for src and devel/build+install directories
    while true; do
        if [[ -d "$current_dir/src" && (-d "$current_dir/devel" || (-d "$current_dir/build" && -d "$current_dir/install")) ]]; then
            break
        fi

        # If we've reached the root directory, stop searching
        if [[ "$current_dir" == "/" ]]; then
            echo -e "${red}Error:${reset} Could not find a valid ROS1 or ROS2 workspace in any parent directory."
            return 1
        fi

        # Move up to the parent directory
        current_dir=$(dirname "$current_dir")
    done

    workspace_dir="$current_dir"
    workspace_name="source_$(basename "$workspace_dir")"
    source_function=""

    if [[ -d "$workspace_dir/src" && -d "$workspace_dir/devel" ]]; then
        source_function="ros1_source"
    elif [[ -d "$workspace_dir/src" && -d "$workspace_dir/build" && -d "$workspace_dir/install" ]]; then
        source_function="ros2_source"
    else
        echo -e "${red}Error:${reset} Could not detect a valid ROS1 or ROS2 workspace in the current directory."
        return 1
    fi

    # Check if alias already exists in ~/.bashrc
    if grep -q "alias $workspace_name=" ~/.bashrc; then
        echo -e "${yellow}Warning:${reset} Alias $workspace_name already exists in ~/.bashrc. Skipping."
        return 0
    fi

    echo "alias $workspace_name='cd $workspace_dir && $source_function'" >> ~/.bashrc
    source ~/.bashrc
    echo -e "${green}Alias added:${reset} 'alias $workspace_name=\"cd $workspace_dir && $source_function\"' to ~/.bashrc"
    return 0
}

function source_this() {
    add_workspace_alias_result=$(add_workspace_alias)
    echo "$add_workspace_alias_result"

    current_dir=$(pwd)

    # Find the workspace directory by searching for src and devel/build+install directories
    while true; do
        if [[ -d "$current_dir/src" && (-d "$current_dir/devel" || (-d "$current_dir/build" && -d "$current_dir/install")) ]]; then
            break
        fi

        # If we've reached the root directory, stop searching
        if [[ "$current_dir" == "/" ]]; then
            echo -e "${red}Error:${reset} Could not find a valid ROS1 or ROS2 workspace in any parent directory."
            return 1
        fi

        # Move up to the parent directory
        current_dir=$(dirname "$current_dir")
    done

    workspace_dir="$current_dir"

    if [[ -d "$workspace_dir/src" && -d "$workspace_dir/devel" ]]; then
        ros1_source
    elif [[ -d "$workspace_dir/src" && -d "$workspace_dir/build" && -d "$workspace_dir/install" ]]; then
        ros2_source
    else
        echo -e "${red}Error:${reset} Could not detect a valid ROS1 or ROS2 workspace in the current directory."
        return 1
    fi

    return 0
}
