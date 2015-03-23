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
#import "REVClusterAnnotationView.h"

@interface MapResultsViewController () {
    
    //Array of POI locations
    NSArray* gMapLocations;
    
    //Line that will show up user's path on the map
    MKPolyline *polyline;
    
    MKCoordinateRegion rememberedMapRegion;
    UIToolbar* blurBackground;
    MKCoordinateRegion beforeShowingDetailsRegion;;
    
    CLLocation* currentLocationShowing;
}

@end

@implementation MapResultsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //For iOS7
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
        ADJUST_IOS7_LAYOUT
        
    //Initially hidden
    self.poiDetailsView.alpha = 0.0;
    self.poiDetailsView.frame = CGRectMake(0, -self.poiDetailsView.frame.size.height, self.poiDetailsView.frame.size.width, self.poiDetailsView.frame.size.height);
    [self.editBtn setTitle:L(EDIT) forState:UIControlStateNormal];
    [self.closeBtn setTitle:L(CLOSE) forState:UIControlStateNormal];

    self.title = L(RESULTS);
    
    self.gMapView.showsUserLocation = YES;
    
    //Initialize polyline
    polyline = [[MKPolyline alloc] init];
    
    //Set delegate to self
    self.gMapView.gMapDelegate = self;
    self.gMapView.delegate = self;
    self.gMapView.selectionDelegate = self;

    
    //Create map locations
    gMapLocations = [self createMapLocations];
    
    //Set them
    [self.gMapView setLocations:gMapLocations];
    
    //Show with pins
    [self.gMapView show];
    
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
        if (calloutName==nil || [calloutName isKindOfClass:[NSNull class]] || [calloutName isEqualToString:@"null"] || calloutName.length==0)
            calloutName = L(NONAME);
        
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
            
            NSString* addString;
            if (minutesBetweenDates<=1)
                addString = [NSString stringWithFormat:@" (%d %@)", minutesBetweenDates, L(MINUTE)];
            else
                addString = [NSString stringWithFormat:@" (%d %@)", minutesBetweenDates, L(MINUTES)];
            
            
            calloutName = [calloutName stringByAppendingString:addString];
        }
        
        if (calloutName.length > 19)
        {
            calloutName = [NSString stringWithFormat:@"%@..", [calloutName substringToIndex:17]];
        }
        
        NSString* description = poi.comment;
        if (description==nil || [description isKindOfClass:[NSNull class]] || [description isEqualToString:@"null"] || description.length==0)
            description = L(NODESCRIPTION);
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [[NSNumber alloc] initWithDouble:poi.location.coordinate.latitude],       MAP_LATITUDE_KEY,
                              [[NSNumber alloc] initWithDouble:poi.location.coordinate.longitude],      MAP_LONGITUDE_KEY,
                              calloutName,                                                              MAP_CALLOUT_KEY,
                              description,                                                              MAP_CALLOUT_SUB_KEY,
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
    
    REVClusterPin *pin = (REVClusterPin *)annotation;
    
    if( [pin nodeCount] > 0 ){
        
        MyLog(@"Cluster found");
        
        static NSString *annotationIdentifier = @"clusterAnnotationIdentifier";
        
        MKAnnotationView *annView = (REVClusterAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        
        if(!annView)
            annView = (REVClusterAnnotationView*)[[REVClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        
        annView.image = [UIImage imageNamed:@"cluster"];
        
        [(REVClusterAnnotationView*)annView setClusterText:[NSString stringWithFormat:@"%d",[pin nodeCount]]];
        
        NSLog(@"%@", [NSString stringWithFormat:@"%d",[pin nodeCount]]);
        
        annView.canShowCallout = NO;
        
        return annView;
        
    }
    else
    {
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
            if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
            {
                
                CGFloat leftViewDimension;
                if ([[[UIDevice currentDevice] systemVersion] intValue] >= 8)
                    leftViewDimension = 55;
                else
                    leftViewDimension = 45;
                
                UIButton* directionsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, leftViewDimension, leftViewDimension)];
                [directionsButton setImage:[UIImage imageNamed:@"car"] forState:UIControlStateNormal];
                [directionsButton addTarget:self action:@selector(getDirections:) forControlEvents:UIControlEventTouchUpInside];
                directionsButton.tag = [(MapAnnotation *)annotation tag];
                
                UIView* leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, leftViewDimension, 100)];
                leftView.backgroundColor = [UIColor blueColor];
                [leftView addSubview:directionsButton];
                
                pinView.leftCalloutAccessoryView = leftView;
            }
            
            //Set an edit button as the right accessory view
            UIButton* rightInfoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            rightInfoButton.frame = CGRectMake(0.0, 0.0, 16.0, 16.0);
            [rightInfoButton setImage:[UIImage imageNamed:@"accessoryIndicator"] forState:UIControlStateNormal];
            [rightInfoButton addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
            rightInfoButton.tag = [(MapAnnotation *)annotation tag];
            
            pinView.rightCalloutAccessoryView = rightInfoButton;
            
            pinView.image = [UIImage imageNamed:@"pinblue"];
            
            UILabel* number = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, 20, 10)];
            number.font = CELLFONTSMALL;
            number.adjustsFontSizeToFitWidth = YES;
            number.textColor = [UIColor whiteColor];
            number.backgroundColor = [UIColor clearColor];
            number.textAlignment = NSTextAlignmentCenter;
            number.text = [NSString stringWithFormat:@"%d",[(MapAnnotation *)annotation tag]];
            
            [pinView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
            [pinView addSubview:number];
        }
        return pinView;
    }
}


