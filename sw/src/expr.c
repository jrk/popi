
/***  expr.c (parser)  ******************************/

#include "popi.h"

extern int	lexval, nsrc;
extern struct	SRC	src[MANY];
extern short	CUROLD, CURNEW;
int		lat;	/* look ahead token */

int op[4][7] = {
	{ '*', '/', '%', 0, 0, 0, 0, },
	{ '+', '-',   0, 0, 0, 0, 0, },
	{ '>', '<',  GE, LE, EQ, NE, 0, },
	{ '^', AND,  OR, 0, 0, 0, 0, },
};

expr()
{	extern int prs;
	extern int parsed[MANY];
	int remem1, remem2;

	level(3);
	if (lat == '?')
	{	lat = lex();
		emit('?');
		remem1 = prs; emit(0);
		expr();
		expect(':'); emit(':');
		remem2 = prs; emit(0);
		parsed[remem1] = prs-1;
		expr();
		parsed[remem2] = prs-1;
	}
}

level(nr)
{	int i;
	extern int noerr;

	if (nr < 0)
	{	factor();
		return;
	}
	level(nr-1);
	for (i = 0; op[nr][i] != 0 && noerr; i++)
		if (lat == op[nr][i])
		{	lat = lex();
			level(nr);
			emit(op[nr][i]);
			break;
		}
}

transform()
{	extern int prs;

	prs = 0; /* initial length of parse string */
	if (lat != NEW)
	{	expr();
		emit('@');
		pushback(lat);
		return;
	}
	lat = lex();
	if (lat == '[')
	{	fileref(CURNEW, LVAL);
		expect('='); expr(); emit('=');
	} else
	{	expect('='); expr(); emit('@');
	}
	if (lat != '\n' && lat != ';')
		error("syntax error, separator\n");
	pushback(lat);
}

factor()
{	int n;

	switch (lat) {
	case   '(':	lat = lex();
			expr();
			expect(')');
			break;
	case   '-':	lat = lex();
			factor();
			emit(UMIN);
			break;
	case   '!':	lat = lex();
			factor();
			emit('!');
			break;
	case   OLD:	lat = lex();
			fileref(CUROLD, RVAL);
			break;
	case FNAME:	n = lexval;
			lat = lex();
			fileref(n+1, RVAL);
			break;
	case   '$':	lat = lex();
			expect(VALUE);
			fileref(lexval+1, RVAL);
			break;
	case VALUE:	emit(VALUE);
			emit(lexval);
			lat = lex();
			break;
	case 'y':
	case 'x':	emit(lat);
			lat = lex();
			break;
	default :	error("expr: syntax error\n");
	}
	if (lat == POW)
	{	lat = lex();
		factor();
		emit(POW);
	}
}

fileref(val, tok)
{
	if (val < 0 || val >= nsrc)
		error("bad file number: %d\n", val);

	emit(VALUE);
	emit(val);
	if (lat == '[')
	{	lat = lex();
		expr();	expect(',');
		expr(); expect(']');	/* [x,y] */
	} else
	{	emit('x');
		emit('y');
	}
	emit(tok);
}

expect(t)
{
	if (lat == t)
		lat = lex();
	else
		error("error: expected token %d\n",t);
}
