#include <stdio.h>
#include <ctype.h>

#define	DEBUG 0

#define		streq(s1,s2)	(strcmp(s1,s2) == 0)

#define PJ_MAP_VAR "MYPROJECTS"
#define PROJECT_VAR "PROJECT"

extern int errno;
extern char *projname();
extern char *projdir();
extern char *getenv();

char prog[BUFSIZ];

main(argc,argv,envp)
/*
** wherepj - search for a project name in the project map file,
** and return the project directory name
*/
int argc;
char *argv[];
char *envp[];
{
	int argn = 1, subpj = 0;
	char *p, proj_map[BUFSIZ], dirstr[BUFSIZ];

	strcpy(prog,argv[0]);

	/*
	** first, check to see if project management environment
	** established. if not, display error message and exit:
	*/

	p = getenv(PJ_MAP_VAR);

	if (p == NULL)
	{
		fprintf(stderr,"%s:  %s is undefined\n",prog,PJ_MAP_VAR);
		fprintf(stdout,"NULL\n");
		exit(1);
	}
	else
		strcpy(proj_map,p);

	/*
	** default is to echo nothing, so chpj will re-establish the
	** current project environment, and pushpj will switch top
	** two elements on dir stack.
	*/
	if (argn >= argc)
		exit(0);

	/*
	** PROCESS FLAGS:
	*/


	while (argn < argc && argv[argn][0] == '-') {
		if (streq(argv[argn],"-s")) {
			subpj = 1;
			++argn;
		} else if (streq(argv[argn],"-lspj")) {
			lspj(proj_map);
			++argn;
			exit(0);
		} else {
			fprintf(stderr,"%s:  '%s' is not a valid option.\n",prog,argv[argn]);
			exit(1);
		}
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
			fprintf(stderr,"%s:  %s is undefined\n",prog,
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
	if (searchpjfile(&dirstr[0], argv[argn], proj_map)) {
		fprintf(stdout,"%s\n",dirstr);
		exit(0);
	} else {
		fprintf(stderr,"%s:  no such project, %s\n",prog, argv[argn]);
		fprintf(stdout,"NULL\n",dirstr);
	}

	exit(1);
}

int
lspj(fn)
/*
** list the project index files, and interprolate the include files.
*/
char fn[];
{
	char buf[BUFSIZ], proj[BUFSIZ];
	FILE *fp;

	/*
	** is the project list file accessible?
	*/
	if ((fp = fopen(fn,"r")) == NULL)
	{
		fprintf(stderr, "%s:  can't open %s\n",prog,fn);
		perror("wherepj");
		fprintf(stdout,"NULL\n");
		exit(1);
	}

	/*
	** Otherwise, search the project file:
	*/
	while (fgets(buf,BUFSIZ,fp) != NULL) {
		strcpy(proj,projname(buf));
		if (streq(proj, "%include")) {
			/* PROCESS INCLUDE file */
			fprintf(stdout, "%s", buf);
			lspj(projdir(buf));
			fprintf(stdout, "<END INCLUDE>\n");
		} else {
			fputs(buf,stdout);
		}
	}

	fclose(fp);
	return(0);
}
int
searchpjfile(dirstr, look4, fn)
/*
** look in <fn> for <look4>.  if found, return true with result in <dirstr>.
** if not found, return false with "NULL" in <dirstr>.
*/
char *dirstr, look4[], fn[];
{
	char buf[BUFSIZ], buf2[BUFSIZ], proj[BUFSIZ];
	FILE *fp;

	strcpy(dirstr,"NULL");

#if DEBUG
fprintf(stderr, "looking for '%s' in file '%s'\n", look4, fn);
#endif DEBUG

	/*
	** is the project list file accessible?
	*/
	if ((fp = fopen(fn,"r")) == NULL)
	{
		fprintf(stderr, "%s:  can't open %s\n",prog,fn);
		perror("wherepj");
		fprintf(stdout,"NULL\n");
		exit(1);
	}

	/*
	** Otherwise, search the project file:
	*/
	while (fgets(buf,BUFSIZ,fp) != NULL) {
		strcpy(proj,projname(buf));
		if (streq(proj, "%include")) {
			/* PROCESS INCLUDE file */
			if (searchpjfile(&buf2[0], look4, projdir(buf))) {
				strcpy(dirstr, buf2);
				fclose(fp);
				return(1);		/* found in include file */
			}
		} else if (streq(look4, proj)) {
			strcpy(dirstr, projdir(buf));
			fclose(fp);
			return(1);
		}
	}

	fclose(fp);
	return(0);
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

#if DEBUG > 1
fprintf(stderr,"projname='%s'\n",retval);
#endif DEBUG

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

	if (i <= 0) {
		retval[i] = '\0';
	} else {
		retval[i-1] = '\0';
	}

#if DEBUG > 1
fprintf(stderr,"projdir='%s'\n",retval);
#endif DEBUG

	return(retval);
}
