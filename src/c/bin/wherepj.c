#include <stdio.h>
#include <ctype.h>

#define		streq(s1,s2)	(strcmp(s1,s2) == 0)

#define PJ_MAP_VAR "MYPROJECTS"

extern char *projname();
extern char *projdir();
extern char *getenv();

main(argc,argv,envp)
/*
 * wherepj - search for a project name in the project map file,
 * and return the project directory name
 */
int argc;
char *argv[];
char *envp[];
{
  char buf[BUFSIZ], *p, proj_map[BUFSIZ];
  FILE *fp;

  /*
   * first, check to see if this guy is aware of project management stuff.
   * if not, give error and exit:
   */

  p = proj_map;
  strcpy(p,getenv(PJ_MAP_VAR));

  if (p == NULL)
  {
    fprintf(stderr,"%s:  %s is undefined\n",argv[0],PJ_MAP_VAR);
    fprintf(stdout,"NULL\n");
    exit(-1);
  }

  /*
   * is the project list file accessible?
   */
  if ((fp = fopen(proj_map,"r")) == NULL)
  {
    fprintf(stderr,"%s:  can't open %s\n",argv[0],proj_map);
    fprintf(stdout,"NULL\n");
    exit(-1);
  }

  /*
   * default is to echo users home dir, so that chpj with
   * no args will take you home:
   */
  if (argc < 2)
  {
    fprintf(stdout,"%s\n",getenv("HOME"));
    exit(0);
  }

  /*
   * if arg. given, and of the form '+' <integer>,
   * just echo the arg, so we can pass on to pushd
   */
  if (argv[1][0] == '+' && isdigit(argv[1][1]))
  {
    fprintf(stdout,"%s\n",argv[1]);
    exit(0);
  }

  /*
   * Otherwise, search the project file:
   */
  while (fgets(buf,BUFSIZ,fp) != NULL)
  {
    if (streq(argv[1], projname(buf)))
    {
      fputs(projdir(buf),stdout);
      exit(0);
    }
  }

  fprintf(stderr,"%s:  no such project, %s\n",argv[0], argv[1]);
  fprintf(stdout,"NULL\n");
  exit(-1);
}

char *
projname(buf)
/*
 * the project name is the first field
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
 * the project dir is the second field
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
