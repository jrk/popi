
/***  main.c ****************************************/

#include	<stdio.h>
#include	<ctype.h>
#include	"popi.h"

int	parsed[MANY];
struct	SRC	src[MANY];
short	CUROLD=0, CURNEW=1;
int	noerr, lexval, prs=0, nsrc=2;
char	text[256];

char *Emalloc();

main(argc, argv)
	char **argv;
{
	int i;

	src[CUROLD].pix = (unsigned char **)
		Emalloc(DEF_Y * sizeof(unsigned char *));
	src[CURNEW].pix = (unsigned char **)
		Emalloc(DEF_Y * sizeof(unsigned char *));

	for (i = 0; i < DEF_Y; i++)
	{	src[CUROLD].pix[i] = (unsigned char *)
			Emalloc(DEF_X);
		src[CURNEW].pix[i] = (unsigned char *)
			Emalloc(DEF_X);
	}

	for (i = 1; i < argc; i++)
		getpix(&src[nsrc], argv[i]);

	do noerr=1; while( parse() );
}

parse()
{	extern int lat;		/* look ahead token */

	printf("-> ");
	while (noerr)
	{	switch (lat = lex()) {
		case  'q': return 0;
		case '\n': return 1;
		case  ';': break;
		case  'f': showfiles();
			   break;
		case  'r': getname();
			   if (!noerr) continue;
			   getpix(&src[nsrc], text);
			   break;
		case  'w': getname();
			   if (!noerr) continue;
			   putpix(&src[CUROLD], text);
			   break;
		/* example of adding a function defined in lib.c */
		case  'u': slicer();
			   CUROLD = CURNEW; CURNEW = 1-CUROLD;
			   break;
		default  : transform();
			   if (noerr) run();
			   break;
	}	}
}

getname()
{	int t = lex();

	if (t != NAME && t != FNAME && !isalpha(t))
		error("expected name, bad token: %d\n", t);
}

emit(what)
{
	if (prs >= MANY)
		error("expression too long\n");
	parsed[prs++] = what;
}

error(s, d)
	char *s;
{
	extern int lat;

	fprintf(stderr, s, d);
	while (lat != '\n')
		lat = lex();
	noerr = 0;	/* noerr is now false */
}

char *
Emalloc(N)
{	char *try, *malloc();

	if ((try = malloc(N)) == NULL)
		error("out of memory\n");
	return try;
}
