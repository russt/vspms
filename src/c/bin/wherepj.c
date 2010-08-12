/*
** wherepj - search for a project name in the project map file,
**
** Copyright (C) 1990 Russ Tremain.
**
**  This program is free software; you can redistribute it and/or modify
**  it under the terms of the GNU General Public License as published by
**  the Free Software Foundation; either version 2 of the License, or
**  (at your option) any later version.
**
**  This program is distributed in the hope that it will be useful,
**  but WITHOUT ANY WARRANTY; without even the implied warranty of
**  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**  GNU General Public License for more details.
**
**  You should have received a copy of the GNU General Public License
**  along with this program; if not, write to the Free Software
**  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
*/

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
			fprintf(stderr,"%s:  %s is undefined\n",prog, PROJECT_VAR);
			fprintf(stdout,"NULL\n");
			exit(1);
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
** returns 0 if no errors.
*/
char fn[];
{
	char buf[BUFSIZ], proj[BUFSIZ];
	FILE *fp;
	int nerrs = 0;
	int result = 0;

	/*
	** is the project list file accessible?
	*/
	if ((fp = fopen(fn,"r")) == NULL)
	{
		fprintf(stderr, "%s: WARNING: can't open %s\n",prog,fn);
		return(1);
	}

	/*
	** Otherwise, search the project file:
	*/
	while (fgets(buf,BUFSIZ,fp) != NULL) {
		strcpy(proj,projname(buf));
		if (streq(proj, "%include")) {
			/* PROCESS INCLUDE file */
			fprintf(stdout, "<BEGIN INCLUDE %s>\n", projdir(buf));
			result = lspj(projdir(buf));
			fprintf(stdout, "<%s INCLUDE %s>\n", (result == 0 ? "END" : "FAILED"), projdir(buf));
			nerrs += result;
		} else {
			fprintf(stdout, "%s\t%s\n", proj, projdir(buf));
		}
	}

	fclose(fp);
	return(nerrs);
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
#if DEBUG
		perror("wherepj");
#endif DEBUG
		return(0);
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

#if DEBUG
fprintf(stderr,"projname='%s'\n",retval);
#endif DEBUG

	return(retval);
}

char *
expand_env(buf)
/*
** interpolate any environment variables in <buf>
*/
char *buf;
{
	static char retval[BUFSIZ];
	char cmd[BUFSIZ], tmpfn[BUFSIZ];
	int has_evar = 0;
	int errs = 0;
	int ii = 0;
	FILE *fp;

	retval[0] = '\0';

	strcpy(retval,buf);

	has_evar = 0;
	ii = 0;
	while(buf[ii] != '\0') {
		if (buf[ii] == '$') {
			has_evar = 1;
			break;
		}
		++ii;
	}

	if (has_evar) {
		sprintf(tmpfn, "/tmp/%s.%d", prog, getpid());
		sprintf(cmd, "echo %s > %s", retval, tmpfn);
#if DEBUG
		fprintf(stderr,"cmd='%s' tmpfn='%s'\n",cmd, tmpfn);
#endif DEBUG

		system(cmd);

		if ((fp = fopen(tmpfn,"r")) != NULL) {
			/* read the result: */
			if (fgets(retval,BUFSIZ,fp) != NULL) {
				/* trim EOL chars: */
				ii = strlen(retval) - 1;
				while (retval[ii] == '\n' || retval[ii] == '\r') {
					retval[ii++] = '\0';
				}

			} else {
				++errs;
			}

			/* clean up: */
			fclose(fp);
			unlink(tmpfn);
		} else {
			++errs;
		}

		if (errs != 0) {
			fprintf(stderr,"%s:  WARNING:  Errors interpolating '%s'\n", prog, buf);
		}
	}

#if DEBUG
	fprintf(stderr,"expand_env retval='%s'\n", retval);
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
		retval[0] = '\0';
	} else {
		retval[i-1] = '\0';
	}

#if DEBUG
fprintf(stderr,"projdir='%s'\n",retval);
#endif DEBUG

	strcpy(retval, expand_env(retval));
	return(retval);
}
