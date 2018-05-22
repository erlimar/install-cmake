#!/bin/sh

_has() {
    type "${1}" > /dev/null 2>&1
}

_os()
{
    local uname=`uname`
    if [ ${uname} = "Darwin" ]; then
        echo "darwin"
    elif [ ${uname} = "FreeBSD" ]; then
        echo "freebsd"
    elif [ ${uname} = "Linux" ]; then
        echo "linux"
    else
        echo "other"
    fi
}

_error()
{
    echo "Error: ${1}"
}

# -----------------
# Script parameters
# -----------------
while [ $# -ne 0 ]
do
    name="$1"
    case "$name" in
        --[Ii]nstall-[Pp]ath)
            shift
            install_path="$1"
            ;;
        --version|-[Vv]ersion)
            shift
            version="$1"
            ;;
        *)
            _error "Unknown argument \`$name\`"
            exit 1
            ;;
    esac

    shift
done

# -------------------
# Check prerequisites
# -------------------
if ! _has "uname"; then
    _error "Unix uname is required"
    exit 1
fi

#if [ ! `_os` = "linux" ] && [ ! `_os` = "darwin" ]; then
if [ ! `_os` = "linux" ]; then
    _error "OS "`_os`" is not supported"
    exit 1
fi

if ! _has "tar"; then
    _error "Unix tar is required"
    exit 1
fi

if ! _has "curl" && ! _has "wget" && ! _has "fetch"; then
    _error "Tool curl, wget or fetch is required"
    exit 1
fi

if [ "$version" = "" ]; then
    _error "--version is required."
    exit 1
fi

if [ "$install_path" = "" ]; then
    _error "--install-path is required."
    exit 1
fi

arch=`uname -m`

x86_linux_arch="i386"
x64_linux_arch="x86_64"
is_x86=true
linux_arch=$x86_linux_arch

if [ "$arch" = "x86_64" ] || [ "$arch" = "x64" ]; then
    linux_arch=$x64_linux_arch
    is_x86=false
fi

extract_zipfile()
{
    local zip_path="$1"
    local out_path="$2"

    tar -xzf "$zip_path" -C "$out_path" > /dev/null
}

download() {
    local url="$1"
    local path="${2:-}"
    
    if _has "curl"; then
        downloadcurl "$url" "$path"
    elif _has "wget"; then
        downloadwget "$url" "$path"
    else
        _error "fetch download not implemented"
    fi
}

downloadcurl() {
    local url="$1"
    local path="${2:-}"

    curl --retry 10 -sSL -f --create-dirs -o "$path" "$url"
}

downloadwget() {
    local url="$1"
    local path="${2:-}"

    wget --tries 10 -O "$path" "$url"
}

make_cmake_url() {
    echo "https://cmake.org/files/$1/$2"
}

make_cmake_file_name() {
    echo "cmake-$1-Linux-$2"
}

