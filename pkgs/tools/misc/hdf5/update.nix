{ lib, writeScript, coreutils, curl, gnugrep, gnused, xidel, jq, common-updater-scripts }:

writeScript "update-hdf5" ''
PATH=${lib.makeBinPath [ common-updater-scripts coreutils curl gnugrep gnused xidel jq ]}

set -x
url=https://support.hdfgroup.org/HDF5/release/obtainsrc5110.html

latest_version=$(curl $url | \
	xidel -q - --extract "//a/@href" | \
	grep tar.bz2 | \
	sed -e "s:.*hdf5-\(.*\).tar.bz2:\1:")

update-source-version hdf5 "$latest_version"
set +x
''
