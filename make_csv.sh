#!/bin/bash

set -e

tempcsv="/tmp/78926572.csv"

echo "making csv, please redirect" >> /dev/stderr
echo "header..." >> /dev/stderr

firstfile=$(find . -mindepth 2 -type f | sort | head -n1)
header=$(cat "${firstfile}" | jq -r '.data.fulfillTranscript.transcript.otherPeopleRelatedRecords.records | .[0] | .fields | map(.fieldId) | @csv')

printf "%s,%s,%s,%s,%s,%s\n" "${header}" "ApproxAge" "Address" "AddressStreet" "Inhabited" "LatLon" > "${tempcsv}"

echo "each street..." >> /dev/stderr
for folder in khartoum thompson wadbrough walton; do
  cat "${folder}"/* | jq --slurp -r '
      .[] |
    (.data.fulfillTranscript.transcript.fields[] | select(.fieldId=="Address")|.value) as $addr |
    (.data.fulfillTranscript.transcript.fields[] | select(.fieldId=="AddressStreet")|.value) as $addr_street |
    (.data.fulfillTranscript.transcript.fields[] | select(.fieldId=="Inhabited")|.value) as $inhabited |
    (.data.fulfillTranscript.transcript.fields[] | select(.fieldId=="LatLon")|.value) as $latlon |
      .data.fulfillTranscript.transcript.otherPeopleRelatedRecords.records | .[] |
    .fields |
      map({"key": .fieldId, "value": .value}) | from_entries |
    .ApproxAge=(1939 - (.BirthDate[-4:]|tonumber?)|tostring) |
    .Address=$addr |
    .AddressStreet=$addr_street |
    .Inhabited=$inhabited |
    .LatLon=$latlon |
      [.[]] | @csv
    ' >> "${tempcsv}"
    # get uninhabited addresses
    cat "${folder}"/* | jq -r --slurp '
      .[] |
      select(.data.fulfillTranscript.transcript.fields[] | select(.fieldId=="Inhabited")|.value == "N") |
      .data.fulfillTranscript.transcript.fields | map({"key": .fieldId, "value": .value}) | from_entries |
      [([range(0;11)]|map("")|.[]), .Address, .AddressStreet, .Inhabited, .LatLon] |
      @csv
    ' >> "${tempcsv}"
done

echo "wrote to ${tempcsv}" >> /dev/stderr
echo "putting to stdout" >> /dev/stderr

columnorder="AddressStreet,Address,Inhabited,LatLon,FirstName,LastName,BirthDate,ApproxAge,OccupationText,Gender,MaritalStatus,Relationship,Schedule,ScheduleSubNumber,Id"
echo "${columnorder}"
cat "${tempcsv}" | csvtool namedcol "${columnorder}" "${tempcsv}" | tail -n+2 | sort -V
