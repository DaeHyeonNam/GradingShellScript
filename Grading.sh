#!/bin/bash

# Created by DaeHyeon
# Works to grade simple, single-file c++ programs
# You need to install valgrind to grade the memory leak
# You can see the result from result.csv file and it will be more readable if you move the file to window and use excel.
echo "Please enter the assignmnet number: "
echo "Please enter the name of header file{ex)LinkedList.h} :"

testcase_main="/home/"
testcase_output="/home/"
student_ID=/home/=studentID.txt
studentFolder="/home/"
taFolder="/home/"
ResultFolder="/home/"

#the array of main files and output files In this form, there are 17 mains for scoring the cases and 2 mains for scoring the memory leak.
main_arr=("main1.cpp" "main2.cpp" "main3.cpp" "main4.cpp" "main5.cpp" "main6.cpp" "main7.cpp" "main8.cpp" "main9.cpp" "main10.cpp" "main11.cpp" "main12.cpp" "main13.cpp" "main14.cpp" "main15.cpp" "main16.cpp" "main17.cpp" "main18.cpp" "main19.cpp")
output_arr=("output1.txt" "output2.txt" "output3.txt" "output4.txt" "output5.txt" "output6.txt" "output7.txt" "output8.txt" "output9.txt" "output10.txt" "output11.txt" "output12.txt" "output13.txt" "output14.txt" "output15.txt" "output16.txt" "output17.txt")

#example each 2files of main and output files
#main_arr=("main1.cpp" "main2.cpp")
#output_arr=("output1.txt" "output2.txt")

#the size of array
length=${#main_arr[@]}

#remove result if it already existed
[ -e $taFolder/result$(date +%m%d).csv ] && rm $taFolder/result$(date +%m%d).csv

#make the result.csv form
cd $taFolder
echo -n "Student ID, Compile Error">> result$(date +%m%d).csv
for((i=1; i<=$length; i++))
do
	echo -n ",main$i">> result$(date +%m%d).csv	
done
echo ",total,date">> result$(date +%m%d).csv

#read each line from the ID.txt file
while read line
do
	let total=0	
	
	#append student ID to result file
	echo -n "$line">>result$(date +%m%d).csv

	#check if header file can be compiled or not
	if g++ $studentFolder/$line/assignment\#$1/$2 ;
        then
		#give 5 points if it compiled
                echo -n ",5">>result$(date +%m%d).csv
		let total+=5
        else 
                echo -n ",0">>result$(date +%m%d).csv
        fi

	#compare each of main and output files
	for ((i=0; i<$length; i++));
	do

		echo "${main_arr[$i]} + $line is on processing"
		
		cd $testcase_main
		#compile header file with main file and if there is compile error, save it in the student's dir as name of "compile_err.txt"		
		g++ -I $studentFolder/$line/assignment\#$1/ ${main_arr[$i]}
 
		#save the student's output file in the student's dir as name of main+i()
		timeout 5s ./a.out > $studentFolder/$line/assignment\#$1/${main_arr[$i]%.*}
		
		#this if statement is for grading memory leak. So it only works when i is 17 or 18.
		if [ $i -eq 17 -o $i -eq 18 ]
		then
			#save output of valgrind to txt.
			valgrind ./a.out > memory_check.txt 2>&1
		
			#search if there is memory lost or not.
			grep -q "definitely lost: 0 bytes in 0 blocks" "memory_check.txt"

			#ret saves 1 if there is none, saves 0 if there is.
			ret=$?	

			for ((k=4; k<16; k++));
        	        do
	                        grep -q "Process terminating with default action of signal $k" "memory_check.txt"
        	                seg=$?
        	                if [ $seg -eq 0 ]
        	                then
        	                        break
        	                fi
        	        done

			cd $taFolder
			if [ $ret -eq 0 -a $seg -eq 1 ]
			then
				#if there is no memory lost, give 5points.
				echo -n ",5">>result$(date +%m%d).csv
				let total+=5
			else
				echo -n ",0">>result$(date +%m%d).csv
			fi
		else
			cd $taFolder

			#diff student's output file with our correct output file	
			result=$? $(cmp $testcase_output${output_arr[$i]} $studentFolder/$line/assignment\#$1/${main_arr[$i]%.*} > /dev/null)
			if [ $result -eq 0 ]
			then
				#if correct give 5 points
				echo -n ",5">>result$(date +%m%d).csv
				let total+=5
	
			else
				echo -n ",0">>result$(date +%m%d).csv
			fi
		fi	
	done
	#we can see the grading result from the result.csv
	echo -n ",$total">>result$(date +%m%d).csv
	echo -n ",">>result$(date +%m%d).csv
	
	#get a commision date of students 
	cd $studentFolder/$line/
	git show --quiet --date=format-local:%m-%d --format="%cd" > date.txt
	cd $taFolder
	cat $studentFolder/$line/date.txt >> result$(date +%m%d).csv
done <$student_ID

mv ./result$(date +%m%d).csv $ResultFolder/result$(date +%m%d).csv
