if [ x$PROJECT_SAVE = x ]; then
	echo "Saving project environment..."
	pjsave
fi
rmpjenv
pjclean
exit
