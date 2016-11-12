#!/bin/sh
# Assumptions:
# 1) Variables or defaults are set as indicated below
# 2) eth1 is the WAN
# 3) A file named a_records.txt is in the same directory, containing all the records to update
#   a) the file contains a line for each record, space separated, formatted: zone name id 

ip=`vbash -ic "show interfaces" | grep eth1 | awk '{print $2}' | rev | cut -c 4- | rev`
email=${CLOUDFLARE_EMAIL:-"nobody@example.com"} # replace this default or set the env var
token=${CLOUDFLARE_TOKEN:-""} # replace this default or set the env var

# args: space separated string in the format:  "zone name id"
update_record_with_ip() {
  array=($1)

  curl https://www.cloudflare.com/api_json.html \
    -d 'a=rec_edit' \
    -d "tkn=$token" \
    -d "email=$email" \
    -d "z=$(array[0])" \
    -d "id=$(array[2])" \
    -d 'type=A' \
    -d "name=$(array[1])" \
    -d 'ttl=1' \
    -d "content=$ip" \
    > /dev/null
}

readarray -t domains < a_records.txt
for entry in "${domains[@]}"
do
  update_record_with_ip $entry
done

