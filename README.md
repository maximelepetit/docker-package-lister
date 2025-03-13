# docker-package-lister
A script to extract and list installed R, Python, and system packages from a Docker container. It automatically detects the operating system and organizes the output into a specified folder.

## Features

- **R Packages**: Extracts installed R packages with their versions.
- **Python Packages**: Extracts installed Python packages using `pip`.
- **System Packages**: Detects the container's OS and extracts system packages (Ubuntu/Debian, Alpine, RHEL/CentOS/Fedora).
- **Output Directory**: Saves the package lists in the specified output folder.

## Prerequisites

- Docker installed on your machine.
- The image you want to inspect.

## Usage

```bash
./list_packages.sh <image_name> [output_folder]
```

- **image_name**: The name of the Docker image you want to inspect.
- **output_folder** (optional): The directory where the package lists will be saved. Defaults to output/ if not provided.

## Example
To extract packages from a Docker image named my_docker_image and save the results in the my_output folder:
```bash
./list_packages.sh my_docker_image my_output
```
If you want to use the default output folder:
```bash
./list_packages.sh my_docker_image
```

## Output
The script will generate the following files in the output folder:

- **list_r_packages.txt** : List of installed R packages and their versions.
- **list_python_packages.txt** : List of installed Python packages.
- **list_system_packages.txt** : List of installed system packages (depending on the detected OS).

## Supported OS Types
- **Ubuntu/Debian**: Extracts system packages using dpkg.
- **Alpine**: Extracts system packages using apk.
- **RHEL/CentOS/Fedora**: Extracts system packages using rpm.
## License
This project is licensed under the GPL-3.0 License - see the [LICENSE](https://github.com/maximelepetit/docker-package-lister/blob/main/LICENSE) file for details.

