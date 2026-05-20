#!/usr/bin/env bash
#
# Script to generate btrfs test files
# Requires Linux with dd and mkfs.btrfs

source ./shared_linux.sh

assert_availability_binary dd
assert_availability_binary fallocate
assert_availability_binary mkfs.btrfs
assert_availability_binary mknod
assert_availability_binary qemu-img
assert_availability_binary setfattr
assert_availability_binary truncate

VERSION=$( mkfs.btrfs -V | head -n 1 | sed 's/^mkfs.btrfs.* v\(.*\)/\1/' )

SPECIMENS_PATH="specimens/mkfs.btrfs-${VERSION}"

if test -d ${SPECIMENS_PATH}
then
	echo "Specimens directory: ${SPECIMENS_PATH} already exists."

	exit ${EXIT_FAILURE}
fi

mkdir -p ${SPECIMENS_PATH}

set -e

USERNAME=$( whoami )

MOUNT_POINT="/mnt/btrfs"

sudo mkdir -p ${MOUNT_POINT}

# Minimum size for a btrfs device.
IMAGE_SIZE=$(( 125 * 1024 * 1024 ))
SECTOR_SIZE=512

NODE_SIZE=4096

echo "Creating: btrfs; with node size: ${NODE_SIZE}; metadata single; mixed-mode"
create_test_image_file_with_file_entries "${SPECIMENS_PATH}/btrfs.raw" ${IMAGE_SIZE} ${SECTOR_SIZE} "--label btrfs_test" "--metadata single" "--mixed" "--nodesize ${NODE_SIZE}"

for RAW_FILE in ${SPECIMENS_PATH}/*.raw
do
	qemu-img convert -f raw -O qcow2 "${RAW_FILE}" "${RAW_FILE/.raw/.qcow2}"
	rm -rf "${RAW_FILE}"
done

exit ${EXIT_SUCCESS}
