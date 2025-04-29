#!/bin/bash

# address and info
echo "request information"
cat "${1}" | jq '.data.fulfillTranscript.transcript.fields | map({"key": .fieldId, "value": .value}) | from_entries'
# people
echo ""
echo "related information"
echo ""

cat "${1}" | jq '.data.fulfillTranscript.transcript.otherPeopleRelatedRecords.records | .[] | .fields | map({"key": .fieldId, "value": .value}) | from_entries | .ApproxAge=(1939 - (.BirthDate[-4:]|tonumber?)|tostring)'
