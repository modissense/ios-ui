//
//  UIConstants.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/16/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//


// colors
//
#define MAINCOLOR                        [UIColor whiteColor]
#define CELLCOLOR                        [UIColor blackColor]
#define CELLGRAYCOLOR                    [UIColor lightGrayColor]
#define CELLEDITINGCOLOR                 [UIColor darkGrayColor]
#define DEFAULTBLUE                      [UIColor colorWithRed:0.22/1.0 green:0.33/1.0 blue:0.53/1.0 alpha:1.0]
#define DARKGREEN                        [UIColor colorWithRed:0.0/1.0 green:0.8/1.0 blue:0.0/1.0 alpha:1.0]



// fonts
//
#define CELLFONT            [UIFont fontWithName:@"Verdana" size:12.0]
#define CELLFONTBOLD        [UIFont fontWithName:@"Verdana-Bold" size:12.0]



// paddings
//
#define CELLPADDING         15


// iPhone 5 support
#define ASSET_BY_SCREEN_HEIGHT(regular) (([[UIScreen mainScreen] bounds].size.height <= 480.0 || [[UIScreen mainScreen] bounds].size.height > 568) ? regular : [[NSString alloc] initWithFormat:@"%@-568h", regular])
