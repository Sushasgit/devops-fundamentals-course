#!/bin/bash

REPO_DIR="./dist/app"

REPORT_FILE="$REPO_DIR/error_report.txt"
if [ -f "$REPORT_FILE" ]; then
    rm "$REPORT_FILE"
fi
touch "$REPORT_FILE"

echo "Linting results:" >> $REPORT_FILE
npm run lint --quiet 2>&1 | grep ERROR >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "Unit tests results:" >> $REPORT_FILE
TMP_FILE="test_output.txt"
npm run test -- --watch=false > $TMP_FILE 2>&1 || true
grep -E '(error TS|Error:)' $TMP_FILE >> $REPORT_FILE
rm $TMP_FILE
echo "" >> $REPORT_FILE

echo "End-to-end tests results:" >> $REPORT_FILE
npm run e2e --quiet 2>&1 | grep ERROR >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "Npm audit results:" >> $REPORT_FILE
npm audit >> $REPORT_FILE 2>&1 || true
echo "" >> $REPORT_FILE

if grep -q "ERROR" $REPORT_FILE; then
  echo "There were issues found with app quality. Please review the report file: $REPORT_FILE"
else
  echo "No problems found with app quality."
fi

