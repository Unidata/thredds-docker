#!/bin/bash
# Sync latest 31 days of files from public S3 to local directory
# and clean up files older than 31 days

S3_BUCKET="s3://imos-data/IMOS/SRS/AusTemp/ssta"
LOCAL_PATH="/usr/local/tomcat/content/thredds/public/austemp"
DAYS_TO_KEEP=31

# Create directory if it doesn't exist
mkdir -p "$LOCAL_PATH"

echo "$(date): Starting S3 sync for last $DAYS_TO_KEEP days"

# Calculate the last 31 days (including today)
for i in $(seq 0 $((DAYS_TO_KEEP - 1))); do
    TARGET_DATE=$(date -d "$i days ago" +%Y%m%d)
    TARGET_YEAR=$(date -d "$i days ago" +%Y)

    echo "Syncing files for date: $TARGET_DATE"

    # Sync files for this specific date from the year folder
    aws s3 sync "$S3_BUCKET/$TARGET_YEAR/" "$LOCAL_PATH" \
        --no-sign-request \
        --region ap-southeast-2 \
        --exclude "*" \
        --include "${TARGET_DATE}_*.nc"
done

echo "$(date): S3 sync completed"

# Clean up local files older than DAYS_TO_KEEP
echo "$(date): Cleaning up files older than $DAYS_TO_KEEP days"

# Calculate the cutoff date
CUTOFF_DATE=$(date -d "$DAYS_TO_KEEP days ago" +%Y%m%d)

# Find and delete files with date patterns older than cutoff
# Pattern matches: YYYYMMDD_*.nc
find "$LOCAL_PATH" -type f -name "*.nc" | while read -r file; do
    # Extract date from filename (assuming pattern YYYYMMDD_*.nc)
    filename=$(basename "$file")
    file_date=$(echo "$filename" | grep -oE '^[0-9]{8}' || echo "")

    if [ -n "$file_date" ] && [ "$file_date" -lt "$CUTOFF_DATE" ]; then
        echo "Deleting old file: $filename (date: $file_date, cutoff: $CUTOFF_DATE)"
        rm -f "$file"
    fi
done

echo "$(date): Cleanup completed"

# Display current disk usage
echo "Current disk usage of $LOCAL_PATH:"
du -sh "$LOCAL_PATH"
echo "File count: $(find "$LOCAL_PATH" -type f -name "*.nc" | wc -l)"
