#!/bin/bash

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# 예외처리
if [ "$#" -ne 3 ]; then
    echo "usage: $0 file1 file2 file3"
    exit 1
fi

file1=$1
file2=$2
file3=$3

# whoami
echo "************OSS1 - Project1************
* StudentID : 12182544 *
* Name : JI WOON PARK*
*******************************************

"

# MENU 출력
while true; do
    echo "[MENU]"
    echo "1. Get the data of Heung-Min Son's Current Club, Appearances, Goals, Assists in players.csv"
    echo "2. Get the team data to enter a league position in teams.csv"
    echo "3. Get the Top-3 Attendance matches in matches.csv"
    echo "4. Get the team's league position and team's top scorer in teams.csv & players.csv"
    echo "5. Get the modified format of date_GMT in matches.csv"
    echo "6. Get the data of the winning team by the largest difference on home stadium in teams.csv & matches.csv"
    echo "7. Exit"
    echo -n "Enter your CHOICE (1~7) : "
    read choice

    case $choice in
        1)
            echo "Do you want to get Heung-Min Son's data? (y/n): "
            read answer
            if [ "$answer" = "y" ]; then
                son_data=$(awk -F, '$1=="Heung-Min Son" {print "Team:"$4", Appearance:"$6", Goal:"$7", Assist:"$8}' $file2)
                echo $son_data
            fi
            ;;
        2)
            echo -n "What do you want to get the team data of league_position[1~20]: "
            read position
            awk -F, -v pos=$position '$6==pos {
                wins=$2; draws=$3; losses=$4;
                games=wins+draws+losses;
                win_rate=wins/games;
                printf "%s %s %.6f\n", $6, $1, win_rate}' $file1
            ;;
        3)
            echo -n "Do you want to know Top-3 attendance data and average attendance? (y/n): "
            read answer
            if [ "$answer" = "y" ]; then
                echo -e "***Top-3 Attendance Match***\n"

               awk -F, 'NR>1 {
               date=$1; attendance=$2; home=$3; away=$4; stadium=$7;
               printf "%s,%s,%s,%s,%s\n", date, attendance, home, away, stadium}' $file3 | sort -t, -k2,2nr | head -n 3 | awk -F, '{
               printf "%s vs %s (%s)\n%s %s\n\n", $3, $4, $1, $2, $5}'
            fi
            ;;
        4)
            echo -n "Do you want to get each team's ranking and the highest-scoring player? (y/n): "
            read answer
            if [ "$answer" = "y" ]; then
                echo ""
                awk -F, 'NR>1 {printf "%s,%s\n", $6, $1}' $file1 | sort -k1,1n | awk -F, '{printf "%s,", $2}' | sed 's/,$//' > teams_ranked.txt
                tr -d '%' < teams_ranked.txt > new_teams_ranked.txt
                IFS=','
                counter=1
                for var in $(cat new_teams_ranked.txt); do
                    awk -F, -v team=$var '$4==team {printf "%s,%s,%s\n", $7, $1, team}' $file2 |
                    sort -t, -k1,1nr |
                    head -n 1 |
                    awk -F, -v team=$var -v cnt="$counter" '{printf "%s %s\n%s %s\n\n", cnt, team, $2, $1}'
                    ((counter++))
                done
            fi
            ;;
        5)
            echo -n "Do you want to modify the format of date?(y/n):"
            read answer
            if [ "$answer" = "y" ]; then
                sed -r 's/(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) ([0-9]{1,2}) ([0-9]{4}) - ([0-9]{1,2}:[0-9]{2}(am|pm))/\3\/\1\/\2 \4/' matches.csv | sed 's/Jan/01/; s/Feb/02/; s/Mar/03/; s/Apr/04/; s/May/05/; s/Jun/06/; s/Jul/07/; s/Aug/08/; s/Sep/09/; s/Oct/10/; s/Nov/11/; s/Dec/12/' |
                head -n 11 |
                awk -F, 'NR>1 { print $1 }'
                echo ""
            fi
            ;;
        6)
            awk -F, 'NR > 1 {
                if (NR < 12) {
                    left[NR-1] = sprintf("%2d) %-20s", NR-1, $1);
                } else {
                    right[NR-11] = sprintf("%2d) %s", NR-1, $1);
                }
            }
            END {
                for (i = 1; i <= 10; i++) {
                    printf "%s\t\t%s\n", left[i], right[i];
                }
            }' "$file1"

            echo -n "Enter your team number:"
            read answer

            echo ""
            selected_team=$(awk -F, -v num=$answer ' NR > 1 && NR == num + 1 { print $1 }' $file1 )

            max_diff=$(awk -F, -v team="$selected_team" 'BEGIN { max = 0 } $3 == team {
            diff = $5 - $6
            if (diff > max) max = diff
            } END {print max}' "$file3" )

            awk -F, -v team="$selected_team" -v diff="$max_diff" '$3 == team && ($5 - $6) == diff { printf "%s\n%s %s vs %s %s\n\n", $1, $3 ,$5,$6, $4}' "$file3"
            ;;
        7)
            echo "Bye!"
            exit 0
            ;;
    esac
done


