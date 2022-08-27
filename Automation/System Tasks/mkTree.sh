# Creates a directory tree (makes your work easier when you often need to create new directory trees with the same structure)
# Replace subdirectories names with yours inside the mkdir command
# Add to .bashrc

# Usage: mktree <rootDirName>

# Example: mktree node
# Example result:
#│───node
#│   ├───subdir1
#│   ├───subdir2
#│   ├───subdir3
#│   ├───subdir n

mktree () {
        mkdir -p $1/{#subdir1, subdir2, subdir3, subdir n}
}