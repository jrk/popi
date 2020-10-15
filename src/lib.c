#include	"popi.h"

#define New	src[CURNEW].pix
#define Old	src[CUROLD].pix

extern struct	SRC	src[MANY];
extern short	CUROLD, CURNEW;

/*
 *	Some user defined functions, as described in Chapter 6.
 *	Transformations `oil()' and `melting()' are the most
 *	time consuming. Runtime is about 10 minutes on a VAX-750.
 *	The other transformations take less than a minute each.
 *	A call to function `slicer()' is included as an example in main.c.
 */

#define N	3

oil()
{	register int x, y;
	register int dx, dy, mfp;
	int histo[256];

	for (y = N; y < DEF_Y-N; y++)
	for (x = N; x < DEF_X-N; x++)
	{	for (dx = 0; dx < 256; dx++)
			histo[dx] = 0;

		for (dy = y-N; dy <= y+N; dy++)
		for (dx = x-N; dx <= x+N; dx++)
			histo[Old[dy][dx]]++;

		for (dx = dy = 0; dx < 256; dx++)
			if (histo[dx] > dy)
			{	dy = histo[dx];
				mfp = dx;
			}
		New[y][x] = mfp;
}	}

shear()
{	register int x, y, r;
	int dx, dy, yshift[DEF_X];

	for (x = r = 0; x < DEF_X; x++)
	{	if (rand()%256 < 128)
			r--;
		else
			r++;
		yshift[x] = r;
	}
	
	for (y = 0; y < DEF_Y; y++)
	{	if (rand()%256 < 128)
			r--;
		else
			r++;

		for (x = 0; x < DEF_X; x++)
		{	dx = x+r; dy = y+yshift[x];
			if (dx >= DEF_X || dy >= DEF_Y
			||  dx < 0 || dy < 0)
				continue;
			New[y][x] = Old[dy][dx];
}	}	}

slicer()
{	register int x, y, r;
	int dx, dy, xshift[DEF_Y], yshift[DEF_X];

	for (x = dx = 0; x < DEF_X; x++)
	{	if (dx == 0)
		{	r = (rand()&63)-32;
			dx = 8+rand()&31;
		} else
			dx--;
		yshift[x] = r;
	}	
	for (y = dy = 0; y < DEF_Y; y++)
	{	if (dy == 0)
		{	r = (rand()&63)-32;
			dy = 8+rand()&31;
		} else
			dy--;
		xshift[y] = r;
	}
	
	for (y = 0; y < DEF_Y; y++)
	for (x = 0; x < DEF_X; x++)
	{	dx = x+xshift[y]; dy = y+yshift[x];
		if (dx < DEF_X && dy < DEF_Y
		&&  dx >= 0 && dy >= 0)
			New[y][x] = Old[dy][dx];
}	}

#define T 25	/* tile size */

tiling()
{	register int x, y, dx, dy;
	int ox, oy, nx, ny;

	for (y = 0; y < DEF_Y-T; y += T)
	for (x = 0; x < DEF_X-T; x += T)
	{	ox = (rand()&31)-16;	/* displacement */
		oy = (rand()&31)-16;

		for (dy = y; dy < y+T; dy++)
		for (dx = x; dx < x+T; dx++)
		{	nx = dx+ox; ny = dy+oy;
			if (nx >= DEF_X || ny >= DEF_Y
			||  nx < 0 || ny < 0)
				continue;
			New[ny][nx] = Old[dy][dx];
}	}	}

melting()
{	register int x, y, val, k; 

	for (k = 0; k < DEF_X*DEF_Y; k++)
	{	x = rand()%DEF_X;
		y = rand()%(DEF_Y-1);

		while (y < DEF_Y-1 && Old[y][x] <= Old[y+1][x])
		{	val = Old[y][x];
			Old[y][x] = Old[y+1][x];
			Old[y+1][x] = val;
			y++;
	}	}
	for (y = 0; y < DEF_Y; y++)
	for (x = 0; x < DEF_X; x++)
		New[y][x] = Old[y][x];	/* update the other edit buffer */
}

#define G	7.5	/* gamma factor */

extern double pow();	/* the C-library routine */

matte()
{	register x, y;
	unsigned char lookup[256];

	for (x = 0; x < 256; x++)
		lookup[x] = (255. * pow(x/255., G)<3.)?255:0;
	for (y = 0; y < DEF_Y; y++)
	for (x = 0; x < DEF_X; x++)
		New[y][x] = lookup[Old[y][x]];
}
