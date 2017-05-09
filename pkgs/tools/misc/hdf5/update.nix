{ lib, writeScript, coreutils, curl, gnugrep, gnused, xidel, jq, common-updater-scripts }:

writeScript "update-hdf5" ''
PATH=${lib.makeBinPath [ common-updater-scripts coreutils curl gnugrep gnused xidel jq ]}

set -x
url=https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/

latest_version=$(curl $url | \
	xidel -q - --extract "//a/@href" | \
	grep hdf5- | \
	sed -e "s:.*hdf5-\(.*\)\/:\1:" | sort -n | tail -n 1)

update-source-version hdf5 "$latest_version"
set +x
''
