#!/bin/bash
data=$(curl -sX GET "https://disease.sh/v3/covid-19/countries/704?strict=true" -H "accept: application/json")
if [[ -z data ]]; then
    echo "Not found data of $-OPTARG country" >&2
else
    countryflag=$(echo $data | jq ".countryInfo" | jq ".flag")  # country flag
    cases=$(echo $data |  jq ".cases")
    country=$(echo $data | jq ".country")
    deaths=$(echo $data | jq ".deaths")
    active=$(echo $data | jq ".active")
### print
    echo "Infomation about ${country} is:" >&2
    echo "Info:${countryflag}" >&2
    id=`basename $countryflag | sed 's/"//'`
    if [[ ! -f /home/dangnam739/Documents/Learning/linux_project/img/$id ]]; then
    eval "wget $countryflag -O ./img/$id >/dev/null 2>&1"
    /home/dangnam739/Documents/Learning/linux_project/img/img_resize.py /home/dangnam739/Documents/Learning/linux_project/img/$id
    fi
    /home/dangnam739/Documents/Learning/linux_project/imcat/imcat /home/dangnam739/Documents/Learning/linux_project/img/$id
    echo -e "\e[1;34m Cases: ${cases} \e[0m" >&2
    echo -e "\e[4;31m Deaths: ${deaths} \e[0m" >&2
    echo -e "\e[3;33m Active: ${active} \e[0m" >&2
fi
