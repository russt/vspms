#include <stdio.h>
#include <ctype.h>

#define USAGE_SET	"Usage:  %s set dir project [subproj|+n]\n"
#define USAGE_GET	"Usage:  %s get dir\n"
#define USAGE_DEL	"Usage:  %s del dir\n"

#define		streq(s1,s2)	(strcmp(s1,s2) == 0)

/* storage for parsed environment var: */
#define MAXENV	20
#define MAXLEN	100
char dirEnv[MAXENV][MAXLEN];
char projEnv[MAXENV][MAXLEN];
char sbpjEnv[MAXENV][MAXLEN];
int nEnv;

/* the name of the environment var used to tell us pjenv_fn: */
#define PJENV_VAR "PROJECT_ENV"

/* the name of the tmp file used to save environment: */
char pjenv_fn[MAXLEN];

char argv0[MAXLEN];

extern char *getenv();

main(argc,argv,envp)
/*
**	edpjenv -
**		maintain cache file of active projects
**	
**	OPERATIONS:
**
**	get dir
**		if dir is in the project cache, echo (project, subproject)
**		if not in cache, then echo (dir .), and enter in cache.
**	
**	set dir project [subproject|+n]
**		if dir is in the project cache, then NOP
**		if not in cache, then adds the triple (dir,project,subproject)
**	
**	del dir
**		if dir is in the project cache, then delete it
*/
int argc;
char *argv[];
char *envp[];
{
	char buf[BUFSIZ], *p;
	char dir[MAXLEN];
	char proj[MAXLEN];
	char subpj[MAXLEN];
	int argn = 1;

	strcpy(argv0,argv[0]);

	if (argc < 2) {
		fprintf(stderr,USAGE_SET,argv[0]);
		fprintf(stderr,USAGE_GET,argv[0]);
		fprintf(stderr,USAGE_DEL,argv[0]);
		exit(1);
	}

	p = getenv(PJENV_VAR);

	if (p == NULL)
	{
		fprintf(stderr,"%s:  %s is undefined\n",argv0,PJENV_VAR);
		exit(1);
	}
	else
		strcpy(pjenv_fn,p);


	parseEnv();

	switch (argv[argn][0]) {
	case 'd':
		/* Usage:  del dir */
		if (argc < 3) {
			fprintf(stderr,USAGE_DEL,argv[0]);
			exit(1);
		}
		strcpy(dir,argv[++argn]);
		delpjenv(dir);
		break;
	case 'g':
		/* Usage:  get dir */
		if (argc < 3) {
			fprintf(stderr,USAGE_GET,argv[0]);
			exit(1);
		}
		strcpy(dir,argv[++argn]);
		getpjenv(dir);
		break;
	case 's':
		/* Usage:  set dir project [subproject|+n] */
		if (argc < 4) {
			fprintf(stderr,USAGE_SET,argv[0]);
			exit(1);
		}
		strcpy(dir,argv[++argn]);
		strcpy(proj,argv[++argn]);
		if (argn < argc)
			strcpy(subpj,argv[++argn]);
		else
			subpj[0] = '\0';
		setpjenv(dir,proj,subpj);
		break;
	default:
		fprintf(stderr,USAGE_SET,argv[0]);
		fprintf(stderr,USAGE_GET,argv[0]);
		fprintf(stderr,USAGE_DEL,argv[0]);
		exit(1);
	}

	exit(0);
}

setpjenv(dir,proj,subpj)
/*
**	set dir project [subproject|+n]
**		if dir is in the project cache, then NOP
**		if not in cache, then adds the triple (dir,project,subproject)
*/
register char *dir;
char *proj, *subpj;
{
	register int i;

	for (i=0; i< nEnv; i++) {
		if (streq(dir,dirEnv[i])) {
			return;
		}
	}

	if (nEnv < MAXENV) {
		strcpy(dirEnv[nEnv],dir);
		strcpy(projEnv[nEnv],proj);
		strcpy(sbpjEnv[nEnv],subpj);
		++nEnv;
	}
	else {
		fprintf(stderr,"set: project cache overflow, max is %d\n",
			MAXENV);
		exit(1);
	}

	updateEnv();
}

getpjenv(dir)
/*
**	get dir
**		if dir is in the project cache, echo (project, subproject)
**		if not in cache, then echo (dir .), and enter in cache.
*/
register char *dir;
{
	register int i;

	for (i=0; i< nEnv; i++) {
		if (streq(dir,dirEnv[i])) {
			printf("%s %s %s\n",dir,projEnv[i],sbpjEnv[i]);
			return;
		}
	}

	printf("%s .\n",dir);
}

delpjenv(dir)
/*
**	del dir
**		if dir is in the project cache, then delete it
*/
register char *dir;
{
	register int i;

	for (i=0; i< nEnv; i++) {
		if (streq(dir,dirEnv[i])) {
			dirEnv[i][0] = '\0';
			updateEnv();
			return;
		}
	}

}

updateEnv()
/*
**	update the environment string
*/
{
	register int i;
	char buf[BUFSIZ*4];
	char tmp[BUFSIZ/2];
	FILE *fp;

	buf[0] = '\0';
	for (i=0; i< nEnv; i++) {
		if (dirEnv[i][0] != '\0') {
			sprintf(tmp, "%s;%s;%s;",
				dirEnv[i], projEnv[i], sbpjEnv[i]);
			strcat(buf,tmp);
		}
	}

	/*
	** open env file for writing...
	*/
	if ((fp = fopen(pjenv_fn,"w")) != NULL) {
		fwrite(buf,strlen(buf),1,fp);
		fclose(fp);
	}
	else {
		fprintf(stderr,"%s:  can't create env tmp file, %s\n",
			argv0,pjenv_fn);
		exit(1);
	}
}

parseEnv()
/*
** retrieve the current project environment, if any, and store
** in parallel array structures
*/
{
	register int j;
	char buf[BUFSIZ*4];
	register char *p = buf;
	FILE *fp;

	/*
	** if env file exists...
	*/
	*p = '\0';
	if ((fp = fopen(pjenv_fn,"r")) != NULL) {
		/* ...then read the whole file into a buf: */
		fread(p,BUFSIZ*4,1,fp);
		fclose(fp);
	}

	nEnv = 0;

	/* read env file into arrays: */
	while (*p) {
		for (j=0;*p != ';' && *p; j++,p++)
			dirEnv[nEnv][j] = *p;

		++p;	/* skip semi-colon */
		for (j=0;*p != ';' && *p; j++,p++)
			projEnv[nEnv][j] = *p;

		++p;	/* skip semi-colon */
		for (j=0;*p != ';' && *p; j++,p++)
			sbpjEnv[nEnv][j] = *p;

		++p;	/* skip final semi-colon */

		nEnv++;
	}
}

#ifdef	DEBUG
dumpEnv()
/*
**	print the environment arrays
*/
{
	register int i;

	for (i=0; i< nEnv; i++) {
		printf("%s %s %s\n", dirEnv[i], projEnv[i], sbpjEnv[i]);
	}

}
#endif	DEBUG
