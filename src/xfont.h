/*
 *  A Z-Machine
 *  Copyright (C) 2000 Andrew Hunter
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
 * Font handling for X-Windows
 */

#ifndef __XFONT_H
#define __XFONT_H

#include "../config.h"

struct xfont;

typedef struct xfont xfont;

extern void    xfont_initialise    (void);
extern void    xfont_shutdown      (void);

extern xfont*  xfont_load_font     (char* font);
extern void    xfont_release_font  (xfont*);

extern void    xfont_set_colours   (int,
				    int);
extern int     xfont_get_width     (xfont*);
extern int     xfont_get_height    (xfont*);
extern int     xfont_get_ascent    (xfont*);
extern int     xfont_get_descent   (xfont*);
extern int     xfont_get_text_width(xfont*,
				    const int*,
				    int);
#if WINDOW_SYSTEM==1
extern void    xfont_plot_string   (xfont*,
				    Drawable,
				    GC,
				    int, int,
				    const int*,
				    int);
#else
extern void xfont_plot_string(xfont*,
			      HDC,
			      int, int,
			      const int*,
			      int);

extern void xfont_choose_new_font(xfont*,
				  int);
#endif

#endif