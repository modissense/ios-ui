//
//  TrajectoryMapViewController.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 11/5/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "TrajectoryMapViewController.h"
#import "Engine.h"
#import "Util.h"
#import "UIConstants.h"
#import "CalendarDayViewController.h"

@interface TrajectoryMapViewController () {
    
    //Array of POI locations
    NSArray* gMapLocations;
    
    //Line that will show up user's path on the map
    MKPolyline *polyline;
    
    BOOL isRenderingGPSTrace;
}

@end


@implementation TrajectoryMapViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    isRenderingGPSTrace = NO;
    
    //For iOS7
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
        ADJUST_IOS7_LAYOUT
        
    self.title = L(HISTORY);
    
    UIBarButtonItem* calendarViewBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"clock"] style:UIBarButtonItemStylePlain target:self action:@selector(showCalendarView)];
    self.navigationItem.rightBarButtonItem = calendarViewBtn;
    
    self.gMapView.showsUserLocation = YES;
    
    //Initialize polyline
    polyline = [[MKPolyline alloc] init];
    
    //Set delegate to self
    self.gMapView.gMapDelegate = self;
    
    
    //Create map locations
    gMapLocations = [self createMapLocations];
    
    //Set them
    [self.gMapView setLocations:gMapLocations];
    
    //Show with pins
    [self.gMapView show];
    
    [self showTrajectoryLine];
    
    //Get GPS trace from server
    
    BlogEngine* blogEngine = [[BlogEngine alloc] init];
    blogEngine.delegate = self;
    [blogEngine retrieveGPSTraceForDate:self.blogDate];
     
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Create locations array

-(NSArray *)createMapLocations {
    
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    
    if (!self.pointsOfInterest || self.pointsOfInterest.count == 0)
        return nil;
    
    POI *poi;
    
    for(int i = 0; i < self.pointsOfInterest.count; i++)
    {
        poi = [self.pointsOfInterest objectAtIndex:i];
        
        NSString* calloutName = poi.name;
        
        //If there are start and end dates add the hours remained there
        if (![Util isEmptyString:poi.startDate ] && ![Util isEmptyString:poi.endDate])
        {
            NSDateFormatter* df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyy-MM-dd HH:mm:ss"];
            
            NSDate* start = [df dateFromString:poi.startDate];
            NSDate* end = [df dateFromString:poi.endDate];
            
            NSTimeInterval distanceBetweenDates = [end timeIntervalSinceDate:start];
            double secondsInAnMinute = 60;
            NSInteger minutesBetweenDates = distanceBetweenDates / secondsInAnMinute;
            
            //We only care about the same day
            int daysBetween = (int) minutesBetweenDates / 1440;   //1440 minutes in a day
            
            minutesBetweenDates -= daysBetween*1440;
            
            NSString* addString;
            if (minutesBetweenDates==1)
                addString = [NSString stringWithFormat:@" (%d %@)", minutesBetweenDates, L(MINUTE)];
            else
                addString = [NSString stringWithFormat:@" (%d %@)", minutesBetweenDates, L(MINUTES)];
            
            
            calloutName = [calloutName stringByAppendingString:addString];
        }
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [[NSNumber alloc] initWithDouble:poi.location.coordinate.latitude],       MAP_LATITUDE_KEY,
                              [[NSNumber alloc] initWithDouble:poi.location.coordinate.longitude],      MAP_LONGITUDE_KEY,
                              calloutName,                                                              MAP_CALLOUT_KEY,
                              poi.comment,                                                              MAP_CALLOUT_SUB_KEY,
                              [[NSNumber alloc] initWithInt:i],                                         MAP_TAG_KEY,
                              [[NSNumber alloc] initWithInt:EPinDefault],                               MAP_PIN_TYPE_KEY,
                              nil];
        
        [locations addObject:dict];
    }
    return locations;
}


#pragma mark - MapView delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    // in case it's the user location just return nil
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    
    // Dequeue an existing pin view first
    static NSString *annotationIdentifier = @"annotationIdentifier";
    
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    
    if (pinView == nil)
    {
        // if an existing pin view was not available, create one
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
    }
    
    pinView.animatesDrop = NO;
    pinView.canShowCallout = YES;
    
    if (self.pointsOfInterest.count>0)
    {
        pinView.image = [UIImage imageNamed:@"pinblue"];
        
        UILabel* number = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, 20, 10)];
        number.font = CELLFONTSMALL;
        number.textColor = [UIColor whiteColor];
        number.backgroundColor = [UIColor clearColor];
        number.textAlignment = NSTextAlignmentCenter;
        number.text = [NSString stringWithFormat:@"%d",[(MapAnnotation *)annotation tag]];
        
        [pinView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
        [pinView addSubview:number];
    }
    return pinView;
}


#pragma mark - Show trajectory and trace line call & delegate

-(void)showTrajectoryLine {

    for (int i=0 ; i<self.pointsOfInterest.count ; i++)
    {
        CLLocationCoordinate2D coord[2];
        
        if (i!=0)
        {
            coord[0] = ((POI*)[self.pointsOfInterest objectAtIndex:i-1]).location.coordinate;
            coord[1] = ((POI*)[self.pointsOfInterest objectAtIndex:i]).location.coordinate;
        }
        
        polyline = [MKPolyline polylineWithCoordinates:coord count:2];
        [self.gMapView addOverlay:polyline];
    }
}


-(void)showTraceLineWithLocations:(NSArray*)locations {
    
    isRenderingGPSTrace = YES;
    
    //Show trace line
    for (int i=0 ; i<locations.count ; i++)
    {
        CLLocationCoordinate2D coord[2];
        
        if (i!=0)
        {
            coord[0] = ((CLLocation*)[locations objectAtIndex:i]).coordinate;     //i-1 for connected line
            coord[1] = ((CLLocation*)[locations objectAtIndex:i]).coordinate;
        }
        
        polyline = [MKPolyline polylineWithCoordinates:coord count:2];
        [self.gMapView addOverlay:polyline];
    }
}




- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    if (!isRenderingGPSTrace)
    {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.strokeColor = [UIColor blueColor];
        renderer.lineWidth = 2;
        return renderer;
    }
    else    //Render GPS trace
    {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.strokeColor = [UIColor redColor];
        renderer.lineWidth = 2;
        return renderer;
    }
}


#pragma mark - Show Calendar view

-(void)showCalendarView {
    
    CalendarDayViewController* calVC = [[CalendarDayViewController alloc] init];
    calVC.pois = self.pointsOfInterest;
    calVC.blogDate = self.blogDate;
    
    UINavigationController *calNavController = [[UINavigationController alloc] initWithRootViewController:calVC];
    [self.navigationController presentViewController:calNavController animated:YES completion:nil];
}



#pragma mark - Trace delegate

-(void)traceRetrieved:(NSArray*)locations {
    
    //Show the GPS trace line
    [self showTraceLineWithLocations:locations];
}

@end
