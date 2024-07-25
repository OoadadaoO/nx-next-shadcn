#!/bin/bash

# Check if the target path is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <target-path>"
  exit 1
fi

# Check if the target directory exists
TARGET_DIR="${1:-.}"
COMPONENTS_DIR="$TARGET_DIR/src/components/ui"
if [ ! -d "$TARGET_DIR" ]; then
  echo "The specified directory $TARGET_DIR does not exist."
  exit 1
fi

# Define the target index file
SRC_INDEX="$TARGET_DIR/src/index.ts"
COMPONENTS_INDEX="$COMPONENTS_DIR/index.ts"

# Clear the index.ts file, or create it if it doesn't exist
> $COMPONENTS_INDEX

# Loop through the .ts files in the directory
for FILE in $COMPONENTS_DIR/*.{ts,tsx}; do
  # Get the filename without the path and extension
  FILENAME=$(basename -- "$FILE")
  BASENAME="${FILENAME%.*}"

  # Exclude the index.ts file itself
  if [ "$BASENAME" != "index" ]; then
    # Write the re-export statement to the index.ts file
    echo "export * from './$BASENAME';" >> $COMPONENTS_INDEX

    # Replace content in the file
    sed -i 's#@/lib/utils#../../lib/utils#g' "$FILE"
    sed -i 's#@/components/ui#./#g' "$FILE"
  fi
done

# Add export statements to src/index.ts if they don't already exist
if ! grep -Fq "export * from './components/ui';" $SRC_INDEX; then
  echo "export * from './components/ui';" >> $SRC_INDEX
fi

if ! grep -Fq "export * from './lib/utils';" $SRC_INDEX; then
  echo "export * from './lib/utils';" >> $SRC_INDEX
fi

echo "Updated successfully."