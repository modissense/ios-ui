//
//  MapResultsViewController.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 9/4/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "MapResultsViewController.h"
#import "Engine.h"
#import "POI.h"
#import "Util.h"

@interface MapResultsViewController () {
    
    //Array of POI locations
    NSArray* gMapLocations;
    
    //Line that will show up user's path on the map
    MKPolyline *polyline;
}

@end

@implementation MapResultsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //For iOS7
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
        ADJUST_IOS7_LAYOUT
	
    if (self.showTrajectory)
        self.title = L(HISTORY);
    else
        self.title = L(RESULTS);
    
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
    
    if (self.showTrajectory)
        [self showTrajectoryLine];
    
//    [self.gMapView setRegion:self.region animated:YES];
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
            double secondsInAnHour = 3600;
            NSInteger hoursBetweenDates = distanceBetweenDates / secondsInAnHour;
            
            NSString* addString;
            if (hoursBetweenDates>1)
                addString = [NSString stringWithFormat:@" (%d %@)", hoursBetweenDates, L(HOURS)];
            else
                addString = [NSString stringWithFormat:@" (%d %@)", hoursBetweenDates, L(HOUR)];
            
            
            calloutName = [calloutName stringByAppendingString:addString];
        }
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [[NSNumber alloc] initWithDouble:poi.location.coordinate.latitude],       MAP_LATITUDE_KEY,
                              [[NSNumber alloc] initWithDouble:poi.location.coordinate.longitude],      MAP_LONGITUDE_KEY,
                              calloutName,                                                              MAP_CALLOUT_KEY,
                              poi.description,                                                          MAP_CALLOUT_SUB_KEY,
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
    
    pinView.animatesDrop = YES;
    pinView.canShowCallout = YES;
    
    if (self.pointsOfInterest.count>0)
    {
        POI* poi = [self.pointsOfInterest objectAtIndex:[(MapAnnotation *)annotation tag]];
        
        //Set the left accessory annotation view according to hotness or interest
        UIImageView* leftView;
        
        if (poi.hotness > poi.interest)
            leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hot"]];
        else if (poi.hotness < poi.interest)
            leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"interesting"]];
        else
            leftView = nil;
        
        pinView.leftCalloutAccessoryView = leftView;
    
        
        //Set an edit button as the rught accessory view
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        rightButton.frame = CGRectMake(0.0, 0.0, 16.0, 16.0);
        [rightButton setImage:[UIImage imageNamed:@"pencil"] forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(editPOI:) forControlEvents:UIControlEventTouchUpInside];
        
        //Set a tag to the info button so we know what button was pressed
        rightButton.tag = [(MapAnnotation *)annotation tag];
        
        pinView.rightCalloutAccessoryView = rightButton;
        
        //Green color
        pinView.pinColor = MKPinAnnotationColorGreen;
    }
    return pinView;
}


#pragma mark - Edit POI clicked & delegates called

-(void)editPOI:(UIButton*)infoButton {
    
    POI* poi = [self.pointsOfInterest objectAtIndex:infoButton.tag];
    NSLog(@"Editing poi %d",infoButton.tag);
    
    EditPOIViewController* editVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EditPOIViewID"];
    editVC.delegate = self;
    editVC.nearMeMap = NO;
    editVC.tag = infoButton.tag;
    editVC.name = poi.name;
    editVC.poiLocation = poi.location;
    editVC.keywords = poi.keywords;
    editVC.description = poi.description;
    [self.navigationController pushViewController:editVC animated:YES];
}


-(void)updatePinWithTag:(NSInteger)tag name:(NSString*)name location:(CLLocation*)location descriptiom:(NSString*)description publicity:(BOOL)publicity andKeywords:(NSArray*)keywords {
    
    POI* poi = [self.pointsOfInterest objectAtIndex:tag];
    poi.name = name;
    poi.location = location;
    poi.description = description;
    poi.publicity = publicity;
    poi.keywords = keywords;
    
    NSMutableArray* pois = [NSMutableArray arrayWithArray:self.pointsOfInterest];
    [pois replaceObjectAtIndex:tag withObject:poi];
    self.pointsOfInterest = pois;
    
    [self recreatePins];
}


-(void)removePinWithTag:(NSInteger)tag {
    
    POI* poi = [self.pointsOfInterest objectAtIndex:tag];
    
    NSMutableArray* pois = [NSMutableArray arrayWithArray:self.pointsOfInterest];
    [pois removeObject:poi];
    self.pointsOfInterest = pois;
    
    [self recreatePins];
}


-(void) recreatePins {
    
    //Create map locations
    gMapLocations = [self createMapLocations];
    
    //Set them
    [self.gMapView setLocations:gMapLocations];
    
    //Show with pins
    [self.gMapView show];
    
    if (self.showTrajectory)
        [self showTrajectoryLine];
}


#pragma mark - Show trajectory line call & delegate

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


//Draw line between locations
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    
    MKPolylineView *polyLineView = [[MKPolylineView alloc] initWithPolyline:polyline];
    polyLineView.fillColor = [UIColor blueColor];
    polyLineView.strokeColor = [UIColor blueColor];
    polyLineView.lineWidth = 4;
    return polyLineView;
}

@end
