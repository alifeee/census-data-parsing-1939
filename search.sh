#!/bin/bash

# curl search

streetid="${wadbrough}"

if [[ -z "${1}" ]]; then
  echo "1 - wad, 2 - khartoum, 3 - walton, 4 - thompson" >> /dev/stderr
  echo "./search.sh 2" >> /dev/stderr
  exit 1
elif [[ "${1}" == "1" ]]; then
  echo "wadbrough" >> /dev/stderr
  streetid="TNA/R39/STREET/0FF690EEEEB90B72FF646395685F1A68"
elif [[ "${1}" == "2" ]]; then
  echo "khartoum" >> /dev/stderr
  streetid="TNA/R39/STREET/D9C9074E606D0AAF3FF6A2789D504195"
elif [[ "${1}" == "3" ]]; then
  echo "walton" >> /dev/stderr
  streetid="TNA/R39/STREET/6D6137475C04A16A613AE5ABAFB2FCD5"
elif [[ "${1}" == "4" ]]; then
  echo "thompson" >> /dev/stderr
  streetid="TNA/R39/STREET/42564E03CA754A904605B215FA9AFAA5"
fi

curl 'https://www.findmypast.co.uk/titan/marshal/graphql' --compressed -X POST -H 'content-type: application/json' --data-raw '{"operationName":"HouseholdByStreetId","variables":{"streetId":"'"${streetid}"'","top":200,"skip":0,"orderBy":[]},"query":"query HouseholdByStreetId($streetId: String!, $top: Int, $skip: Int, $orderBy: [Ordering]) {\n  street(streetId: $streetId, top: $top, skip: $skip, orderBy: $orderBy) {\n    count\n    records {\n      recordId\n      fields {\n        fieldName\n        value\n        __typename\n      }\n      __typename\n    }\n    __typename\n  }\n}\n"}'

