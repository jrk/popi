# To unbundle, sh this file
echo READ.ME 1>&2
sed 's/.//' >READ.ME <<'//GO.SYSIN DD READ.ME'
-
-                        Digital Darkroom Software
-                        =========================
-	Copyright (c) 1988 by Bell Telephone Laboratories, Incorporated.
-
-The software on this diskette is described in detail in Chapters 5 and 6
-of the book `Beyond Photography - the Digital Darkroom.' It should
-run on any system with a C compiler and the standard libraries.
-(e.g. UNIX, MS-DOS, CP/M, running on any hardware with 256kb of RAM
-or more).
-
-UNIX systems
-============
-On a UNIX system (UNIX is a registered trademark of AT&T) the software
-is compiled into an executable file named `popi' as follows:
-	cc -o popi expr.c io.c lex.c lib.c main.c run.c
-
-On other systems you may have to find out exactly where standard
-libraries and header files are stored and include these explicitly.
-
-MS-DOS systems
-==============
-On my MS-DOS system (MS-DOS is a trademark of the Microsoft
-Corporation) running on an AT&T PC-6300+ computer, I compile `popi'
-as follows, using the Lattice C-compiler.
-All Lattice files (including the header files and the library files)
-are kept in directory c:\lc on this system. The environment variable
-`INCLUDE' is used by the compiler to find the header file `stdio.h'
-used in file `io.c.' After setting the variable, all files are first
-compiled and then linked with the appropriate libraries. Note, they
-may have different names on your system.
-In particular, the files `c:\lc\cd', `c:\lc\lcd', and `c:\lc\lcmd'
-(the C initialization code, the standard library, and the math library) are
-sometimes named `c:\lc\d\c', `c:\lc\d\lc', and `c:\lc\d\lcm', respectively.
-I use the `D' memory model.
-	set INCLUDE=c:\lc
-	lc -md expr.c io.c lex.c lib.c main.c run.c
-	link expr+io+lex+lib+main+run+c:\lc\cd,popi,,c:\lc\lcd+c:\lc\lcmd
-
-A Quick Test
-============
-To test that the software is running properly you can execute the
-following commands, where `$' is the operating system prompt, and
-`->' is the image editor's prompt. `face1' is a sample image file
-provided on the diskette. It is 248x248=61504 bytes long.
-	$ popi
-	-> r face1
-	-> new=$1
-	-> w out
-	-> q
-	$ 
-
-The two files `face1' and `out' should now be equal. On a UNIX system
-you can quickly verify that, for instance, by typing:
-	$ cmp face1 out
-	$ 
-
-which should produce no output.
-On an MS-DOS system you would compare the files as follows, where `A>'
-is the system prompt:
-	A> comp face1 out
-	Files compare OK
-	A> 
-
-
-Display
-=======
-When the software runs properly, your next assignment is to make
-or to find a display routine that can show the images on a monitor,
-a printer, or whatever output medium you choose. A first step
-might be to use a separate program to display the images:
-	$ popi
-	-> r face1
-	-> new=Z-$1
-	-> w nuface
-	-> q
-	$ display face1
-	$ display nuface
-	$ 
-
-An example display routine in BASIC is provided on the source diskette
-in ASCII form in a file called
-	DISPLAY.BAS
-If you have `gwbasic' and a display with medium or high resolution graphics,
-it lets you display an image with a simple, but quite effective
-dithering pattern to simulate greyscale (see Chapter 5, p. 106).
-It will prompt for a filename:
-	A> gwbasic display
-	file name? face1
-
-Use it as an example for writing your own display routines. It is not
-ideal. For one thing, it is quite slow.
-Secondly, BASIC and MS-DOS do not allow arbitary pixel values
-to be stored in files and read as if they were characters,
-so you will have to remove those values from an image before
-it is written to disk.
-You can trivially do that with `popi':
-
-	-> old==10||old==26?old-1:old	remove values 10 and 26
-	-> w nuface			write the file
-	-> q				quit
-	A> gwbasic display		etc.
-
-If you will be working on an MS-DOS system the best solution will
-be to make a change in the file `io.c', replacing routine `putpix()'
-with the alternative routine given there to filter out these values
-automatically each time a file is written to disk. (The alternative
-routine is in fact enabled by default. To turn it off include a
-statement "#define NODOS	1" at the beginning of the file.)
-
-The next step is to integrate the system specific display routines into
-the software itself, following the guidelines given in Chapter 5.
-Be convinced, it is well worth the effort!
-
-Note carefully that all software and all digitized photos on these
-diskettes are copyright protected.
-
-Murray Hill, January 1988
//GO.SYSIN DD READ.ME
echo display.bas 1>&2
sed 's/.//' >display.bas <<'//GO.SYSIN DD display.bas'
-10 CLS
-20 SCREEN 1		'Select graphics mode
-30 RES=8		'Use 8x8 halftoning screen
-40 DIM TRESH(8,8)	'Array with treshhold values
-45 			'Fill the array
-50 FOR Y = 0 TO RES-1
-60 FOR X = 0 TO RES-1
-70      READ TRESH(X,Y)
-90 NEXT X
-100 NEXT Y
-105 '
-110 DATA 0,128,32,160,8,136,40,168
-120 DATA 192,64,224,96,200,72,232,104
-130 DATA 48,176,16,144,56,184,24,152
-140 DATA 240,112,208,80,248,120,216,88
-150 DATA 12,140,44,172,4,132,36,164
-160 DATA 204,76,236,108,196,68,228,100
-170 DATA 60,188,28,156,52,180,20,148
-180 DATA 252,124,220,92,244,116,212,84
-185 					'Get the name of a 248x248 image file
-186 FOR I = 0 TO 16 : PRINT : NEXT I	'At bottom of the screen
-190 INPUT "file name";IMAGE$
-200 OPEN IMAGE$ FOR INPUT AS 2
-205 			'Read and display one byte (pixel) at a time
-210 FOR Y = 0 TO 247
-220 FOR X = 0 TO 247
-230     IF INPUT$(1,2) >= CHR$(TRESH(X MOD RES, Y MOD RES)) THEN PSET(X,Y)
-240 NEXT X
-250 NEXT Y
-255 '
-260 CLOSE 2		'Close the image file
-270 SCREEN 0		'Return to text mode
-270 END
//GO.SYSIN DD display.bas
echo expr.c 1>&2
sed 's/.//' >expr.c <<'//GO.SYSIN DD expr.c'
-
-/***  expr.c (parser)  ******************************/
-
-#include "popi.h"
-
-extern int	lexval, nsrc;
-extern struct	SRC	src[MANY];
-extern short	CUROLD, CURNEW;
-int		lat;	/* look ahead token */
-
-int op[4][7] = {
-	{ '*', '/', '%', 0, 0, 0, 0, },
-	{ '+', '-',   0, 0, 0, 0, 0, },
-	{ '>', '<',  GE, LE, EQ, NE, 0, },
-	{ '^', AND,  OR, 0, 0, 0, 0, },
-};
-
-expr()
-{	extern int prs;
-	extern int parsed[MANY];
-	int remem1, remem2;
-
-	level(3);
-	if (lat == '?')
-	{	lat = lex();
-		emit('?');
-		remem1 = prs; emit(0);
-		expr();
-		expect(':'); emit(':');
-		remem2 = prs; emit(0);
-		parsed[remem1] = prs-1;
-		expr();
-		parsed[remem2] = prs-1;
-	}
-}
-
-level(nr)
-{	int i;
-	extern int noerr;
-
-	if (nr < 0)
-	{	factor();
-		return;
-	}
-	level(nr-1);
-	for (i = 0; op[nr][i] != 0 && noerr; i++)
-		if (lat == op[nr][i])
-		{	lat = lex();
-			level(nr);
-			emit(op[nr][i]);
-			break;
-		}
-}
-
-transform()
-{	extern int prs;
-
-	prs = 0; /* initial length of parse string */
-	if (lat != NEW)
-	{	expr();
-		emit('@');
-		pushback(lat);
-		return;
-	}
-	lat = lex();
-	if (lat == '[')
-	{	fileref(CURNEW, LVAL);
-		expect('='); expr(); emit('=');
-	} else
-	{	expect('='); expr(); emit('@');
-	}
-	if (lat != '\n' && lat != ';')
-		error("syntax error, separator\n");
-	pushback(lat);
-}
-
-factor()
-{	int n;
-
-	switch (lat) {
-	case   '(':	lat = lex();
-			expr();
-			expect(')');
-			break;
-	case   '-':	lat = lex();
-			factor();
-			emit(UMIN);
-			break;
-	case   '!':	lat = lex();
-			factor();
-			emit('!');
-			break;
-	case   OLD:	lat = lex();
-			fileref(CUROLD, RVAL);
-			break;
-	case FNAME:	n = lexval;
-			lat = lex();
-			fileref(n+1, RVAL);
-			break;
-	case   '$':	lat = lex();
-			expect(VALUE);
-			fileref(lexval+1, RVAL);
-			break;
-	case VALUE:	emit(VALUE);
-			emit(lexval);
-			lat = lex();
-			break;
-	case 'y':
-	case 'x':	emit(lat);
-			lat = lex();
-			break;
-	default :	error("expr: syntax error\n");
-	}
-	if (lat == POW)
-	{	lat = lex();
-		factor();
-		emit(POW);
-	}
-}
-
-fileref(val, tok)
-{
-	if (val < 0 || val >= nsrc)
-		error("bad file number: %d\n", val);
-
-	emit(VALUE);
-	emit(val);
-	if (lat == '[')
-	{	lat = lex();
-		expr();	expect(',');
-		expr(); expect(']');	/* [x,y] */
-	} else
-	{	emit('x');
-		emit('y');
-	}
-	emit(tok);
-}
-
-expect(t)
-{
-	if (lat == t)
-		lat = lex();
-	else
-		error("error: expected token %d\n",t);
-}
//GO.SYSIN DD expr.c
echo io.c 1>&2
sed 's/.//' >io.c <<'//GO.SYSIN DD io.c'
-
-/***  io.c   (file handler)  ************************/
-
-#include	<stdio.h>
-#include	"popi.h"
-
-extern struct SRC src[MANY];
-extern int nsrc, noerr;
-extern char *Emalloc();
-
-getpix(into, str)
-	struct SRC *into;	/* work buffer */
-	char *str;		/* file name   */
-{
-	FILE *fd;
-	int i;
-
-	if ((fd = fopen(str, "r")) == NULL)
-	{	fprintf(stderr, "no file %s\n", str);
-		return;
-	}
-
-	if (into->pix == (unsigned char **) 0)
-	{	into->pix = (unsigned char **)
-			Emalloc(DEF_Y * sizeof(unsigned char *));
-		for (i = 0; i < DEF_Y; i++)
-			into->pix[i] = (unsigned char *)
-				Emalloc(DEF_X);
-	}
-	into->str = (char *) Emalloc(strlen(str)+1);
-	if (!noerr) return;	/* set by Emalloc */
-
-	for (i = 0; i < DEF_Y; i++)
-		fread(into->pix[i], 1, DEF_X, fd);
-	strcpy(into->str, str);
-
-	fclose(fd);
-	nsrc++;
-}
-
-#ifdef NODOS
-
-putpix(into, str)
-	struct SRC *into;	/* work buffer */
-	char *str;		/* file name   */
-{
-	FILE *fd;
-	int i;
-
-	if ((fd = fopen(str, "w")) == NULL)
-	{	fprintf(stderr, "cannot create %s\n", str);
-		return;
-	}
-	for (i = 0; i < DEF_Y; i++)
-		fwrite(into->pix[i], 1, DEF_X, fd);
-	fclose(fd);
-}
-
-#else
-
-putpix(into, str)
-	struct SRC *into;
-	char *str;
-{
-	FILE *fd;
-	int i, j;
-	static unsigned char *buffer;
-	register unsigned char c, *p, *q;
-
-	if ((fd = fopen(str, "w")) == NULL)
-	{	fprintf(stderr, "cannot create %s\n", str);
-		return;
-	}
-	if (!buffer)
-		buffer = (unsigned char *) Emalloc(DEF_X);
-
-	for (i = 0; i < DEF_Y; i++)
-	{	for (j = 0, p=buffer, q=into->pix[i]; j < DEF_X; j++)
-		{	c = *q++;
-			*p++ = (c==10||c==26)?c-1:c;
-		}
-		fwrite(buffer, 1, DEF_X, fd);
-	}
-	fclose(fd);
-}
-#endif
-
-showfiles()
-{	int n;
-
-	if (nsrc == 2)
-		printf("no files open\n");
-	else
-		for (n = 2; n < nsrc; n++)
-			printf("$%d = %s\n", n-1, src[n].str);
-}
//GO.SYSIN DD io.c
echo lex.c 1>&2
sed 's/.//' >lex.c <<'//GO.SYSIN DD lex.c'
-
-/***  lex.c  (lexical analyzer) *********************/
-
-#include <stdio.h>
-#include <ctype.h>
-#include "popi.h"
-
-extern struct	SRC src[MANY];
-extern short	CUROLD, CURNEW;
-extern int	nsrc, lexval;
-extern char	text[];
-
-lex()
-{	int c;
-
-	do	/* ignore white space */
-		c = getchar();
-	while (c == ' ' || c == '\t');
-
-	if (isdigit(c))
-		c = getnumber(c);
-	else if (isalpha(c) || c == '_')
-		c = getstring(c);
-
-	switch (c) {
-	case EOF:  c = 'q'; break;
-	case '*':  c = follow('*', POW, c); break;
-	case '>':  c = follow('=', GE,  c); break;
-	case '<':  c = follow('=', LE,  c); break;
-	case '!':  c = follow('=', NE,  c); break;
-	case '=':  c = follow('=', EQ,  c); break;
-	case '|':  c = follow('|', OR,  c); break;
-	case '&':  c = follow('&', AND, c); break;
-	case 'Z':  c = VALUE; lexval = 255; break;
-	case 'Y':  c = VALUE; lexval = DEF_Y-1; break;
-	case 'X':  c = VALUE; lexval = DEF_X-1; break;
-	default :  break;
-	}
-	return c;
-}
-
-getnumber(first)
-{	int c;
-
-	lexval = first - '0';
-	while (isdigit(c = getchar()))
-		lexval = 10*lexval + c - '0';
-	pushback(c);
-	return VALUE;
-}
-
-getstring(first)
-{	int c = first;
-	char *str = text;
-
-	do {
-		*str++ = c;
-		c = getchar();
-	} while (isalpha(c) || c == '_' || isdigit(c));
-	*str = '\0';
-	pushback(c);
-
-	if (strcmp(text, "new") == 0) return NEW;
-	if (strcmp(text, "old") == 0) return OLD;
-
-	for (c = 2; c < nsrc; c++)
-		if (strcmp(src[c].str, text) == 0)
-		{	lexval = c-1;
-			return FNAME;
-		}
-	if (strlen(text) > 1)
-		return NAME;
-	return first;
-}
-
-follow(tok, ifyes, ifno)
-{	int c;
-
-	if ((c = getchar()) == tok)
-		return ifyes;
-	pushback(c);
-
-	return ifno;
-}
-
-pushback(c)
-{
-	ungetc(c, stdin);
-}
//GO.SYSIN DD lex.c
echo lib.c 1>&2
sed 's/.//' >lib.c <<'//GO.SYSIN DD lib.c'
-#include	"popi.h"
-
-#define New	src[CURNEW].pix
-#define Old	src[CUROLD].pix
-
-extern struct	SRC	src[MANY];
-extern short	CUROLD, CURNEW;
-
-/*
- *	Some user defined functions, as described in Chapter 6.
- *	Transformations `oil()' and `melting()' are the most
- *	time consuming. Runtime is about 10 minutes on a VAX-750.
- *	The other transformations take less than a minute each.
- *	A call to function `slicer()' is included as an example in main.c.
- */
-
-#define N	3
-
-oil()
-{	register int x, y;
-	register int dx, dy, mfp;
-	int histo[256];
-
-	for (y = N; y < DEF_Y-N; y++)
-	for (x = N; x < DEF_X-N; x++)
-	{	for (dx = 0; dx < 256; dx++)
-			histo[dx] = 0;
-
-		for (dy = y-N; dy <= y+N; dy++)
-		for (dx = x-N; dx <= x+N; dx++)
-			histo[Old[dy][dx]]++;
-
-		for (dx = dy = 0; dx < 256; dx++)
-			if (histo[dx] > dy)
-			{	dy = histo[dx];
-				mfp = dx;
-			}
-		New[y][x] = mfp;
-}	}
-
-shear()
-{	register int x, y, r;
-	int dx, dy, yshift[DEF_X];
-
-	for (x = r = 0; x < DEF_X; x++)
-	{	if (rand()%256 < 128)
-			r--;
-		else
-			r++;
-		yshift[x] = r;
-	}
-	
-	for (y = 0; y < DEF_Y; y++)
-	{	if (rand()%256 < 128)
-			r--;
-		else
-			r++;
-
-		for (x = 0; x < DEF_X; x++)
-		{	dx = x+r; dy = y+yshift[x];
-			if (dx >= DEF_X || dy >= DEF_Y
-			||  dx < 0 || dy < 0)
-				continue;
-			New[y][x] = Old[dy][dx];
-}	}	}
-
-slicer()
-{	register int x, y, r;
-	int dx, dy, xshift[DEF_Y], yshift[DEF_X];
-
-	for (x = dx = 0; x < DEF_X; x++)
-	{	if (dx == 0)
-		{	r = (rand()&63)-32;
-			dx = 8+rand()&31;
-		} else
-			dx--;
-		yshift[x] = r;
-	}	
-	for (y = dy = 0; y < DEF_Y; y++)
-	{	if (dy == 0)
-		{	r = (rand()&63)-32;
-			dy = 8+rand()&31;
-		} else
-			dy--;
-		xshift[y] = r;
-	}
-	
-	for (y = 0; y < DEF_Y; y++)
-	for (x = 0; x < DEF_X; x++)
-	{	dx = x+xshift[y]; dy = y+yshift[x];
-		if (dx < DEF_X && dy < DEF_Y
-		&&  dx >= 0 && dy >= 0)
-			New[y][x] = Old[dy][dx];
-}	}
-
-#define T 25	/* tile size */
-
-tiling()
-{	register int x, y, dx, dy;
-	int ox, oy, nx, ny;
-
-	for (y = 0; y < DEF_Y-T; y += T)
-	for (x = 0; x < DEF_X-T; x += T)
-	{	ox = (rand()&31)-16;	/* displacement */
-		oy = (rand()&31)-16;
-
-		for (dy = y; dy < y+T; dy++)
-		for (dx = x; dx < x+T; dx++)
-		{	nx = dx+ox; ny = dy+oy;
-			if (nx >= DEF_X || ny >= DEF_Y
-			||  nx < 0 || ny < 0)
-				continue;
-			New[ny][nx] = Old[dy][dx];
-}	}	}
-
-melting()
-{	register int x, y, val, k; 
-
-	for (k = 0; k < DEF_X*DEF_Y; k++)
-	{	x = rand()%DEF_X;
-		y = rand()%(DEF_Y-1);
-
-		while (y < DEF_Y-1 && Old[y][x] <= Old[y+1][x])
-		{	val = Old[y][x];
-			Old[y][x] = Old[y+1][x];
-			Old[y+1][x] = val;
-			y++;
-	}	}
-	for (y = 0; y < DEF_Y; y++)
-	for (x = 0; x < DEF_X; x++)
-		New[y][x] = Old[y][x];	/* update the other edit buffer */
-}
-
-#define G	7.5	/* gamma factor */
-
-extern double pow();	/* the C-library routine */
-
-matte()
-{	register x, y;
-	unsigned char lookup[256];
-
-	for (x = 0; x < 256; x++)
-		lookup[x] = (255. * pow(x/255., G)<3.)?255:0;
-	for (y = 0; y < DEF_Y; y++)
-	for (x = 0; x < DEF_X; x++)
-		New[y][x] = lookup[Old[y][x]];
-}
//GO.SYSIN DD lib.c
echo main.c 1>&2
sed 's/.//' >main.c <<'//GO.SYSIN DD main.c'
-
-/***  main.c ****************************************/
-
-#include	<stdio.h>
-#include	<ctype.h>
-#include	"popi.h"
-
-int	parsed[MANY];
-struct	SRC	src[MANY];
-short	CUROLD=0, CURNEW=1;
-int	noerr, lexval, prs=0, nsrc=2;
-char	text[256];
-
-char *Emalloc();
-
-main(argc, argv)
-	char **argv;
-{
-	int i;
-
-	src[CUROLD].pix = (unsigned char **)
-		Emalloc(DEF_Y * sizeof(unsigned char *));
-	src[CURNEW].pix = (unsigned char **)
-		Emalloc(DEF_Y * sizeof(unsigned char *));
-
-	for (i = 0; i < DEF_Y; i++)
-	{	src[CUROLD].pix[i] = (unsigned char *)
-			Emalloc(DEF_X);
-		src[CURNEW].pix[i] = (unsigned char *)
-			Emalloc(DEF_X);
-	}
-
-	for (i = 1; i < argc; i++)
-		getpix(&src[nsrc], argv[i]);
-
-	do noerr=1; while( parse() );
-}
-
-parse()
-{	extern int lat;		/* look ahead token */
-
-	printf("-> ");
-	while (noerr)
-	{	switch (lat = lex()) {
-		case  'q': return 0;
-		case '\n': return 1;
-		case  ';': break;
-		case  'f': showfiles();
-			   break;
-		case  'r': getname();
-			   if (!noerr) continue;
-			   getpix(&src[nsrc], text);
-			   break;
-		case  'w': getname();
-			   if (!noerr) continue;
-			   putpix(&src[CUROLD], text);
-			   break;
-		/* example of adding a function defined in lib.c */
-		case  'u': slicer();
-			   CUROLD = CURNEW; CURNEW = 1-CUROLD;
-			   break;
-		default  : transform();
-			   if (noerr) run();
-			   break;
-	}	}
-}
-
-getname()
-{	int t = lex();
-
-	if (t != NAME && t != FNAME && !isalpha(t))
-		error("expected name, bad token: %d\n", t);
-}
-
-emit(what)
-{
-	if (prs >= MANY)
-		error("expression too long\n");
-	parsed[prs++] = what;
-}
-
-error(s, d)
-	char *s;
-{
-	extern int lat;
-
-	fprintf(stderr, s, d);
-	while (lat != '\n')
-		lat = lex();
-	noerr = 0;	/* noerr is now false */
-}
-
-char *
-Emalloc(N)
-{	char *try, *malloc();
-
-	if ((try = malloc(N)) == NULL)
-		error("out of memory\n");
-	return try;
-}
//GO.SYSIN DD main.c
echo run.c 1>&2
sed 's/.//' >run.c <<'//GO.SYSIN DD run.c'
-
-/***  run.c  (interpreter) **************************/
-
-#include	"popi.h"
-
-extern int	prs, parsed[MANY];
-extern struct	SRC	src[MANY];
-extern short	CUROLD, CURNEW;
-
-#define dop(OP)	a = *--rr; tr = rr-1; *tr = (*tr OP (long)a)
-
-long
-Pow(a, b)
-	long a, b;
-{
-	double c = (double)a;
-	double d = (double)b;
-	double pow();
-
-	return (long) pow(c, d);
-}
-
-run()
-{	long R[MANY];              /* the stack    */
-	register long *rr, *tr;    /* top of stack */
-	register unsigned char *u; /* explicit destination */
-	register unsigned char *p; /* default  destination */
-	register int k;            /* indexes parse string */
-	int a, b, c;               /* scratch     */
-	int x, y;                  /* coordinates */
-
-	p = src[CURNEW].pix[0];
-	for (y = 0; y < DEF_Y; y++, p = src[CURNEW].pix[y])
-	for (x = 0; x < DEF_X; x++, p++)
-	for (k = 0, rr = R; k < prs; k++)
-	{	if (parsed[k] == VALUE)
-		{	*rr++ = (long)parsed[++k];
-			continue;
-		}
-		if (parsed[k] == '@')
-		{	*p = (unsigned char) (*--rr);
-			continue;
-		}
-		switch (parsed[k]) {
-		case  '+': dop(+);  break;
-		case  '-': dop(-);  break;
-		case  '*': dop(*);  break;
-		case  '/': dop(/);  break;
-		case  '%': dop(%);  break;
-		case  '>': dop(>);  break;
-		case  '<': dop(<);  break;
-		case   GE: dop(>=); break;
-		case   LE: dop(<=); break;
-		case   EQ: dop(==); break;
-		case   NE: dop(!=); break;
-		case  AND: dop(&&); break;
-		case   OR: dop(||); break;
-		case  '^': dop(|);  break;
-		case  'x': *rr++ = (long)x; break;
-		case  'y': *rr++ = (long)y; break;
-		case UMIN: tr = rr-1; *tr = -(*tr); break;
-		case  '!': tr = rr-1; *tr = !(*tr); break;
-		case  '=': a = *--rr;
-			   u = (unsigned char *) *--rr;
-			   *u = (unsigned char) a;
-			   break;
-		case RVAL: a = *--rr;
-			   b = *--rr;
-			   tr = rr-1;
-			   c = *tr;
-			   *tr = (long) src[c].pix[a][b];
-			   break;
-		case LVAL: a = *--rr;
-			   b = *--rr;
-			   tr = rr-1;
-			   c = *tr;
-			   *tr = (long) &(src[c].pix[a][b]);
-			   break;
-		case  POW: a = *--rr;
-			   *(rr-1) = Pow(*(rr-1),(long)a);
-			   break;
-		case  '?': a = *--rr; k++;
-			   if (!a) k = parsed[k];
-			   break;
-		case  ':': k = parsed[k+1]; break;
-
-		default  : error("run: unknown operator\n");
-		}
-	}
-	CUROLD = CURNEW; CURNEW = 1-CUROLD;
-}
//GO.SYSIN DD run.c
echo popi.h 1>&2
sed 's/.//' >popi.h <<'//GO.SYSIN DD popi.h'
-
-/***  popi.h (header file) **************************/
-
-#define MANY	128
-#define DEF_X	248	/* image width  */
-#define DEF_Y	248	/* image height */
-
-#define RVAL	257	/* larger than any char token */
-#define LVAL	258
-#define FNAME	259
-#define VALUE	260
-#define NAME	261
-#define NEW	262
-#define OLD	263
-#define AND	264
-#define OR	265
-#define EQ	266
-#define NE	267
-#define GE	268
-#define LE	269
-#define UMIN	270
-#define POW	271
-
-struct SRC {
-	unsigned char **pix;	/* pix[y][x] */
-	char *str;
-};
//GO.SYSIN DD popi.h
