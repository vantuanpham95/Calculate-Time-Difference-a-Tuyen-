#!/bin/bash
split -l 1 -d -a1 tuyen.txt txt
totalline=$(wc -l < tuyen.txt)
#echo $totalline

for (( i=0; i<=$totalline; i++ ))
do
	cat txt$i | awk -F ', ' '{print $1}' > fulldaytime1txt$i
	cat txt$i | awk -F ', ' '{print $2}' > fulldaytime2txt$i
	rm -rf txt$i

	cat fulldaytime1txt$i | awk -F ' ' '{print $1}' > fullday1txt$i
	cat fulldaytime2txt$i | awk -F ' ' '{print $1}' > fullday2txt$i
	cat fulldaytime1txt$i | awk -F ' ' '{print $2}' > fulltime1txt$i
	cat fulldaytime2txt$i | awk -F ' ' '{print $2}' > fulltime2txt$i
	

	#split milisecond of each time
	read -r mls1$i <<<$(echo $(cat fulltime1txt$i | awk -F'.' '{print $2}'))
	if [[ $((mls1$i)) -lt 100 ]]
	then
		let mls1$i*=10
	fi

	read -r mls2$i <<<$(echo $(cat fulltime2txt$i | awk -F'.' '{print $2}'))
	if [[ $((mls2$i)) -lt 100 ]]
	then
		let mls2$i*=10
	fi
	#echo $((mls1$i)) $((mls2$i))

	#calculate milisec difference of each line
	read -r emls$i <<<$(expr $((mls2$i)) - $((mls1$i)))
	#echo "emls$i: $((emls$i))"

	#calculate datediff of each line
	read -r days1txt$i <<<$(date -u -d $(cat fullday1txt$i) +%j)
	read -r days2txt$i <<<$(date -u -d $(cat fullday2txt$i) +%j)
	read -r datedifftxt$i <<<$(expr $((days2txt$i)) - $((days1txt$i)))
	#echo "datedifftxt$i: $((datedifftxt$i))"

	#calculate secondsdiff of each line
	read -r sec1txt$i <<<$(date -u -d $(cat fulltime1txt$i) +%s)
	read -r sec2txt$i <<<$(date -u -d $(cat fulltime2txt$i) +%s)
	read -r secondsdiff$i <<<$(expr $((sec1txt$i)) - $((sec2txt$i)))
	#echo $((secondsdiff$i))

	rm -rf fulltime1txt$i fulltime2txt$i fullday1txt$i fullday2txt$i fulldaytime1txt$i fulldaytime2txt$i


	#Mac dinh thoi gian 2 luon lon hon thoi gian 1
	
	if [ ! $((emls$i)) -lt 100 ]
	then
		read -r htxt$i <<<$(echo $((secondsdiff$i))/3600 | bc)
		read -r mtxt$i <<<$(echo $((secondsdiff$i))/60 - 60*$((htxt$i)) | bc)
		read -r stxt$i <<<$(echo $((secondsdiff$i))%60 | bc)
		
		echo "Time Diff $(expr $i + 1): $((datedifftxt$i)) days,$((htxt$i)):$((mtxt$i)):$((stxt$i)).$((emls$i))" >> results.txt
		elif [[ $((emls$i)) -lt 100 && ! $((emls$i)) -lt 0 ]]; then
			read -r htxt$i <<<$(echo $((secondsdiff$i))/3600 | bc)
			read -r mtxt$i <<<$(echo $((secondsdiff$i))/60 - 60*$((htxt$i)) | bc)
			read -r stxt$i <<<$(echo $((secondsdiff$i))%60 | bc)

			echo "Time Diff $(expr $i + 1): $((datedifftxt$i)) days,$((htxt$i)):$((mtxt$i)):$((stxt$i)).0$((emls$i))" >> results.txt
		elif [[ $((emls$i)) -lt 0 && ! $((secondsdiff$i)) -lt 1 ]]; then
				let secondsdiff$i-=1

				read -r htxt$i <<<$(echo $((secondsdiff$i))/3600 | bc)
				read -r mtxt$i <<<$(echo $((secondsdiff$i))/60 - 60*$((htxt$i)) | bc)
				read -r stxt$i <<<$(echo $((secondsdiff$i))%60 | bc)

				echo "Time Diff $(expr $i + 1): $((datedifftxt$i)) days,$((htxt$i)):$((mtxt$i)):$((stxt$i)).$(expr $((emls$i)) + 1000)" >> results.txt
			elif [[ $((emls$i)) -lt 0 && $((secondsdiff$i)) -lt 1 ]]; then
					let datedifftxt$i-=1
					let secondsdiff$i+=86399

					read -r htxt$i <<<$(echo $((secondsdiff$i))/3600 | bc)
					read -r mtxt$i <<<$(echo $((secondsdiff$i))/60 - 60*$((htxt$i)) | bc)
					read -r stxt$i <<<$(echo $((secondsdiff$i))%60 | bc)

					echo "Time Diff $(expr $i + 1): $((datedifftxt$i)) days,$((htxt$i)):$((mtxt$i)):$((stxt$i)).$(expr $((emls$i)) + 1000)" >> results.txt
	fi
done
