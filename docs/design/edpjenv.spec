this program does the following:
-keeps an internal cache of active projects.

get dir
	if dir is in the project cache, then returns associated PROJ and SUBPJ
	if not in cache, then prints:

		dir .	(project, subproject)

	and enters in cache

set dir project [subproject|+n]
	if dir is in the project cache, then NOP

	if not in cache, then adds the triple (dir,project,subproject)

del dir
	if dir is in the project cache, then delete it
