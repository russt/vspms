#! /bin/csh -f
# script to install or reinstall VSPMS command aliases

echo -n "This script will add to your .cshrc and .logout file.  'y' to continue: "
set ans=$<
if ($ans != y) then

cat << 'EOF'
-------------------------------------------------------------------------------
If you would like to try VSPMS, then you'll need to add commands similar to
the following in your .cshrc file:

	set RUSST=/usr/forte/russt
	set VSPMSLIB=$RUSST/lib
	if (-r $VSPMSLIB/vspmslib.csh) then
		source $VSPMSLIB/vspmslib.csh
		set path = ($path $RUSST/bin $RUSST/bin/`whatport`)
	endif
	#adjust this to your preference:
	setenv MYPROJECTS ~/myprojects

where ~/myprojects is a file containing lines of the form:
	project_name	project_directory

'EOF'

	echo -n "Would you like to see more?  "
	set ans=$<
	if ($ans != y) then
	  exit -1
	endif

	goto PRINTDOC
endif

ed - ~/.cshrc << 'EOF'
g/#VSPMS$/d
$a
set RUSST=/usr/forte/russt                              #VSPMS
set VSPMSLIB=$RUSST/lib                                 #VSPMS
if (-r $VSPMSLIB/vspmslib.csh) then                     #VSPMS
	source $VSPMSLIB/vspmslib.csh                       #VSPMS
	set path = ($path $RUSST/bin $RUSST/bin/`whatport`) #VSPMS
endif                                                   #VSPMS
#adjust this to your preference:                        #VSPMS
setenv MYPROJECTS ~/myprojects                          #VSPMS
.
1,$-8g/MYPROJECTS/.m$
w
q
'EOF'

ed - ~/.logout << 'EOF'
g/#VSPMS$/d
$a
pjclean                                                 #VSPMS
.
w
q
'EOF'

PRINTDOC:

more <<'EOF'
-------------------------------------------------------------------------------

Brief guide to VSPMS commands:

	alias			description:
	----------------------------------------------------------------
	lspj	lists your project names and locations.

	addpj [project_name]
		add the current working directory as "project_name"

	chpj [project_name]
		changes the current project to "project_name",
		and sources the .projectrc file to establish
		the project environment.  If no name is given,
		re-establishes the current project environment.

	pushpj [project_name|+n]
		pushes the named project on the directory
		stack.  With no arguments, exchanges the
		top two projects.  The +n form rotates the
		nth project to the top of the stack. (Same
		semantics as pushd.)

	poppj	pops the top project of the directory
		stack

	swpj	exchanges the top two projects on the
		directory stack.  (Same as pushpj with
		no arguments.)

	pjenv	prints the current project environment.

	newpjenv filename
		change project index file to filename.

	pci rcs_file
		check in a file with the current project revision label.

	pco rcs_file
		check out a file with the current project revision label.

	========================== SUBPROJECTS ==========================

	subpj [sub_project_dir]
		change to a new sub-project.  Sub-projects are names
		of directories under the "main" project name, i.e.,
		if the project is comprised of directories:

			/usr/myproject/src/{include,lib,bin}

		and the main project directory is /usr/myproject/src,
		then possible sub-projects are:

			{include,lib,bin}

		The .projectrc file for the project only needs to
		be created in the root project directory.  Thus
		sub-projects are defined to be all sub-trees
		sharing the same .projectrc file (and hence a
		common REV label, if there is one.)

	popspj
		pop a sub-project off the directory stack.

	pushspj [+n] [proj_name]
		push a new sub-project on directory stack.

	swspj
		switch between the top two subprojects on the directory
		stack.  Should only be used to switch between
		sub-projects sharing the same parent project.

To use these commands, you must define the following environment
variable:

	setenv MYPROJECTS my_project_index

Your project index file has 2 columns:

	project_name	project_directory

The project directory should have a ".projectrc" file, to establish the
project environment - here is an example:

		# standard .projectrc file
		setenv REV V0210d4
		setenv MAKEMF_LIB /usr/myproject/makemf

If you allowed installpj to modify your .cshrc file, then issue the command:

	source ~/.cshrc

for your new aliases to take effect now.

Note:  You may repeat this command to see this help message again.
-------------------------------------------------------------------------------
'EOF'
