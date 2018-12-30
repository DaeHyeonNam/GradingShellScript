#!/bin/bash

# Created by DaeHyeon
# Works to grade simple, single-file c++ programs
# You can see the result from result.csv file and it will be more readable if you move the file to window and use excel.
echo "Please enter the assignmnet number: "
echo "Please enter the name of header file which will be scored: "
echo "Please enter an individual studnet ID: "

# get an location of each folder.
testcase_main="/home/"
testcase_output="/home/"
studentsFolder="/home/"
taFolder="/home/"

#the array of main files and output files

main_arr=("main1.cpp" "main2.cpp" "main3.cpp" "main4.cpp" "main5.cpp" "main6.cpp" "main7.cpp" "main8.cpp" "main9.cpp" "main10.cpp" "main11.cpp" "main12.cpp" "main13.cpp" "main14.cpp" "main15.cpp" "main16.cpp" "main17.cpp" "main18.cpp" "main19.cpp")
output_arr=("output1.txt" "output2.txt" "output3.txt" "output4.txt" "output5.txt" "output6.txt" "output7.txt" "output8.txt" "output9.txt" "output10.txt" "output11.txt" "output12.txt" "output13.txt" "output14.txt" "output15.txt" "output16.txt" "output17.txt" )

#example each 2files of main and output files
#main_arr=("main1.cpp" "main2.cpp")
#output_arr=("output1.txt" "output2.txt")

#the size of array
length=${#main_arr[@]}

#make the result.csv form
cd $taFolder
echo -n "Student ID, Compile Error">>temp.csv
for((i=1; i<=$length; i++))
do
	echo -n ",main$i">>temp.csv
done
echo ",total">>temp.csv

#read each line from the ID.txt file
let total=0	

#append student ID to result file
echo -n "$3">>temp.csv

	#check if header file can be compiled or not
if g++ $studentFolder/$3/assignment\#$1/$2 ;
then
	#give 5 points if it compiled
        echo -n ",5">>temp.csv
	let total+=5
else 
        echo -n ",0">>temp.csv
fi
	#compare each of main and output files
for ((i=0; i<$length; i++));
do
	
	cd $testcase_main
	#compile header file with main file and if there is compile error, save it in the student's dir as name of "compile_err.txt"		
	g++ -I $studentFolder/$3/assignment\#$1/ ${main_arr[$i]}

	echo "$3 + ${main_arr[$i]} is on processing..."
	#save the student's output file in the student's dir as name of main+i()
	timeout 5s ./a.out > $studentFolder/$3/assignment\#$1/${main_arr[$i]%.*}

	if [ $i -eq 17 -o $i -eq 18 ]
	then
		valgrind ./a.out > memory_check.txt 2>&1
		echo "$3 + ${main_arr[$i]}" >> memory_check.txt

	        grep -q "definitely lost: 0 bytes in 0 blocks" "memory_check.txt"

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
			echo -n ",5">>temp.csv
			let total+=5
		else
			echo -n ",0">>temp.csv
		fi
	
	else
		cd $taFolder
		result=$? $(cmp $testcase_output${output_arr[$i]} $studentFolder/$3/assignment\#$1/${main_arr[$i]%.*} > /dev/null)
	        if [ $result -eq 0 ]
       		then
        	        #if correct give 5 points
        	        echo -n ",5">>temp.csv
        	        let total+=5
        	else
        	        echo -n ",0">>temp.csv
        	fi

	fi
	#diff student's output file with our correct output file
done
	#we can see the grading result from the result.csv
echo ",$total">>temp.csv

while read line
do
	echo $line
done < temp.csv

rm temp.csv
