
/***  run.c  (interpreter) **************************/

#include	"popi.h"

extern int	prs, parsed[MANY];
extern struct	SRC	src[MANY];
extern short	CUROLD, CURNEW;

#define dop(OP)	a = *--rr; tr = rr-1; *tr = (*tr OP (long)a)

long
Pow(a, b)
	long a, b;
{
	double c = (double)a;
	double d = (double)b;
	double pow();

	return (long) pow(c, d);
}

run()
{	long R[MANY];              /* the stack    */
	register long *rr, *tr;    /* top of stack */
	register unsigned char *u; /* explicit destination */
	register unsigned char *p; /* default  destination */
	register int k;            /* indexes parse string */
	int a, b, c;               /* scratch     */
	int x, y;                  /* coordinates */

	p = src[CURNEW].pix[0];
	for (y = 0; y < DEF_Y; y++, p = src[CURNEW].pix[y])
	for (x = 0; x < DEF_X; x++, p++)
	for (k = 0, rr = R; k < prs; k++)
	{	if (parsed[k] == VALUE)
		{	*rr++ = (long)parsed[++k];
			continue;
		}
		if (parsed[k] == '@')
		{	*p = (unsigned char) (*--rr);
			continue;
		}
		switch (parsed[k]) {
		case  '+': dop(+);  break;
		case  '-': dop(-);  break;
		case  '*': dop(*);  break;
		case  '/': dop(/);  break;
		case  '%': dop(%);  break;
		case  '>': dop(>);  break;
		case  '<': dop(<);  break;
		case   GE: dop(>=); break;
		case   LE: dop(<=); break;
		case   EQ: dop(==); break;
		case   NE: dop(!=); break;
		case  AND: dop(&&); break;
		case   OR: dop(||); break;
		case  '^': dop(|);  break;
		case  'x': *rr++ = (long)x; break;
		case  'y': *rr++ = (long)y; break;
		case UMIN: tr = rr-1; *tr = -(*tr); break;
		case  '!': tr = rr-1; *tr = !(*tr); break;
		case  '=': a = *--rr;
			   u = (unsigned char *) *--rr;
			   *u = (unsigned char) a;
			   break;
		case RVAL: a = *--rr;
			   b = *--rr;
			   tr = rr-1;
			   c = *tr;
			   *tr = (long) src[c].pix[a][b];
			   break;
		case LVAL: a = *--rr;
			   b = *--rr;
			   tr = rr-1;
			   c = *tr;
			   *tr = (long) &(src[c].pix[a][b]);
			   break;
		case  POW: a = *--rr;
			   *(rr-1) = Pow(*(rr-1),(long)a);
			   break;
		case  '?': a = *--rr; k++;
			   if (!a) k = parsed[k];
			   break;
		case  ':': k = parsed[k+1]; break;

		default  : error("run: unknown operator\n");
		}
	}
	CUROLD = CURNEW; CURNEW = 1-CUROLD;
}
