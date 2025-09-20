#!/bin/bash

START_PASSAGE="splash"

TWEEGO_BIN="< tweego path >"
SRC_DIR="< /src path>"
BUILD_DIR="< /build path >"
HTML_OUT="$BUILD_DIR/index.html"


# setup.mode = 'prod';
sed -i '' "s/setup.mode = '.*';/setup.mode = '{{MODE}}';/" src/javascript/__ui.js
sed -i '' "s/{{MODE}}/prod/" src/javascript/__ui.js

# Replace the start passage for prod build !
sed -i '' -E "s/^[[:space:]]*\"start\"[[:space:]]*:[[:space:]]*\"[^\"]+\"/  \"start\": \"$START_PASSAGE\"/" src/config/_story.tw
echo -n "✅ Start passage: "
grep -E '^[[:space:]]*"start"' _story.tw


echo "🔧 Compilation with Tweego..."
"$TWEEGO_BIN" -o "$HTML_OUT" "$SRC_DIR"

if [ $? -ne 0 ]; then
  echo "❌ Compilation failed. Abandoned."
  exit 1
fi

echo "✅ Compilation successful in $HTML_OUT"

# Clean up previous build files
echo "Cleaning up old assets..."
rm -rf "$BUILD_DIR/images" "$BUILD_DIR/audio"


mkdir -p "$BUILD_DIR/images"
mkdir -p "$BUILD_DIR/audio"

echo "Search for assets used in files .tw..."

# OK : Extraction of assets paths (between double quotation marks, does not detect single quotation marks)
used_assets=$(grep -rhoE '"(images|audio)/[^"]+' "$SRC_DIR" | cut -d'"' -f2 | sort -u)

# Copying existing assets
for asset in $used_assets; do
  src_path="$asset"
  dest_path="$BUILD_DIR/$asset"
  dest_dir=$(dirname "$dest_path")

  if [ -f "$src_path" ]; then
    mkdir -p "$dest_dir"
    cp "$src_path" "$dest_path"
    #echo "Copied : $src_path → $dest_path"


    while [[ "$dest_dir" != "$BUILD_DIR" && ! -f "$dest_dir/index.html" ]]; do
      touch "$dest_dir/index.html"
      dest_dir=$(dirname "$dest_dir")
    done
  else
    echo "⚠️ Asset not found : $src_path"
  fi
done


# Open in Google Chrome
open -a "Google Chrome" "file://$HTML_OUT"


# delete old archive
[ -f enquete1900.zip ] && rm enquete1900.zip
# create zip for Itch.io
zip -r build/enquete1900.zip build > /dev/null
echo "✅ Archive created : enquete1900.zip"

# Analyse des textes
./tools/count_total_scenes.sh