case "$version" in
    # v2.4
    2.4.2|2.4.3|2.4.4|2.4.5|2.4.6|2.4.7|2.4.8)
        if [ $is_x86 = true ]; then  # x86 only
            cmake_version="v2.4"
            cmake_file_name=$(make_cmake_file_name $version $x86_linux_arch)
        fi
        ;;
    # v2.6
    2.6.0|2.6.1|2.6.2|2.6.3|2.6.4)
        if [ $is_x86 = true ]; then  # x86 only
            cmake_version="v2.6"
            cmake_file_name=$(make_cmake_file_name $version $x86_linux_arch)
        fi
        ;;
    # v2.8
    2.8.0|2.8.1|2.8.2|2.8.3|2.8.4|2.8.5|2.8.6|2.8.7|2.8.8|2.8.9|2.8.10|2.8.10.1|2.8.10.2|2.8.11|2.8.11.1|2.8.11.2|2.8.12|2.8.12.1|2.8.12.2)
        if [ $is_x86 = true ]; then  # x86 only
            cmake_version="v2.8"
            cmake_file_name=$(make_cmake_file_name $version $x86_linux_arch)
        fi
        ;;
    # v3.0
    3.0.0|3.0.1|3.0.2)
        if [ $is_x86 = true ]; then  # x86 only
            cmake_version="v3.0"
            cmake_file_name=$(make_cmake_file_name $version $x86_linux_arch)
        fi
        ;;
    # v3.1
    3.1.0|3.1.1|3.1.2|3.1.3)
        cmake_version="v3.1"
        if [ $is_x86 = true ]; then # x86 & x64
            cmake_file_name=$(make_cmake_file_name $version $x86_linux_arch)
        else
            cmake_file_name=$(make_cmake_file_name $version $linux_arch)
        fi
        ;;
    # v3.2
    3.2.0|3.2.1|3.2.2|3.2.3)
        cmake_version="v3.2"
        if [ $is_x86 = true ]; then # x86 & x64
            cmake_file_name=$(make_cmake_file_name $version $x86_linux_arch)
        else
            cmake_file_name=$(make_cmake_file_name $version $linux_arch)
        fi
        ;;
    # v3.3
    3.3.0|3.3.1|3.3.2)
        cmake_version="v3.3"
        if [ $is_x86 = true ]; then # x86 & x64
            cmake_file_name=$(make_cmake_file_name $version $x86_linux_arch)
        else
            cmake_file_name=$(make_cmake_file_name $version $linux_arch)
        fi
        ;;
    # v3.4
    3.4.0|3.4.1|3.4.2|3.4.3)
        cmake_version="v3.4"
        if [ $is_x86 = true ]; then # x86 & x64
            cmake_file_name=$(make_cmake_file_name $version $x86_linux_arch)
        else
            cmake_file_name=$(make_cmake_file_name $version $linux_arch)
        fi
        ;;
    # v3.5
    3.5.0|3.5.1|3.5.2)
        cmake_version="v3.5"
        if [ $is_x86 = true ]; then # x86 & x64
            cmake_file_name=$(make_cmake_file_name $version $x86_linux_arch)
        else
            cmake_file_name=$(make_cmake_file_name $version $linux_arch)
        fi
        ;;
    # v3.6
    3.6.0|3.6.1|3.6.2|3.6.3)
        cmake_version="v3.6"
        if [ $is_x86 = true ]; then # x86 & x64
            cmake_file_name=$(make_cmake_file_name $version $x86_linux_arch)
        else
            cmake_file_name=$(make_cmake_file_name $version $linux_arch)
        fi
        ;;
    # v3.7
    3.7.0|3.7.1|3.7.2)
        cmake_version="v3.7"
        if [ $is_x86 = false ]; then # x64 only
            cmake_file_name=$(make_cmake_file_name $version $x64_linux_arch)
        fi
        ;;
    # v3.8
    3.8.0|3.8.1|3.8.2)
        cmake_version="v3.8"
        if [ $is_x86 = false ]; then # x64 only
            cmake_file_name=$(make_cmake_file_name $version $x64_linux_arch)
        fi
        ;;
    # v3.9
    3.9.0|3.9.1|3.9.2|3.9.3|3.9.4|3.9.5|3.9.6)
        cmake_version="v3.9"
        if [ $is_x86 = false ]; then # x64 only
            cmake_file_name=$(make_cmake_file_name $version $x64_linux_arch)
        fi
        ;;
    # v3.10
    3.10.0|3.10.1|3.10.2|3.10.3)
        cmake_version="v3.10"
        if [ $is_x86 = false ]; then # x64 only
            cmake_file_name=$(make_cmake_file_name $version $x64_linux_arch)
        fi
        ;;
    # v3.11
    3.11.0|3.11.1|3.11.2)
        cmake_version="v3.11"
        if [ $is_x86 = false ]; then # x64 only
            cmake_file_name=$(make_cmake_file_name $version $x64_linux_arch)
        fi
        ;;
    *)
        ;;
esac

if [ "$cmake_file_name" = "" ]; then
    _error "CMake v$version not found!"
    exit 1
fi

cmake_dir_name=$cmake_file_name
cmake_file_name="$cmake_file_name.tar.gz"
cmake_url=$(make_cmake_url $cmake_version $cmake_file_name)
cmake_file_path="$install_path/$cmake_file_name"
cmake_dir_path="$install_path/$cmake_dir_name"
cmake_bin_folder_path="$install_path/bin"
cmake_bin_path="$cmake_bin_folder_path/cmake"

if [ ! -d $install_path ]; then
    mkdir $install_path -p
fi

echo "Installing CMake v$version..."
echo "-----------------------------"

echo " -> Downloading $cmake_url..."
download $cmake_url $cmake_file_path

echo " -> Extracting $cmake_file_name"
extract_zipfile $cmake_file_path $install_path

echo " -> Moving install files..."
mv $cmake_dir_path/* $install_path

echo " -> Removing temporary files..."
rm -Rf $cmake_file_path

if [ ! -f $cmake_bin_path ]; then
    _error "CMake v$version install fail!"
    exit 1
fi

echo "-----------------------------"
echo "CMake v$version successfully install!"
echo ""
echo "Add ""$cmake_bin_folder_path"" to PATH!"
echo " - SH: export PATH=\"$cmake_bin_folder_path\":\"\$PATH\""
echo ""
