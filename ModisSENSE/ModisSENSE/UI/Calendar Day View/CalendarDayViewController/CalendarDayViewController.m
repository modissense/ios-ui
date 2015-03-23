//
//  CalendarDayViewController.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 6/20/14.
//  Copyright (c) 2014 ATC. All rights reserved.
//

#import "CalendarDayViewController.h"
#import "NSDate+TKCategory.h"
#import "UINavigationBar+TKCategory.h"
#import "POI.h"
#import "UIConstants.h"
#import "Engine.h"

@interface CalendarDayViewController () {
    NSMutableArray* data;
    NSDateFormatter *serviceDateFormatter;
    TKCalendarDayView* calendarView;
}

@end

@implementation CalendarDayViewController


- (void) viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	
	self.navigationController.navigationBar.hairlineDividerView.hidden = YES;
	self.dayView.daysBackgroundView.backgroundColor = NAVCOLOR;
}

- (void) viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	self.navigationController.navigationBar.hairlineDividerView.hidden = NO;
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //For ios7
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
        ADJUST_IOS7_LAYOUT
        
    self.title = L(TIMETABLE);
    
    //Clean new array
    data = [NSMutableArray array];
    
    serviceDateFormatter = [[NSDateFormatter alloc] init];
    [serviceDateFormatter setDateFormat:@"yyy-MM-dd"];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    for (POI* poi in self.pois)
    {
        NSDate *startDate = [dateFormatter dateFromString:poi.startDate];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:startDate];
        int startHour = [components hour];
        NSNumber* startHr = [NSNumber numberWithInt:startHour];
        int startMinute = [components minute];
        NSNumber* startMin = [NSNumber numberWithInt:startMinute];
        
        NSDate *endDate = [dateFormatter dateFromString:poi.endDate];
        NSCalendar *calendar2 = [NSCalendar currentCalendar];
        NSDateComponents *components2 = [calendar2 components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:endDate];
        int endHour = [components2 hour];
        NSNumber* endHr = [NSNumber numberWithInt:endHour];
        int endMinute = [components2 minute];
        NSNumber* endMin = [NSNumber numberWithInt:endMinute];
        
        [data addObject:@[poi.name, poi.comment, startHr, startMin, endHr, endMin]];
    }
    
    self.dayView.showDate = [serviceDateFormatter dateFromString:self.blogDate];
//    self.dayView.date = blogDate;
    
    //Left button
    UIBarButtonItem* doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    //    UIBarButtonItem *addBlogBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add"] style:UIBarButtonItemStylePlain target:self action:@selector(showAddNewVisitPicker:)];
    //    UIBarButtonItem* refreshBtn = [[UIBarButtonItem alloc] initWithTitle:L(REFRESH) style:UIBarButtonItemStylePlain target:self action:@selector(getBlogs)];
    self.navigationItem.rightBarButtonItem = doneBtn;
}



- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Dismiss modal

-(void)done{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark TKCalendarDayView datasource
- (NSArray *) calendarDayTimelineView:(TKCalendarDayView*)calendarDayTimeline eventsForDate:(NSDate *)eventDate {
	
//	if([eventDate compare:[NSDate dateWithTimeIntervalSinceNow:-24*60*60]] == NSOrderedAscending) return @[];
//	if([eventDate compare:[NSDate dateWithTimeIntervalSinceNow:24*60*60]] == NSOrderedDescending) return @[];
    
	NSDateComponents *info = [[NSDate date] dateComponentsWithTimeZone:calendarDayTimeline.calendar.timeZone];
	info.second = 0;
	NSMutableArray *ret = [NSMutableArray array];
	
	for(NSArray *ar in data){
		
		TKCalendarDayEventView *event = [calendarDayTimeline dequeueReusableEventView];
		if(event == nil) event = [TKCalendarDayEventView eventView];
        
		event.identifier = nil;
		event.titleLabel.text = ar[0];
		event.locationLabel.text = ar[1];
		
		info.hour = [ar[2] intValue];
		info.minute = [ar[3] intValue];
		event.startDate = [NSDate dateWithDateComponents:info];
		
		info.hour = [ar[4] intValue];
		info.minute = [ar[5] intValue];
		event.endDate = [NSDate dateWithDateComponents:info];
        
		[ret addObject:event];
		
	}
	return ret;
	
    
}


#pragma mark -  Event view selected delegate

- (void) calendarDayTimelineView:(TKCalendarDayView*)calendarDayTimeline eventViewWasSelected:(TKCalendarDayEventView *)eventView{
	NSLog(@"%@",eventView.titleLabel.text);
}


#pragma mark -  Date selected delegate

- (void) calendarDayTimelineView:(TKCalendarDayView*)calendarDay didMoveToDate:(NSDate*)date {
    
}


@end
