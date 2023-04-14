# my_colcon_utils
Useful short commands for colcon such as colcon_clean. Copy and paste these into your ~/.bashrc to have easy access to them.

## Usage

### colcon_clean 

 - Run from the base directory of your workspace.
 - Completely remove `build` and `install` directories: `colcon_clean`
 - Remove select packages from `build` and `install` directories: `colcon_clean [PATTERN1] [PATTERN2] ...`
 - Supports wildcard usage `*`
 
Example: ![image](https://user-images.githubusercontent.com/41449746/229185660-16d0d03a-eee8-4aba-be61-5122cfab5105.png)
