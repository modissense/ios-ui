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

#define LIGHTBLUE                        [UIColor colorWithRed:0.0/255.0 green:140.0/255.0 blue:255.0/255.0 alpha:1.0]
#define DEFAULTBLUE                      [UIColor colorWithRed:0.22/1.0 green:0.33/1.0 blue:0.53/1.0 alpha:1.0]
#define DARKGREEN                        [UIColor colorWithRed:0.0/1.0 green:0.8/1.0 blue:0.0/1.0 alpha:1.0]

#define RED                              [UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0]
#define DARKRED                          [UIColor colorWithRed:179.0/255.0 green:4.0/255.0 blue:4.0/255.0 alpha:1.0]

#define DARKGRAY                         [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0]

#define NAVCOLOR                         [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0]
#define NAVIGATIONREDCOLOR               [UIColor colorWithRed:0.79/1.0 green:0.07/1.0 blue:0.19/1.0 alpha:1.0]

#define DEFAULTTINTCOLOR                 [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]

// fonts
//
#define CELLFONT            [UIFont fontWithName:@"Verdana" size:12.0]
#define CELLFONTSMALL       [UIFont fontWithName:@"Verdana" size:11.0]
#define CELLFONTBOLD        [UIFont fontWithName:@"Verdana-Bold" size:12.0]



// paddings
//
#define CELLPADDING         15


//Cell alpha channel and color
#define CELLALPHA           0.3


// iPhone 5 support
#define ASSET_BY_SCREEN_HEIGHT(regular) (([[UIScreen mainScreen] bounds].size.height <= 480.0 || [[UIScreen mainScreen] bounds].size.height > 568) ? regular : [[NSString alloc] initWithFormat:@"%@-568h", regular])
