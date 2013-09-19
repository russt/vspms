if ($?PROJECT_SAVE) then
	#echo "Saving project environment..."
	#pjsave
endif
#clean up after others as well:
pjcleantmp -f -q &
pjclean                                                 #VSPMS
