#! /bin/env bash

# href sanitizer
uriencode() {
  s="${1//%/%25}"
  s="${s// /%20}"
  s="${s//\"/%22}"
  s="${s//#/%23}"
  s="${s//$/%24}"
  s="${s//&/%26}"
  s="${s//+/%2B}"
  s="${s//,/%2C}"
  s="${s//\//%2F}"
  s="${s//:/%3A}"
  s="${s//;/%3B}"
  s="${s//=/%3D}"
  s="${s//\?/%3F}"
  s="${s//@/%40}"
  s="${s//\[/%5B}"
  s="${s//\]/%5D}"
  printf %s "$s"
}

html_list=''
json_list='['
json_sep=''
file_count=0

for input in "$@"; do
    if [ ! -f "${input}" ]; then
        continue
    fi
    name=$(basename "${input}")

    # add achor for this image to index.html
	href=$( uriencode "${name}" )
	anchor="  <a class=\"IMAGE\" href=\"${href}\">${name}</a><br>"
    html_list+="\n${anchor}"
    # and add file name to json list
    json_list+="${json_sep}\n    \"${name}\""
    json_sep=','

    ((file_count+=1))
done
json_list+="\n  ]"

#generate index.json
json_index="{\n"
json_index+="  \"title\" : \"Movie Posters\",\n"
json_index+="  \"description\" : \"Dithered movie posters for display on ePaper\",\n"
json_index+="  \"count\" : ${file_count},\n"
json_index+="  \"filelist\" : ${json_list}\n}"

# header for index.html
html_block='<!DOCTYPE html>
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
 <meta name="Author" content="John Stebbins">
 <meta name="GENERATOR" content="dither.sh">
 <title>Dithered File List</title>
 <style type="text/css">
  BODY { font-family : monospace, sans-serif;  color: black;}
  P { font-family : monospace, sans-serif; color: black; margin:0px; padding: 0px;}
  A:visited { text-decoration : none; margin : 0px; padding : 0px;}
  A:link    { text-decoration : none; margin : 0px; padding : 0px;}
  A:hover   { text-decoration: underline; background-color : yellow; margin : 0px; padding : 0px;}
  A:active  { margin : 0px; padding : 0px;}
  .VERSION { font-size: small; font-family : arial, sans-serif; }
  .IMAGE  { color: blue;  }
 </style>
</head>
<body>
	<h1>Dithered File List</h1><p>'

html_block+=$html_list
html_block+="\n<script class=\"IMAGES\" type=\"application/json\">\n"
html_block+=${json_index}
html_block+="\n</script>\n"
html_block+="</body>\n</html>"

# generate index.html
echo -e "${html_block}" > index.html
