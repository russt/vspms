#include <stdio.h>
#include <ctype.h>

#define USAGE_SET	"Usage:  %s set dir project [subproj|+n]\n"
#define USAGE_RESET	"Usage:  %s reset dir old_project old_subpj\n"
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
**	reset dir project subproject
**		if proj is contained in dir, reset the project environment
**		for proj/subpj to be (dir,proj,new), where new dir-proj.
**		if proj is not contained in dir, reset to (dir,dir,"."), 
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
	int argn = 1, set_op;

	strcpy(argv0,argv[0]);

	if (argc < 2) {
		fprintf(stderr,USAGE_SET,argv[0]);
		fprintf(stderr,USAGE_RESET,argv[0]);
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
		++argn;		/* skip keyword */
		/* Usage:  del dir */
		if (argc < 3) {
			fprintf(stderr,USAGE_DEL,argv[0]);
			exit(1);
		}
		strcpy(dir,argv[argn++]);
		normalize(dir);
		delpjenv(dir);
		break;
	case 'g':
		++argn;		/* skip keyword */
		/* Usage:  get dir */
		if (argc < 3) {
			fprintf(stderr,USAGE_GET,argv[0]);
			exit(1);
		}
		strcpy(dir,argv[argn++]);
		normalize(dir);
		getpjenv(dir);
		break;
	case 's':
	case 'r':
		set_op = (argv[argn][0] == 's');
		++argn;		/* skip keyword */
		/* Usage:  set dir project [subproject|+n] */
		if (argc < 4) {
			if (set_op)
				fprintf(stderr,USAGE_SET,argv[0]);
			else
				fprintf(stderr,USAGE_RESET,argv[0]);
			exit(1);
		}
		strcpy(dir,argv[argn++]);
		normalize(dir);
		strcpy(proj,argv[argn++]);
		if (argn < argc) {
			strcpy(subpj,argv[argn++]);
		}
		else
			strcpy(subpj,".");
		if (set_op)
			setpjenv(dir,proj,subpj);
		else
			resetpjenv(dir,proj,subpj);
		break;
	default:
		fprintf(stderr,USAGE_SET,argv[0]);
		fprintf(stderr,USAGE_RESET,argv[0]);
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
			printf("%s %s\n",projEnv[i],sbpjEnv[i]);
			return;
		}
	}

	printf("%s .\n",dir);

	/* enter in cache: */
	setpjenv(dir,dir,".");
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

resetpjenv(dir,proj,subpj)
/*
**	if proj is contained in dir, reset the project environment
**	for proj/subpj to be (dir,proj,new), where new dir-proj.
**
**	if proj is not contained in dir, reset to (dir,dir,"."), 
*/
register char *dir;
char *proj, *subpj;
{
	char tmp[MAXLEN], *p;
	register int i;
	int is_subpj;

	strcpy(tmp,dir);
	tmp[strlen(proj)] = '\0';
	is_subpj = streq(tmp,proj);

	sprintf(tmp,"%s/%s",proj,subpj);	/* formulate search key */
	normalize(tmp);

	for (i=0; i< nEnv; i++) {
		if (streq(tmp,dirEnv[i])) {
			strcpy(dirEnv[i],dir);
			if (is_subpj) {
				strcpy(projEnv[i],proj);
				/* the new sub-project is derived from dir: */
				strcpy(sbpjEnv[i], &dir[strlen(proj)+1]);
				if (sbpjEnv[i][0] == '\0')
					strcpy(sbpjEnv[i],".");
			}
			else {
				/* o'wise, use defaults: */
				strcpy(projEnv[i],dir);
				strcpy(sbpjEnv[i],".");
			}

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
	FILE *fp;

	/*
	** open env file for writing...
	*/
	if ((fp = fopen(pjenv_fn,"w")) == NULL) {
		fprintf(stderr,"%s:  can't create env tmp file, %s\n",
			argv0,pjenv_fn);
		exit(1);
	}

	for (i=0; i< nEnv; i++) {
		if (dirEnv[i][0] != '\0') {
			fprintf(fp, "%s;%s;%s\n",
				dirEnv[i], projEnv[i], sbpjEnv[i]);
		}
	}

	fclose(fp);
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
		for (j=0;*p != ';' && *p; p++)
			dirEnv[nEnv][j++] = *p;
		dirEnv[nEnv][j++] = '\0';
		++p;	/* skip semi-colon */

		for (j=0;*p != ';' && *p; p++)
			projEnv[nEnv][j++] = *p;
		projEnv[nEnv][j++] = '\0';
		++p;	/* skip semi-colon */

		for (j=0;*p != '\n' && *p; p++)
			sbpjEnv[nEnv][j++] = *p;
		sbpjEnv[nEnv][j++] = '\0';
		++p;	/* skip final newline */

		nEnv++;
	}
}

normalize(dir)
/* normalize a directory name, by deleting trailing '/' or '/.'
** (unless the full pathname is '/').
*/
char *dir;	/* value-result */
{
	register int len;

	len = strlen(dir)-1;

	if (len > 0) {
		if (dir[len] == '.')
			dir[len] = '\0';
	}
	--len;

	if (len > 0) {
		if (dir[len] == '/')
			dir[len] = '\0';
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