#pragma mark - Edit button clicked

-(void)edit:(UIButton*)infoButton {
    NSLog(@"Editing pin %d ",infoButton.tag);
    
    [self showPinInfo:infoButton.tag];
    
    /*
    UIActionSheet* AS = [[UIActionSheet alloc] init];
    [AS setDelegate:self];
    [AS addButtonWithTitle:L(CANCEL)];
    [AS setDestructiveButtonIndex:0];
    
    [AS addButtonWithTitle:L(EDIT)];
    [AS addButtonWithTitle:L(MORE)];
    
    //Save the tag so we can know which POI was pressed
    AS.tag = infoButton.tag;
    
    AS.actionSheetStyle = UIActionSheetStyleDefault;
    
    [AS showFromToolbar:self.navigationController.toolbar];
     */
}


#pragma mark - Action sheet delegate


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1)
    {
        [self editPOI:actionSheet.tag];
    }
    
    if (buttonIndex==2)
    {
        [self showPinInfo:actionSheet.tag];
    }
}


#pragma mark - Show pin info clicked

-(void)showPinInfo:(int)tag {
    NSLog(@"Showing info for pin %d ",tag);
    
    beforeShowingDetailsRegion = self.gMapView.region;
    
    POI* poi = [self.pointsOfInterest objectAtIndex:tag];
    
    currentLocationShowing = poi.location;
    
    //Zoom to pin !
    [UIView animateWithDuration:0.5 animations:^{
        
        MKCoordinateRegion region;
        region.center = poi.location.coordinate;                          // Current location
        region.center.latitude += 0.0012;                                 //Move pin down a little
        MKCoordinateSpan span;
        span.latitudeDelta = 0.003;                                       // From 0.001 to 120
        span.longitudeDelta = 0.003;
        region.span=span;
        [self.gMapView setRegion:region animated:YES];
    }];

    [self getPOIDetails:tag withPOIID:poi.poi_id];
}


#pragma mark - Get POI details call & elegate

-(void)getPOIDetails:(int)tag withPOIID:(int)poiID {
    
    POIEngine* poiEngine = [[POIEngine alloc] init];
    poiEngine.delegate=self;
    [poiEngine getPOIDetails:poiID];
    
    //Clear all details before reappearing
    [self.poiDetailsView clearAllPOIDetails];
    [self showMoreView:tag];
}


-(void)gotPOIDetails:(POIDetails*)poiDetails {
    
    [self.poiDetailsView setPOIDetails:poiDetails withLocation:currentLocationShowing];
}



#pragma mark - POI deails View show/hide

