
/***  lex.c  (lexical analyzer) *********************/

#include <stdio.h>
#include <ctype.h>
#include "popi.h"

extern struct	SRC src[MANY];
extern short	CUROLD, CURNEW;
extern int	nsrc, lexval;
extern char	text[];

lex()
{	int c;

	do	/* ignore white space */
		c = getchar();
	while (c == ' ' || c == '\t');

	if (isdigit(c))
		c = getnumber(c);
	else if (isalpha(c) || c == '_')
		c = getstring(c);

	switch (c) {
	case EOF:  c = 'q'; break;
	case '*':  c = follow('*', POW, c); break;
	case '>':  c = follow('=', GE,  c); break;
	case '<':  c = follow('=', LE,  c); break;
	case '!':  c = follow('=', NE,  c); break;
	case '=':  c = follow('=', EQ,  c); break;
	case '|':  c = follow('|', OR,  c); break;
	case '&':  c = follow('&', AND, c); break;
	case 'Z':  c = VALUE; lexval = 255; break;
	case 'Y':  c = VALUE; lexval = DEF_Y-1; break;
	case 'X':  c = VALUE; lexval = DEF_X-1; break;
	default :  break;
	}
	return c;
}

getnumber(first)
{	int c;

	lexval = first - '0';
	while (isdigit(c = getchar()))
		lexval = 10*lexval + c - '0';
	pushback(c);
	return VALUE;
}

getstring(first)
{	int c = first;
	char *str = text;

	do {
		*str++ = c;
		c = getchar();
	} while (isalpha(c) || c == '_' || isdigit(c));
	*str = '\0';
	pushback(c);

	if (strcmp(text, "new") == 0) return NEW;
	if (strcmp(text, "old") == 0) return OLD;

	for (c = 2; c < nsrc; c++)
		if (strcmp(src[c].str, text) == 0)
		{	lexval = c-1;
			return FNAME;
		}
	if (strlen(text) > 1)
		return NAME;
	return first;
}

follow(tok, ifyes, ifno)
{	int c;

	if ((c = getchar()) == tok)
		return ifyes;
	pushback(c);

	return ifno;
}

pushback(c)
{
	ungetc(c, stdin);
}
