#! /bin/env bash

json_list='['
json_sep=''
file_count=0

for input in "$@"; do
    if [ ! -f "${input}" ]; then
        continue
    fi
    name=$(basename "${input}")

    # and add file name to json list
    json_list+="${json_sep}\n    \"${name}\""
    json_sep=','

    ((file_count+=1))
done

sha256=$(cat "$@" | sha256sum -b - | cut -d " " -f 1)

json_list+="\n  ]"

#generate index.json
json_index="{\n"
json_index+="  \"title\" : \"Movie Posters\",\n"
json_index+="  \"description\" : \"Dithered movie posters for display on ePaper\",\n"
json_index+="  \"count\" : ${file_count},\n"
json_index+="  \"sha256sum\" : \"${sha256}\",\n"
json_index+="  \"filelist\" : ${json_list}\n}"
echo -e "${json_index}" > index.json
