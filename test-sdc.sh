# This test file will be automatically run when you submit a pull request
# You should not modify this file
# You can run this file using ./test-sdc.sh task-directory-name to check your output
# You can use it with the individual-shell-tools, jq, and shell-pipelines tasks

rm testoutput.txt
if [[ "$1" == "individual-shell-tools" ]]; then
	cd individual-shell-tools
	pass=0
	total=0
	for directory in */; do
		cd $directory
		if [ "$directory" == "helper-files/" ]; then
			cd ..
			continue
		fi
		for exercise in *.sh; do
			total=$(($total+1))
			./$exercise > ../../test.tmp
			./$exercise >> ../../testoutput.txt
			cmp ../../test.tmp ../../expect/individual-shell-tools/$directory$exercise --quiet
			if [ $? -eq 0 ]; then
				pass=$(($pass+1))
			else
				if [[ "$exercise" == *"stretch"* ]]; then
					# echo "Stretch task $directory$exercise failing, you can ignore this if you did not attempt. If you didnt, please have the volunteer check this."
					total=$(($total-1))
				else
					echo "Failed $directory$exercise, please either attempt again or have the volunteer check this." >> ../../testoutput.txt
				fi
			fi
		done
		cd ..
	done
	cd ..
	rm test.tmp
	echo "You passed $pass/$total tasks." >> testoutput.txt
	if [ -v GITHUB_OUTPUT ]; then
		echo "attempted=y" >> "$GITHUB_OUTPUT"
	fi
	if [ $pass -ge $total ]; then
		echo "This task is complete!" >> testoutput.txt
		if [ -v GITHUB_OUTPUT ]; then
			echo "complete=y" >> "$GITHUB_OUTPUT"
		fi
	fi
	cat testoutput.txt
elif [[ "$1" == "shell-pipelines" ]]; then
	cd shell-pipelines
	pass=0
	total=0
	for directory in */; do
		cd $directory
		for exercise in *.sh; do
			total=$(($total+1))
			./$exercise > ../../test.tmp
			cmp ../../test.tmp ../../expect/shell-pipelines/$directory$exercise --quiet
			if [ $? -eq 0 ]; then
				pass=$(($pass+1))
			else
				echo "Failed $directory$exercise, please either attempt again or have the volunteer check this." >> ../../testoutput.txt
			fi
		done
		cd ..
	done
	cd ..
	rm test.tmp
	echo "You passed $pass/$total tasks." >> testoutput.txt
	if [ -v GITHUB_OUTPUT ]; then
		echo "attempted=y" >> "$GITHUB_OUTPUT"
	fi
	if [ $pass -eq $total ]; then
		echo "This task is complete!" >> testoutput.txt
		if [ -v GITHUB_OUTPUT ]; then
			echo "complete=y" >> "$GITHUB_OUTPUT"
		fi
	fi
	cat testoutput.txt
elif [[ "$1" == "jq" ]]; then
	cd jq
	pass=0
	total=0
	for exercise in *.sh; do
		total=$(($total+1))
		./$exercise > ../test.tmp
		cmp ../test.tmp ../expect/jq/$exercise --quiet
		if [ $? -eq 0 ]; then
			pass=$(($pass+1))
		else
			echo "Failed $directory$exercise, please either attempt again or have the volunteer check this." >> ../../testoutput.txt
		fi
	done
	cd ..
	rm test.tmp
	echo "You passed $pass/$total tasks." >> testoutput.txt
	if [ -v GITHUB_OUTPUT ]; then
		echo "attempted=y" >> "$GITHUB_OUTPUT"
	fi
	if [ $pass -eq $total ]; then
		echo "This task is complete!" >> testoutput.txt
		if [ -v GITHUB_OUTPUT ]; then
			echo "complete=y" >> "$GITHUB_OUTPUT"
		fi
	fi
	cat testoutput.txt
else
	echo "Please run this with a valid test directory name as argument"
fi
