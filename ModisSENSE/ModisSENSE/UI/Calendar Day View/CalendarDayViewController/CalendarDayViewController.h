//
//  CalendarDayViewController.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 6/20/14.
//  Copyright (c) 2014 ATC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKCalendarDayViewController.h"
#import "BlogEngine.h"

@interface CalendarDayViewController : TKCalendarDayViewController <BlogEngineDelegate>

@property (strong, nonatomic) NSString* blogDate;
@property (strong, nonatomic) NSArray* pois;

@end
