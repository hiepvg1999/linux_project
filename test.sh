#!/bin/bash
# bash test.sh -a all
# bash test.sh -c VietNam
# bash test.sh -l 5
# bash test.sh -s Viet
check_dependencies() {
  if ! [ -x "$(command -v jq)" ]; then
    err 'Error: jq is not installed.\nhttps://stedolan.github.io/jq/' >&2
    die
  fi
  if ! [ -x "$(command -v curl)" ]; then
    err 'Error: curl is not installed.\nhttps://github.com/curl/curl' >&2
    die
  fi
}
safe_exit() {
  trap - INT TERM EXIT
  exit
}
check_dependencies
while getopts ":a:c:l:s:p:h:" opt; do
  case $opt in
    a)
      if [[ $opt -eq "all" ]]; then
        data=$(curl -X GET "https://disease.sh/v3/covid-19/all" -H "accept: application/json")
        cases=$(echo $data |  jq ".cases")
        deaths=$(echo $data | jq ".deaths")
        active=$(echo $data | jq ".active")
        todayCases=$(echo $data | jq ".todayCases")
        todayDeaths=$(echo $data | jq ".todayDeaths")
        casesPerOneMillion=$(echo $data | jq ".casesPerOneMillion")
        deathsPerOneMillion=$(echo $data | jq ".deathsPerOneMillion")
        tests=$(echo $data | jq ".tests")
        testsPerOneMillion=$(echo $data | jq ".testsPerOneMillion")
        population=$(echo $data | jq ".population")
        echo "Infomation all the world is:" >&2
        echo >&2
        echo -e "\e[1;34m Cases: ${cases} \e[0m" >&2
        echo -e "\e[4;31m Deaths: ${deaths} \e[0m" >&2
        echo -e "\e[1;34m Active: ${active} \e[0m" >&2
        echo -e "\e[1;35m todayCases: ${todayCases} \e[0m" >&2
        echo -e "\e[2;36m todayDeaths: ${todayDeaths} \e[0m" >&2
      else
        echo "Option -$OPTARG wrong!" >&2
      fi
      ;;
    c)
        data=$(curl -X GET "https://disease.sh/v3/covid-19/countries/$OPTARG?strict=true" -H "accept: application/json")
        if [[ -z data ]]; then
          echo "Not found data of $-OPTARG country" >&2
        else
          countryflag=$(echo $data | jq ".countryInfo" | jq ".flag")  # country flag
          flag=$countryflag
          cases=$(echo $data |  jq ".cases")
          country=$(echo $data | jq ".country")
          deaths=$(echo $data | jq ".deaths")
          active=$(echo $data | jq ".active")
        ### print 
          echo "Infomation about ${country} is:" >&2
          echo "Info:${countryflag}" >&2
          echo -e "\e[1;34m Cases: ${cases} \e[0m" >&2
          echo -e "\e[4;31m Deaths: ${deaths} \e[0m" >&2
          echo -e "\e[3;33m Active: ${active} \e[0m" >&2
      fi
      ;;
    l)
    input="countries.txt"
    count=0
    number_line=$(wc -l <countries.txt) ## count number lines
    echo "Total of lines: $number_line" >&2
    echo "$2 countries of $input file:" >&2
    ## read line by line
    if ! [[ "$3" =~ ^[0-9]+$ ]]; then
      while IFS= read -r line
      do
      echo "$line"
      if [[ $count -eq $2 ]]; then
        break
      fi
      count=$((count+1))
      done < "$input"  
    fi
      ;;
    s)
    input="countries.txt"
    ### search info about country
    data=$(grep $2 $input)
    if [[ -z $3 ]]; then
      echo "Search result:" >&2
      echo "$data" >&2
    fi
      ;;
    p)
    # sort by keys (cases,deaths,active)
    if [[ $opt -eq "deaths" ]]; then
      data=$(curl -X GET "https://disease.sh/v3/covid-19/countries?sort=deaths" -H "accept: application/json")
    elif [[ $opt -eq "cases" ]]; then
      data=$(curl -X GET "https://disease.sh/v3/covid-19/countries?sort=cases" -H "accept: application/json")
    elif [[ $opt -eq "active" ]]; then
      data=$(curl -X GET "https://disease.sh/v3/covid-19/countries?sort=active" -H "accept: application/json")
    fi
    len=$(echo $data | jq length)
    echo "Number of countries: $len" >&2
    echo "" | nawk '{printf("========================================================\n");
      printf("|%20s|%10s|%10s|%10s|\n","country","cases","deaths","active");
      }'
    for (( i = 0; i < 5; i++ )); do
      cases=$(echo $data |  jq -r ".[$i].cases")
      country=$(echo $data | jq -r ".[$i].country")
      deaths=$(echo $data | jq -r ".[$i].deaths")
      active=$(echo $data | jq -r ".[$i].active")
      echo "${country} ${cases} ${deaths} ${active}" | nawk '{printf("========================================================\n");
      printf("|%20s|%10s|%10s|%10s|\n",$1,$2,$3,$4);
      }'
    done
      ;;
    h)
    ### menu
    if [[ $opt -eq "menu" ]]; then
      echo -e "\e[1;44m Options\e[0m" >&2
      echo -e "\e[1;37m -c --country Specific country" >&2
      echo -e "\e[1;37m -a --all All data " >&2
      echo -e "\e[1;37m -c --list List of country id code" >&2
      echo -e "\e[1;37m -s --search Search info about specific country" >&2
      exit 1
    fi
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done
safe_exit