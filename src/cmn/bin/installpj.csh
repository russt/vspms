#! /bin/csh -f
# script to install or reinstall VSPMS command aliases

echo -n "This script will modify your .cshrc file.  'y' to continue: "
set ans=$<
if ($ans != y) then
  echo "Aborted..."
  exit -1
endif

ed - ~/.cshrc << 'EOF'
g/alias[ 	]lspj[ 	]/d
g/alias[ 	]chpj[ 	]/d
g/alias[ 	]pjenv[ 	]/d
g/alias[ 	]pushpj[ 	]/d
g/alias[ 	]poppj[ 	]/d
g/alias[ 	]swpj[ 	]/d
$a
alias lspj 'cat $MYPROJECTS'
alias chpj 'cd `wherepj \!*`;setenv PROJECT `pwd`;setenv REV NONE;dirs;source .projectrc>&/dev/null;echo $REV'
alias pushpj 'set tmp=`wherepj \!*`;pushd $tmp; setenv PROJECT `pwd`;setenv REV NONE;source .projectrc>&/dev/null;echo $REV'
alias poppj 'popd;setenv PROJECT `pwd`;setenv REV NONE;source .projectrc>&/dev/null;echo $REV'
alias pjenv 'echo Project $PROJECT, Revision $REV;echo Project table is $MYPROJECTS;echo -n "Directory stack is:  ";dirs'
alias swpj 'pushpj'
.
w
q
'EOF'
more <<'EOF'
-------------------------------------------------------------------------------

The following project management aliases have been newly installed,
or updated, in your .cshrc file:

	alias			description:
	-------------------	---------------------------------------------
	lspj			lists your project names and locations.

	chpj [project_name]	changes the current project to "project_name",
				and sources the .projectrc file to establish
				the project environment.  If no name is given,
				re-establishes the current project environment.

	pushpj [project_name|+n]
				pushes the named project on the directory
				stack.  With no arguments, exchanges the
				top two projects.  The +n form rotates the
				nth project to the top of the stack. (Same
				semantics as pushd.)

	poppj [+n]		pops the top project of the directory
				stack, or the nth project if +n argument
				given.  (Same semantics as popd.)

	swpj			exchanges the top two projects on the
				directory stack.  (Same as pushpj with
				no arguments.)

	pjenv			prints the current project environment.

For these aliases to have effect, you must define the following environment
variable:

	setenv MYPROJECTS my_project_index

Your project index file has 2 columns:

	project_name	project directory

The project directory should have a ".projectrc" file, to establish the
project environment - here is an example:

		# standard .projectrc file
		setenv REV V0210d4
		alias pci "echo $REV; ci -N$REV \!*"
		alias pco "echo $REV; co -r$REV \!*"

Issue the command:

	source ~/.cshrc

for your new aliases to take effect now.

Note:  You may repeat this command to see this help message again.
-------------------------------------------------------------------------------
'EOF'
