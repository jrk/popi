
/***  io.c   (file handler)  ************************/

#include	<stdio.h>
#include	"popi.h"

extern struct SRC src[MANY];
extern int nsrc, noerr;
extern char *Emalloc();

getpix(into, str)
	struct SRC *into;	/* work buffer */
	char *str;		/* file name   */
{
	FILE *fd;
	int i;

	if ((fd = fopen(str, "r")) == NULL)
	{	fprintf(stderr, "no file %s\n", str);
		return;
	}

	if (into->pix == (unsigned char **) 0)
	{	into->pix = (unsigned char **)
			Emalloc(DEF_Y * sizeof(unsigned char *));
		for (i = 0; i < DEF_Y; i++)
			into->pix[i] = (unsigned char *)
				Emalloc(DEF_X);
	}
	into->str = (char *) Emalloc(strlen(str)+1);
	if (!noerr) return;	/* set by Emalloc */

	for (i = 0; i < DEF_Y; i++)
		fread(into->pix[i], 1, DEF_X, fd);
	strcpy(into->str, str);

	fclose(fd);
	nsrc++;
}

#ifdef NODOS

putpix(into, str)
	struct SRC *into;	/* work buffer */
	char *str;		/* file name   */
{
	FILE *fd;
	int i;

	if ((fd = fopen(str, "w")) == NULL)
	{	fprintf(stderr, "cannot create %s\n", str);
		return;
	}
	for (i = 0; i < DEF_Y; i++)
		fwrite(into->pix[i], 1, DEF_X, fd);
	fclose(fd);
}

#else

putpix(into, str)
	struct SRC *into;
	char *str;
{
	FILE *fd;
	int i, j;
	static unsigned char *buffer;
	register unsigned char c, *p, *q;

	if ((fd = fopen(str, "w")) == NULL)
	{	fprintf(stderr, "cannot create %s\n", str);
		return;
	}
	if (!buffer)
		buffer = (unsigned char *) Emalloc(DEF_X);

	for (i = 0; i < DEF_Y; i++)
	{	for (j = 0, p=buffer, q=into->pix[i]; j < DEF_X; j++)
		{	c = *q++;
			*p++ = (c==10||c==26)?c-1:c;
		}
		fwrite(buffer, 1, DEF_X, fd);
	}
	fclose(fd);
}
#endif

showfiles()
{	int n;

	if (nsrc == 2)
		printf("no files open\n");
	else
		for (n = 2; n < nsrc; n++)
			printf("$%d = %s\n", n-1, src[n].str);
}
