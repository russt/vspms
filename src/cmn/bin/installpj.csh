#! /bin/csh -f
# script to install or reinstall VSPMS command aliases

echo -n "This script will add to your .cshrc and .logout files.  'y' to continue: "
set ans=$<
if ($ans != y) then

cat << 'EOF'
-------------------------------------------------------------------------------
If you would like to try VSPMS, then you'll need to add commands similar to
the following in your .cshrc file:

	set RUSST=~russt                                        #VSPMS
	set VSPMSLIB=$RUSST/lib                                 #VSPMS
	if (-r $VSPMSLIB/vspmslib.csh) then                     #VSPMS
		source $VSPMSLIB/vspmslib.csh                       #VSPMS
		set VSPMSPRT = `$RUSST/lib/whatport`                #VSPMS
		set path = ($path $RUSST/bin $VSPMSLIB/`whatport`) #VSPMS
	endif                                                   #VSPMS
	#adjust this to your preference:                        #VSPMS
	setenv MYPROJECTS ~/myprojects                          #VSPMS
	if ($?prompt != 0) then                                 #VSPMS
		# MARK BASE ENVIRONMENT                             #VSPMS
		pjresethome                                         #VSPMS
	endif                                                   #VSPMS

where ~/myprojects is a file containing lines of the form:
	project_name	project_directory

This is done automatically for you when you run ~russt/bin/installpj.
Note that VSPMS relies on Perl version 5.

'EOF'

	echo -n "Would you like to see more (y or n)?  "
	set ans=$<
	if ($ans != y) then
	  exit -1
	endif

	goto PRINTDOC
endif

echo -n "Would you like your own private copy (y or n)?  "
set ans=$<
if ($ans != y) then

ed - ~/.cshrc << 'EOF'
g/#VSPMS$/d
$a
set VSPMSHOME=~russt                                    #VSPMS
.
w
q
'EOF'

	goto EDIT_CSH
endif

### install a local copy:
cd
set TARFILE=~russt/dist/vspms_csh.tar
rm -f `tar tf $TARFILE` > & /dev/null
tar xvf $TARFILE

ed - ~/.cshrc << 'EOF'
g/#VSPMS$/d
$a
set VSPMSHOME=~                                        #VSPMS
.
w
q
'EOF'

EDIT_CSH:

ed - ~/.cshrc << 'EOF3'
$a
set VSPMSLIB=$VSPMSHOME/lib                             #VSPMS
if (-r $VSPMSLIB/vspmslib.csh) then                     #VSPMS
	source $VSPMSLIB/vspmslib.csh                       #VSPMS
	set VSPMSPRT = `$VSPMSLIB/whatport`                 #VSPMS
	set path = ($path $VSPMSHOME/bin $VSPMSHOME/bin/$VSPMSPRT) #VSPMS
endif                                                   #VSPMS
#adjust this to your preference:                        #VSPMS
setenv MYPROJECTS ~/myprojects                          #VSPMS
if ($?prompt != 0) then                                 #VSPMS
	# MARK BASE ENVIRONMENT                             #VSPMS
	pjresethome                                         #VSPMS
endif                                                   #VSPMS
.
w
q
'EOF3'

ed - ~/.logout << 'EOF4'
g/#VSPMS$/d
$a
pjclean                                                 #VSPMS
.
w
q
'EOF4'

PRINTDOC:

more <<'EOF'
-------------------------------------------------------------------------------
What is VSPMS?

This is the "Very Simple Project Management System".  It allows
you to store project locations in an index file, and use shortcuts
to get to your location.  It is designed to help you remember
where you put things, and to provide facilities to set up a
well defined and documented environment for your project.

It is an excellent tool for capturing procedures and
setup information that needs to be shared among a team.

The basic command that you need to understand is the "chpj"
alias.  This command performs the functional equivalent of
the following:

	cd `wherepj <myproj>`; source $PROJECTRC

