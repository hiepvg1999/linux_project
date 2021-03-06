#!/bin/bash
# bash test.sh -a all
# bash test.sh -c VietNam
# bash test.sh -l 5
# bash test.sh -s Viet
# bash test.sh -p cases // deaths // active (top n country)
# bash test.sh -h menu
# bash test.sh -i 704 5  // tham so thu nhat la ma code cua nuoc, tham so thu hai la so ngay
# thong ke theo cac tieu chi va nhap tham so toi da tu 1-10
# Chieu dai cua tung thanh: Lay tung ngay / max

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
while getopts ":a:c:l:s:p:h:i:w:" opt; do
  case $opt in

    #show all information.
    #Example: -a all
    a)
      if [[ "$2" == "all" ]]; then
        data=$(curl -sX GET "https://disease.sh/v3/covid-19/all" -H "accept: application/json")
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
	      echo "=========================================================" >&2
        echo "Infomation all the world is:" >&2
        echo >&2
        echo -e "\e[1;34m Cases: ${cases} \e[0m" >&2
        echo -e "\e[4;31m Deaths: ${deaths} \e[0m" >&2
        echo -e "\e[1;34m Active: ${active} \e[0m" >&2
        echo -e "\e[1;35m Today's Cases: ${todayCases} \e[0m" >&2
        echo -e "\e[2;36m Today's Deaths: ${todayDeaths} \e[0m" >&2
      else
        echo "Wrong argument.Please input (all)" >&2
        safe_exit
      fi
      ;;

    #show by Country.
    #Example: -c vietnam
    c)
        data=$(curl -sX GET "https://disease.sh/v3/covid-19/countries/$2?strict=true" -H "accept: application/json")
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
      ;;

    #list information of countries (country-name, alpha-2-code, alpha-3-code).
    #Example: -l 5
    l)
    cat countries.txt | ./pylist/tb.py $(($2 + 1));;

    s)
    input="countries.txt"
    ### search info about country
    if [[ -z $3 ]]; then
      echo "Search result:"
      grep -i $2 $input | ./pylist/tb.py
    fi
      ;;

    w)
      day=`date -d "$3 day ago" +%D`
      case_before=`curl -sX GET "https://disease.sh/v3/covid-19/historical/$OPTARG?lastdays=$3" -H "accept: application/json" |
            jq ".timeline.cases[\"$day\"]"`
      case_today=`curl -sX GET "https://disease.sh/v3/covid-19/countries/$OPTARG?strict=true" -H "accept: application/json" |
            jq ".cases"`

      death_before=`curl -sX GET "https://disease.sh/v3/covid-19/historical/$OPTARG?lastdays=$3" -H "accept: application/json" |
            jq ".timeline.deaths[\"$day\"]"`
      death_today=`curl -sX GET "https://disease.sh/v3/covid-19/countries/$OPTARG?strict=true" -H "accept: application/json" |
            jq ".deaths"`

      recovered_before=`curl -sX GET "https://disease.sh/v3/covid-19/historical/$OPTARG?lastdays=$3" -H "accept: application/json" |
            jq ".timeline.recovered[\"$day\"]"`
      recovered_today=`curl -sX GET "https://disease.sh/v3/covid-19/countries/$OPTARG?strict=true" -H "accept: application/json" |
            jq ".recovered"`

      echo >&2
      echo "Number of cases: $((case_today - case_before))" >&2
      echo "Number of deaths: $((death_today - death_before))" >&2
      echo "Number of recovered: $((recovered_today - recovered_before))" >&2
      ;;

    i)
    data=$(curl -sX GET "https://disease.sh/v3/covid-19/historical/$2?lastdays=$3" -H "accept: application/json")
    curl -sX GET "https://disease.sh/v3/covid-19/historical/$2?lastdays=$3" -H "accept: application/json" > ./graph/data.json

    echo >&2
    country=$(echo $data | jq ".country")
    echo "========================================================" >&2
    echo "Number of cases in ${country} within $3 days:" >&2
    cases=$(echo $data | jq ".timeline.cases")
    echo $cases
    echo "========================================================" >&2
    echo "Number of deaths in ${country} within $3 days:" >&2
    cases=$(echo $data | jq ".timeline.deaths")
    echo $cases
    echo "========================================================" >&2
    echo "Number of recovered in ${country} within $3 days:" >&2
    cases=$(echo $data | jq ".timeline.recovered")
    echo $cases
    echo "========================================================" >&2
    echo >&2

    echo -e "\e[1;34m           ${country} in $3 days nearest graph: \e[0m" >&2

    python3 ./graph/create_data_file.py
    ./prj_env/bin/termgraph ./graph/data.txt --color {magenta,red,blue}
    echo "========================================================" >&2
      ;;

    p)
    # sort by keys (cases,deaths,active)
    case $2 in
      deaths)
        echo "$2"
        data=$(curl -sX GET "https://disease.sh/v3/covid-19/countries?sort=$2" -H "accept: application/json")
        len=$(echo $data | jq length)
        echo "Number of countries: $len" >&2
        echo "" | nawk '{printf("=========================================================\n");
          printf("|%20s|%10s|%10s|%10s|\n","country","cases","deaths","active");
          }'
        for (( i = 0; i < $3; i++ )); do
          cases=$(echo $data |  jq -r ".[$i].cases")
          country=$(echo $data | jq -r ".[$i].country")
          deaths=$(echo $data | jq -r ".[$i].deaths")
          active=$(echo $data | jq -r ".[$i].active")
          echo "${country} ${cases} ${deaths} ${active}" | nawk '{printf("=========================================================\n");
            printf("|%20s|%10s|%10s|%10s|\n",$1,$2,$3,$4);
            }'
        done
        echo "=========================================================" >&2
        break
        ;;
      cases)
        data=$(curl -sX GET "https://disease.sh/v3/covid-19/countries?sort=$2" -H "accept: application/json")
        len=$(echo $data | jq length)
        echo "Number of countries: $len" >&2
        echo "" | nawk '{printf("-------------------------------------------------------\n");
          printf("|%20s|%10s|%10s|%10s|\n","country","cases","deaths","active");
          }'
        for (( i = 0; i < $3; i++ )); do
          cases=$(echo $data |  jq -r ".[$i].cases")
          country=$(echo $data | jq -r ".[$i].country")
          deaths=$(echo $data | jq -r ".[$i].deaths")
          active=$(echo $data | jq -r ".[$i].active")
          echo "${country} ${cases} ${deaths} ${active}" | nawk '{printf("-------------------------------------------------------\n");
            printf("|%20s|%10s|%10s|%10s|\n",$1,$2,$3,$4);
            }'
        done
        echo "-------------------------------------------------------" >&2
        break
        ;;
      active)
        data=$(curl -sX GET "https://disease.sh/v3/covid-19/countries?sort=$2" -H "accept: application/json")
        len=$(echo $data | jq length)
        echo "Number of countries: $len" >&2
        echo "" | nawk '{printf("-------------------------------------------------------\n");
          printf("|%20s|%10s|%10s|%10s|\n","country","cases","deaths","active");
          }'
        for (( i = 0; i < $3; i++ )); do
          cases=$(echo $data |  jq -r ".[$i].cases")
          country=$(echo $data | jq -r ".[$i].country")
          deaths=$(echo $data | jq -r ".[$i].deaths")
          active=$(echo $data | jq -r ".[$i].active")
          echo "${country} ${cases} ${deaths} ${active}" | nawk '{printf("-------------------------------------------------------\n");
            printf("|%20s|%10s|%10s|%10s|\n",$1,$2,$3,$4);
            }'
        done
        echo "-------------------------------------------------------" >&2
        break
        ;;
      *)
        echo "Wrong argument.Please input (cases,deaths,active)"
        safe_exit
    esac
      ;;


    #display menu and option
    #Example: -h menu
    h)
    ### menu
    if [[ "$2" == "menu" ]]; then
      echo "
_________             .__    .___        ____ ________
\_   ___ \  _______  _|__| __| _/       /_   /   __   \
/    \  \/ /  _ \  \/ /  |/ __ |   ____  |   \____    /
\     \___(  <_> )   /|  / /_/ |  /___/  |   |  /    /
 \______  /\____/ \_/ |__\____ |         |___| /____/
        \/                    \/
"
      echo -e "\e[1;44m Options\e[0m" >&2
      echo -e "\e[1;37m -c --country Specific country" >&2
      echo -e "\e[1;37m -a --all All data " >&2
      echo -e "\e[1;37m -l --list List of country id code" >&2
      echo -e "\e[1;37m -s --search Search info about specific country" >&2
      echo -e "\e[1;37m -p --sortbykey Sort by key (cases,deaths,active)" >&2
      safe_exit
    else
      echo "Wrong argument.Please input (menu)"
    fi
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      safe_exit
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      safe_exit
      ;;
  esac
done

safe_exit
