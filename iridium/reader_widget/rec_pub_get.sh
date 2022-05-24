#!/bin/bash
folders=("mno_commons_dart"
  "mno_lcp_dart"
#  "mno_lcp_native"
  "mno_navigator_flutter"
  "mno_opds_dart"
  "mno_server_dart"
  "mno_shared_dart"
  "mno_streamer_dart"
  #  "pdfium_ffi"
)
for i in "${folders[@]}"; do
  echo "flutter pub get $i"
  (cd "$i" || exit; flutter pub get)
done
