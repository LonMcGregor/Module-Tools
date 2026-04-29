# This test file will be automatically run when you submit a pull request
# You should not modify this file
# You can run this file using ./test-sdc.sh task-directory-name to check your output

echo "<!--CYFTT tag: sdc-test-results-->" > testoutput.txt
echo "Results of test" >> testoutput.txt

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
			cmp ../../test.tmp ../../expect/individual-shell-tools/$directory$exercise --quiet
			if [ $? -eq 0 ]; then
				pass=$(($pass+1))
			else
				if [[ "$exercise" == *"stretch"* && $(stat -c%s ../../test.tmp) == "0" ]]; then
					# Stretch task not attempted, ignoring"
					total=$(($total-1))
				else
					echo "Failed $directory$exercise, please check" >> ../../testoutput.txt
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
				echo "Failed $directory$exercise, please check" >> ../../testoutput.txt
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
			echo "Failed $exercise, please check" >> ../testoutput.txt
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
elif [[ "$1" == "number-systems" ]]; then
	pass=0
	for question in $(seq 1 15); do
		answer=$(jq -r ".answers[$question]" expect/number-systems/Part-1.json)
		nextq=$(($question+1))
		Q_START=$(grep -n "Q$question:" number-systems/Part-1.md | cut -d: -f1)
		ANS_START=$(($Q_START + 1))
		NEXT_Q_START=$(grep -n "Q$nextq:" number-systems/Part-1.md | cut -d: -f1)
		ANS_END=$(($NEXT_Q_START - 1))
		sed -n "$ANS_START,${ANS_END}p;${NEXT_Q_START}q" number-systems/Part-1.md | cut -d: -f2- > answerfile
		grep --quiet -iE $answer answerfile
		if [ $? -eq 0 ]; then
			pass=$(($pass+1))
		else
			echo "Q$question incorrect, please check" >> testoutput.txt
		fi
		rm answerfile
	done
	echo "You passed $pass/15 tasks in part 1." >> testoutput.txt
	if [ -v GITHUB_OUTPUT ]; then
		echo "attempted=y" >> "$GITHUB_OUTPUT"
	fi
	echo "Please let a volunteer check the answers for part 2." >> testoutput.txt
	cat testoutput.txt
else
	echo "Please run this with a valid test directory name as argument"
fi
