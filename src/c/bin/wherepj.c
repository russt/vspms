#include <stdio.h>
#include <ctype.h>

#define		streq(s1,s2)	(strcmp(s1,s2) == 0)

#define PJ_MAP_VAR "MYPROJECTS"
#define PROJECT_VAR "PROJECT"

extern char *projname();
extern char *projdir();
extern char *getenv();

main(argc,argv,envp)
/*
** wherepj - search for a project name in the project map file,
** and return the project directory name
*/
int argc;
char *argv[];
char *envp[];
{
	char buf[BUFSIZ],*p, proj_map[BUFSIZ];
	FILE *fp;
	int argn = 1, subpj = 0;

	/*
	** first, check to see if project management environment
	** established. if not, display error message and exit:
	*/

	p = getenv(PJ_MAP_VAR);

	if (p == NULL)
	{
		fprintf(stderr,"%s:  %s is undefined\n",argv[0],PJ_MAP_VAR);
		fprintf(stdout,"NULL\n");
		exit(-1);
	}
	else
		strcpy(proj_map,p);

	/*
	** is the project list file accessible?
	*/
	if ((fp = fopen(proj_map,"r")) == NULL)
	{
		fprintf(stderr,"%s:  can't open %s\n",argv[0],proj_map);
		fprintf(stdout,"NULL\n");
		exit(-1);
	}

	/*
	** default is to echo nothing, so chpj will re-establish the
	** current project environment, and pushpj will switch top
	** two elements on dir stack.
	*/
	if (argn >= argc)
		exit(0);

	/* if sub-project option... */
	if (streq(argv[argn],"-s")) {
		subpj = 1;
		++argn;
	}

	if (argn >= argc)
		exit(0);

	/*
	** if more args, and of the form '+' <integer>,
	** just echo the arg, so we can pass on to pushd
	*/
	if (argv[argn][0] == '+' && isdigit(argv[argn][1])) {
		fprintf(stdout,"%s\n",argv[argn]);
		exit(0);
	}

	if (subpj) {
		/* look up PROJECT environment var, and echo
		** PROJECT/argn[argn]
		*/
		p = getenv(PROJECT_VAR);

		if (p == NULL)
		{
			fprintf(stderr,"%s:  %s is undefined\n",argv[0],
				PROJECT_VAR);
			fprintf(stdout,"NULL\n");
			exit(-1);
		}

		fprintf(stdout,"%s/%s\n",p,argv[argn]);
		exit(0);
	}

	/*
	** Otherwise, search the project file:
	*/
	while (fgets(buf,BUFSIZ,fp) != NULL) {
		if (streq(argv[argn], projname(buf))) {
			fputs(projdir(buf),stdout);
			exit(0);
		}
	}

	fprintf(stderr,"%s:  no such project, %s\n",argv[0], argv[argn]);
	fprintf(stdout,"NULL\n");
	exit(-1);
}

char *
projname(buf)
/*
** the project name is the first field
*/
char *buf;
{
	static char retval[BUFSIZ];
	int i=0;

	retval[0] = '\0';

	while(!isspace(*buf) && *buf != '\0')
	{
		retval[i++] = *buf;
		++buf;
	}

	retval[i] = '\0';
	return(retval);
}

char *
projdir(buf)
/*
** the project dir is the second field
*/
char *buf;
{
	static char retval[BUFSIZ];
	int i=0;

	retval[0] = '\0';

	/* find first white-space: */
	while(!isspace(*buf) && *buf != '\0')
		++buf;

	/* skip white-space: */
	while(isspace(*buf) && *buf != '\0')
		++buf;

	while(*buf != '\0')
	{
		retval[i++] = *buf;
		++buf;
	}

	retval[i] = '\0';
	return(retval);
}