-(void)showMoreView:(int)tag {
    
    self.editBtn.tag = tag;
    
    if (self.poiDetailsView.alpha == 1.0)
        [self hideMoreView];
    
    self.poiDetailsView.backgroundColor = [UIColor whiteColor];
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.poiDetailsView.frame = CGRectMake(0, 0, self.poiDetailsView.frame.size.width, self.poiDetailsView.frame.size.height);
        self.poiDetailsView.alpha = 1.0;
        
    } completion:^(BOOL finshied){
        
//        self.moreView.backgroundColor = [UIColor clearColor];
//        
//        //Blur content under bottom view
//        blurBackground = [[UIToolbar alloc] initWithFrame:self.moreView.frame];
//        blurBackground.barStyle = UIBarStyleDefault;
//        [self.moreView.superview insertSubview:blurBackground belowSubview:self.moreView];
    }];
}

-(void)hideMoreView {
    
//    [blurBackground removeFromSuperview];
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.poiDetailsView.frame = CGRectMake(0, -self.poiDetailsView.frame.size.height, self.poiDetailsView.frame.size.width, self.poiDetailsView.frame.size.height);
        self.poiDetailsView.alpha = 0.0;
        self.gMapView.region = beforeShowingDetailsRegion;
    }];
}



#pragma mark - Get directions clicked

-(void)getDirections:(UIButton*)infoButton {
    
    POI* poi = [self.pointsOfInterest objectAtIndex:infoButton.tag];
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:poi.location.coordinate addressDictionary:nil];
    MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:placemark];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    request.source = [MKMapItem mapItemForCurrentLocation];
    
    request.destination = destination;
    request.requestsAlternateRoutes = NO;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [SVProgressHUD showWithStatus:L(GETTINGDIRECTIONS) maskType:SVProgressHUDMaskTypeBlack];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         
         [SVProgressHUD dismiss];
         
         if (error) {
             [SVProgressHUD showErrorWithStatus:L(COULDNOTGETDIRECTIONS)];
         } else {
             [self showRoute:response];
         }
     }];
}


-(void)showRoute:(MKDirectionsResponse *)response
{
    [self.gMapView removeOverlays:[self.gMapView overlays]];
    
    for (MKRoute *route in response.routes)
    {
        [self.gMapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
        for (MKRouteStep *step in route.steps)
        {
            NSLog(@"%@", step.instructions);
        }
    }
}


- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 2;
    return renderer;
}

//Draw line between locations
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    
    MKPolylineView *polyLineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polyLineView.fillColor = [UIColor blueColor];
    polyLineView.strokeColor = [UIColor blueColor];
    polyLineView.lineWidth = 4;
    return polyLineView;
}


#pragma mark - Edit POI clicked & delegates called

-(void)editPOI:(int)tag {
    
    POI* poi = [self.pointsOfInterest objectAtIndex:tag];
    NSLog(@"Editing poi %d",tag);
    
    EditPOIViewController* editVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EditPOIViewID"];
    editVC.poi = poi;
    editVC.delegate = self;
    editVC.nearMeMap = NO;
    editVC.tag = tag;
    [self.navigationController pushViewController:editVC animated:YES];
}


-(void)updatePinWithTag:(NSInteger)tag name:(NSString*)name location:(CLLocation*)location descriptiom:(NSString*)description publicity:(BOOL)publicity andKeywords:(NSArray*)keywords {
    
    //Remember map region before updating
    rememberedMapRegion = self.gMapView.region;
    
    POI* poi = [self.pointsOfInterest objectAtIndex:tag];
    poi.name = name;
    poi.location = location;
    poi.comment = description;
    poi.publicity = publicity;
    poi.keywords = keywords;
    
    NSMutableArray* pois = [NSMutableArray arrayWithArray:self.pointsOfInterest];
    [pois replaceObjectAtIndex:tag withObject:poi];
    self.pointsOfInterest = pois;
    
    [self recreatePins];
}


-(void)removePinWithTag:(NSInteger)tag {
    
    //Clear directions that might are present
    [self.gMapView removeOverlays:[self.gMapView overlays]];
    
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
    
    //Center map where it was
    self.gMapView.region = rememberedMapRegion;
}


#pragma mark - More View buttons

- (IBAction)closeMoreView:(id)sender {
    [self hideMoreView];
}

- (IBAction)editPOIBtnClicked:(UIButton*)sender {
    [self hideMoreView];
    [self editPOI:sender.tag];
}
@end