The wherepj command looks up <myproj> (which is the shortcut
you define for your project directory), and returns the directory
where your project is located.  We then cd there and source
the $PROJECTRC file (if it exists).

In practice, things are a bit more complicated, and there are
some bells and whistles, but if you understand the above,
then you understand VSPMS.

Concept of "base environment":

This version of VSPMS has the concept of a "base" or "home"
environment that is set whenever you execute the first
chpj, pushpj, or pjresethome commands.  See the section
under "pjresethome" below for more information.

Brief guide to VSPMS commands:

	alias			description:
	----------------------------------------------------------------
	lspj	lists your project names and locations.

	addpj [project_name]
		add the current working directory as "project_name"

	chpj [project_name]
		changes the current project to "project_name",
		and sources the $PROJECTRC file to establish
		the project environment.  If no name is given,
		re-establishes the current project environment.

	pushpj [project_name|+n]
		pushes the named project on the directory
		stack.  With no arguments, exchanges the
		top two projects.  The +n form rotates the
		nth project to the top of the stack. (Same
		semantics as pushd.)  Note that if you have
		a project defined as a sub-directory of
		another project, pushpj gets confused.  To
		recover, use chpj to re-enter the project.

	poppj	pops the top project of the directory
		stack

	pjenv	prints the current project environment.

	newpjenv filename
		change project index file to filename.

	pjresethome
		Make the current environment the "base" environment.
		This command saves your current environment variable
		definitions and your current alias definitions to disk.
		Each time you change to a new project, All variables
		and aliases not in your base environment are deleted.
		Environment variables whose definitions have changed
		are reset to the original value.  However, alias that have
		been changed retain their new definition. (This is due
		to the technical difficulties in restoring aliases to
		their original form when they involve complicated quoting.
		Because of this, you should consider any alias you define
		in your home environment as global and read-only.)

	========================== SUBPROJECTS ==========================

	subpj [sub_project_dir]
		change to a new sub-project.  Sub-projects are names
		of directories under the "main" project name, i.e.,
		if the project is comprised of directories:

			/usr/myproject/src/{include,lib,bin}

		and the main project directory is /usr/myproject/src,
		then possible sub-projects are:

			{include,lib,bin}

		In this example:

			subpj .		#will take you to /usr/myproject/src/. (the root)
			subpj lib	#will take you to the /usr/myproject/src/lib

		The $PROJECTRC (.projectrc) file for the project only needs to
		be created in the root project directory.  Thus
		sub-projects are defined to be all sub-trees
		sharing the same .projectrc file (and hence a
		common REV label, if there is one.)
		
	popspj
		pop a sub-project off the directory stack.

	pushspj [+n] [proj_name]
		push a new sub-project on directory stack.

To use these commands, you must define the following environment
variable:

	setenv MYPROJECTS my_project_index

(Note that the default value for $MYPROJECTS is "~/myprojects". Edit
your .cshrc file if you want to change it to something else.)

Your project index file has 2 columns:

	project_name	project_directory

You may create $MYPROJECT files that include other files.  Environment
variables in %include statements are expanded.

Example:

	#########       ##########
	#nickname		directory
	#########       ##########
	fooproject		$HOME/foo
	#
	%include ~russt/projects.$HOSTNAME

Beware of nested includes.

Note that the second column is exposed to the shell, so
meta-characters meaningful to the shell ("~", "$", etc.)
will be expanded normally.

The project location (directory) can have a $PROJECTRC file, to
establish the project environment - here is an example of a simple
$PROJECTRC file:

		# .projectrc file
		setenv REV v100
		set path = (/usr/newstuff $path)
		echo HELLO YOU ARE IN A PROJECT

Note that if REV is defined it is displayed whenever you change
to the project.

Don't forget:

If you allowed installpj to modify your .cshrc file, then issue the command:

	source ~/.cshrc

for your new aliases to take effect now. (or logout and log back in).

Note:  You may repeat this command to see this help message again.
-------------------------------------------------------------------------------
'EOF'
