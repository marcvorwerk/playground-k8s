#!/usr/bin/env bash

# https://kops.sigs.k8s.io/getting_started/install/

# Default values
version="latest"
location="/usr/local/bin"
upgrade="false"

# Function to display help
function show_help {
	echo "Usage: $0 [OPTIONS]"
	echo "Installs kops on your Linux system."
	echo ""
	echo "Options:"
	echo "  -v, --version VERSION   Installs the specified Kops version (default: ${version})."
	echo "  -u, --upgrade           Upgrade kops if already installed"
	echo "  -l, --location PATH     Specify install Path (default: ${location})"
	echo "  -h, --help              Displays this help message."
	exit 0
}

# Process options
while [[ $# -gt 0 ]]; do
	case $1 in
	-v | --version)
		if [ -z "$2" ]; then
			echo "Error: Version not specified."
			exit 1
		fi
		version="tags/v$(echo ${2} | sed 's/^v//')"
		shift 2
		;;
	-u | --upgrade)
		upgrade="true"
		shift
		;;
	-l | --location)
		if [ -z "$2" ]; then
			echo "Error: Location not specified."
			exit 1
		fi
		location="echo ${2%/}" # remove trailing slash
		shift 2
		;;
	-h | --help)
		show_help
		;;
	*)
		echo "Invalid option: $1"
		exit 1
		;;
	esac
done

# Pre Check
if [ -e "${location}/kops" ] && [ "${upgrade}" = false ]; then
	echo "Error: kops is already installed. Use --upgrade to install a newer version"
	exit 1
fi

echo "Version to install: ${version}"
read -r -p "Confirm installation? [y/N] " response
response=${response,,}
if [[ ! "$response" =~ ^(yes|y)$ ]]; then
	echo "Aborting ..."
	exit 2
fi

# Download and install Kops
download_url="https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/${version} | jq -r '.tag_name')/kops-linux-amd64"
echo "Downloading kops version $version..."
curl --progress-bar -Lo /tmp/kops "$download_url"

# Check if the download was successful
if [ $? -ne 0 ]; then
	echo "Error downloading kops. Please check the version and your internet connection."
	exit 1
fi

chmod +x /tmp/kops
sudo mv /tmp/kops ${location}/kops

echo "Kops has been successfully installed."

exit 0
