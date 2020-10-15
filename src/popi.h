
/***  popi.h (header file) **************************/

#define MANY	128
#define DEF_X	248	/* image width  */
#define DEF_Y	248	/* image height */

#define RVAL	257	/* larger than any char token */
#define LVAL	258
#define FNAME	259
#define VALUE	260
#define NAME	261
#define NEW	262
#define OLD	263
#define AND	264
#define OR	265
#define EQ	266
#define NE	267
#define GE	268
#define LE	269
#define UMIN	270
#define POW	271

struct SRC {
	unsigned char **pix;	/* pix[y][x] */
	char *str;
};
