#!/bin/bash

# Check if at least one argument is passed
if [ -z "$1" ]; then
    echo "Usage: $0 <image_name> [output_folder]"
    exit 1
fi

IMAGE_NAME=$1
OUTPUT=${2:-output}  # If no second argument is provided, use "output" by default
CONTAINER_NAME="temp_container_$RANDOM"

echo "Creating temporary container from the image $IMAGE_NAME..."
docker run --rm -dit --name $CONTAINER_NAME $IMAGE_NAME bash

# Check if R is installed
if docker exec -it $CONTAINER_NAME sh -c 'command -v R > /dev/null'; then
    echo "Extracting R packages..."
    docker exec -it $CONTAINER_NAME R -q -e 'write.table(installed.packages()[,"Version"], "/list_r_packages.txt", sep="\t")' > /dev/null
    docker cp -q $CONTAINER_NAME:/list_r_packages.txt .
else
    echo "❌ R is not installed in this image."
fi

# Check if Python is installed
if docker exec -it $CONTAINER_NAME sh -c 'command -v python3 > /dev/null'; then
    echo "Extracting Python packages..."
    docker exec -it $CONTAINER_NAME env PIP_DISABLE_PIP_VERSION_CHECK=1 python3 -m pip list --format=freeze > list_python_packages.txt
else
    echo "❌ Python is not installed in this image."
fi

# Detect the operating system
echo "Detecting the operating system..."
OS_TYPE=$(docker exec -it $CONTAINER_NAME sh -c 'cat /etc/os-release | grep "^ID=" | cut -d "=" -f2' | tr -d '"\r\n')

echo "Detected OS: $OS_TYPE"

echo "Extracting system packages..."
case "$OS_TYPE" in
    ubuntu|debian)
        docker exec -i $CONTAINER_NAME dpkg -l > list_system_packages.txt
        ;;
    alpine)
        docker exec -i $CONTAINER_NAME apk list --installed > list_system_packages.txt
        ;;
    rhel|centos|fedora)
        docker exec -i $CONTAINER_NAME rpm -qa > list_system_packages.txt
        ;;
    *)
        echo "❌ Unrecognized OS: $OS_TYPE"
        docker stop $CONTAINER_NAME
        exit 1
        ;;
esac

# Organize the files
mkdir -p "$OUTPUT"
[ -f list_r_packages.txt ] && mv list_r_packages.txt "$OUTPUT/"
[ -f list_python_packages.txt ] && mv list_python_packages.txt "$OUTPUT/"
[ -f list_system_packages.txt ] && mv list_system_packages.txt "$OUTPUT/"

echo "Removing the temporary container..."
docker stop $CONTAINER_NAME

echo "✅ Extraction completed!"
echo "Files generated in the '$OUTPUT/' folder"