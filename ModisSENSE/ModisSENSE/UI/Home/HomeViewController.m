//
//  HomeViewController.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/12/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "HomeViewController.h"
#import "POI.h"
#import "Engine.h"
#import "Config.h"
#import "Util.h"
#import "REVClusterAnnotationView.h"

@interface HomeViewController () {
    
    UIBarButtonItem *refreshBtn;
    UIBarButtonItem *friendsBtn;
    
    MKCoordinateRegion mapRegion;
    BOOL zoomin;
    BOOL isShowingRoute;
    
    NSArray* pointsOfInterest;
    
    //Array of POI locations
    NSArray* gMapLocations;
    
    //This will store my previous location
    CLLocationCoordinate2D myPreviousLocation;
    
    //Line that will show up user's path on the map
    MKPolyline *polyline;
    BOOL locationUpdated;
    
    NSDateFormatter* dateFormatter;
    
    UIView* info;
    UIToolbar* blurBackground;
    
    MKCoordinateRegion beforeShowingDetailsRegion;
    
    UIActivityIndicatorView* trendingSpinner;
    BOOL isTrending;
    
    CLLocation* currentLocationShowing;
    
    CLLocationCoordinate2D northWestCorner;     //Upper left of the selected rect of the map
    CLLocationCoordinate2D southEastCorner;     //Down right of the selected rect of the map
}

@end


@implementation HomeViewController

//Properties in MKOverlay protocol. Must be synthesized to supress warning.
@synthesize coordinate;
@synthesize boundingMapRect;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Initially hidden
    self.poiDetailsView.alpha = 0.0;
    self.poiDetailsView.frame = CGRectMake(0, -self.poiDetailsView.frame.size.height, self.poiDetailsView.frame.size.width, self.poiDetailsView.frame.size.height);
    
    [self.editBtn setTitle:L(EDIT) forState:UIControlStateNormal];
    [self.closeBtn setTitle:L(CLOSE) forState:UIControlStateNormal];
    
    /*************/
    isTrending = NO;
    
    CALayer * infoLayer = self.trendingNowView.layer;
    [infoLayer setMasksToBounds:YES];
    [infoLayer setCornerRadius:2.0];
    
    self.trendingNowLabel.text = L(SHOWTRENDS);
    self.trendingNowView.backgroundColor = DARKRED;
    
    UITapGestureRecognizer *trendingTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(trendingLabelTapped)];
	trendingTap.numberOfTapsRequired = 1;			// How many taps
	trendingTap.numberOfTouchesRequired = 1;		// How many fingers
	[self.trendingNowView addGestureRecognizer: trendingTap];
    /*************/
    
    //For iOS7
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
        ADJUST_IOS7_LAYOUT
    
    self.title = L(NEARME);
    
    locationUpdated = NO;
    zoomin = YES;
    isShowingRoute = NO;
    
//    UIBarButtonItem* refreshBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(searchForPOIS)];
    refreshBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh"] style:UIBarButtonItemStylePlain target:self action:@selector(refreshPOIs)];
    UIBarButtonItem *myLocationBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"loctarget"] style:UIBarButtonItemStylePlain target:self action:@selector(showMyLocation)];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:refreshBtn, myLocationBtn, nil];
    
    UIBarButtonItem* iBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showAddNewPOIVC)];
//    UIBarButtonItem *iBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"info"] style:UIBarButtonItemStylePlain target:self action:@selector(showAddNewPOIVC)];
//    UIBarButtonItem *addNewPOIBtn =[[UIBarButtonItem alloc] initWithTitle:L(ADDNEW) style:UIBarButtonItemStylePlain target:self action:@selector(addNewPOIClicked)];
    friendsBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"friends"] style:UIBarButtonItemStylePlain target:self action:@selector(showFriendsList)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:iBtn, friendsBtn, nil];
    
    //Retrieve friends from service
    [self getFriends];
    [self hideTrendsingLabel];
    
    //Initialize selected users preferences
    Eng.preferences.selectedTwitterUsers = [[NSMutableDictionary alloc] init];
    Eng.preferences.selectedFacebookUsers = [[NSMutableDictionary alloc] init];
    Eng.preferences.selectedFoursquareUsers = [[NSMutableDictionary alloc] init];
    
    Eng.preferences.selectedFriendIDs = [[NSMutableArray alloc] init];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]]; 
    [dateFormatter setDateFormat:@"yyy-MM-dd HH:mm:ss"];
    
    //When I start, my previous location is my current location
    myPreviousLocation = Eng.locationTracker.currentlocation.coordinate;
    
    //Initialize polyline
    polyline = [[MKPolyline alloc] init];
    
    //Set delegate to self
    self.gMapView.gMapDelegate = self;
    self.gMapView.delegate = self;
    self.gMapView.selectionDelegate = self;
    
    [self setTabBarTitles];
    
    //Set map region as the user location at first
    mapRegion.center = Eng.locationTracker.currentlocation.coordinate;   // Current location
    
    
    //Long press recognizer.
    //When the user long presses a point, a new POI will be added
    UILongPressGestureRecognizer* longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDetected:)];
    //adjust time interval(floating value CFTimeInterval in seconds)
    [longPressGesture setMinimumPressDuration:1.0];
    //add gesture to view you want to listen for it(note that if you want whole view to "listen" for gestures you should add gesture to self.view instead)
    [self.gMapView addGestureRecognizer:longPressGesture];
    
    /**************************************************/
    //TO BE DELETED
//    NSMutableArray* arr = [[NSMutableArray alloc] init];
//    POI* poi = [[POI alloc] init];
//    poi.name = @"Hard Rock Cafe";
//    poi.comment = @"Get the fredoccino, it's awesome.";
//    
//    poi.interest = 3;
//    poi.hotness = 3;
//    
//    CLLocation *currentPoint = [[CLLocation alloc] initWithLatitude:38.030715 longitude:23.797138];   //ATC
//    poi.location = currentPoint;
//    poi.timestamp = @"2013-09-06 23:29:43";
//    
//    [arr addObject:poi];
//    pointsOfInterest = arr;
    /**************************************************/
}


-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //Create map locations
    gMapLocations = [self createMapLocations];
    
    //Set them
    [self.gMapView setLocations:gMapLocations];
    

    self.gMapView.showsUserLocation = YES;
        
    // Show path line
    Eng.locationTracker.locationUpdateDelegate=self;

    //Show with pins
    [self.gMapView show];
    
    
    //Set map zoom level
    if (zoomin)
    {
        MKCoordinateSpan span;
        span.latitudeDelta = 0.03;                                       // From 0.001 to 120
        span.longitudeDelta = 0.03;
        mapRegion.span=span;
    }
    
    //Set map region
    [self.gMapView setRegion:mapRegion animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    zoomin = NO;
    mapRegion = self.gMapView.region;   // Current location
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Trendings

-(void) showTrendsingLabel {
    
    [UIView animateWithDuration:1.0 animations:^{
        
        self.trendingNowView.frame = CGRectMake(self.trendingNowView.frame.origin.x - self.trendingNowView.frame.size.width + 25, self.trendingNowView.frame.origin.y, self.trendingNowView.frame.size.width, self.trendingNowView.frame.size.height);
    }];
}

-(void) hideTrendsingLabel {
    
    [UIView animateWithDuration:1.0 animations:^{
        
        self.trendingNowView.frame = CGRectMake(self.trendingNowView.frame.origin.x + self.trendingNowView.frame.size.width - 25, self.trendingNowView.frame.origin.y, self.trendingNowView.frame.size.width, self.trendingNowView.frame.size.height);
    }];
}


-(void) trendingLabelTapped {
    NSLog(@"Trendings label tapped");
    
    if (isTrending)
    {
        [self searchForPOIS];
    }
    else
    {
        [self searchForTrendingPOIS];
    }
}



#pragma mark - Refresh POIs (Navigation left buttom)
-(void) refreshPOIs {
    
    if (isTrending)
        [self searchForTrendingPOIS];
    else
        [self searchForPOIS];
}



#pragma mark - Show add new POI info

-(void)showAddNewPOIVC {
    
    /*
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"ModisSENSE"
                                                        message:L(HOWTOADDNEWPOI)
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [alertView show];
     */
    
    UINavigationController *navVC =[self.storyboard instantiateViewControllerWithIdentifier:@"AddBlogRecordNavID"];
    AddPOIViewController *vc = [navVC.viewControllers objectAtIndex:0];
    vc.delegate = self;
    vc.poiLocation = LocTrck.currentlocation;
    vc.isModal = YES;
    [self presentViewController:navVC animated:YES completion:nil];
}


#pragma mark - Long press gesture delegate

-(void)longPressDetected:(UISwipeGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:self.gMapView];
    
    CLLocationCoordinate2D tapPoint = [self.gMapView convertPoint:point toCoordinateFromView:self.gMapView];
    
    CLLocation *tappedPointLocation = [[CLLocation alloc] initWithLatitude:tapPoint.latitude longitude:tapPoint.longitude];
    
//    MKPointAnnotation *newPOIPoint = [[MKPointAnnotation alloc] init];
//    newPOIPoint.coordinate = tapPoint;
    
    UINavigationController *navVC =[self.storyboard instantiateViewControllerWithIdentifier:@"AddBlogRecordNavID"];
    AddPOIViewController *vc = [navVC.viewControllers objectAtIndex:0];
    vc.delegate = self;
    vc.poiLocation = tappedPointLocation;
    vc.isModal = YES;
    [self presentViewController:navVC animated:YES completion:nil];
}




#pragma mark - Create locations array

-(NSArray *)createMapLocations {
    
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    
    if (!pointsOfInterest || pointsOfInterest.count == 0)
        return nil;
    
    
    for(int i = 0; i < pointsOfInterest.count; i++)
    {
        POI *p = [pointsOfInterest objectAtIndex:i];
        
        NSString* name = p.name;
        
        if (name.length > 19)
        {
            name = [NSString stringWithFormat:@"%@..", [name substringToIndex:17]];
        }
        
        if (name==nil || [name isKindOfClass:[NSNull class]] || [name isEqualToString:@"null"] || name.length==0)
            name = L(NONAME);
        
        NSString* comment = p.comment;
        if (comment==nil || [comment isKindOfClass:[NSNull class]] || [comment isEqualToString:@"null"] || comment.length==0)
            comment = L(NODESCRIPTION);
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [[NSNumber alloc] initWithDouble:p.location.coordinate.latitude],    MAP_LATITUDE_KEY,
                              [[NSNumber alloc] initWithDouble:p.location.coordinate.longitude],   MAP_LONGITUDE_KEY,
                              name,                                                              MAP_CALLOUT_KEY,
                              comment,                                                             MAP_CALLOUT_SUB_KEY,
                              [[NSNumber alloc] initWithInt:i],                                    MAP_TAG_KEY,
                              [[NSNumber alloc] initWithInt:EPinDefault],                          MAP_PIN_TYPE_KEY,
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
            annView = (REVClusterAnnotationView*)
            
        [[REVClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        
        if (isTrending)
            annView.image = [UIImage imageNamed:@"clusterred"];
        else
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
        
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[self.gMapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        
        if (pinView == nil)
        {
            // if an existing pin view was not available, create one
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        }
        
        pinView.animatesDrop = NO;
        pinView.canShowCallout = YES;
        
        if (pointsOfInterest.count>0)
        {
            NSInteger tag = [(MapAnnotation *)annotation tag];
            
            if (tag<pointsOfInterest.count)
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
                    
                    if (isTrending)
                        leftView.backgroundColor = DARKRED;
                    else
                        leftView.backgroundColor = [UIColor blueColor];
                    
                    [leftView addSubview:directionsButton];
                    
                    pinView.leftCalloutAccessoryView = leftView;
                }
                
                //Set an edit button as the right accessory view
                UIButton* rightInfoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                rightInfoButton.frame = CGRectMake(0.0, 0.0, 16.0, 16.0);
                
                if (isTrending)
                    [rightInfoButton setImage:[UIImage imageNamed:@"hot"] forState:UIControlStateNormal];
                else
                    [rightInfoButton setImage:[UIImage imageNamed:@"accessoryIndicator"] forState:UIControlStateNormal];
                
                [rightInfoButton addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
                rightInfoButton.tag = [(MapAnnotation *)annotation tag];
                
                pinView.rightCalloutAccessoryView = rightInfoButton;
                
                //Green color
//                pinView.pinColor = MKPinAnnotationColorGreen;
                if (isTrending)
                    pinView.image = [UIImage imageNamed:@"pinred"];
                else
                    pinView.image = [UIImage imageNamed:@"pinblue"];
                
                UILabel* number = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, 20, 10)];
                number.font = CELLFONTSMALL;
                number.adjustsFontSizeToFitWidth = YES;
                number.textColor = [UIColor whiteColor];
                number.backgroundColor = [UIColor clearColor];
                number.textAlignment = NSTextAlignmentCenter;
                number.text = [NSString stringWithFormat:@"%d",rightInfoButton.tag];
                
                [pinView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
                [pinView addSubview:number];
            }
        }
    return pinView;
    }
}

//Reload trending POIs if user changed region on map
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
}


#pragma mark = Show my location

-(void)showMyLocation {
    zoomin = YES;
    mapRegion.center = Eng.locationTracker.currentlocation.coordinate;   // Current location
    [self viewWillAppear:YES];
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
    
    [AS showFromTabBar:self.tabBarController.tabBar];
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
    
    POI* poi = [pointsOfInterest objectAtIndex:tag];
    
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
    
    [self hideTrendsingLabel];
    
    self.editBtn.tag = tag;
    
    if (self.poiDetailsView.alpha == 1.0)
        [self hideMoreView];
    
    self.poiDetailsView.backgroundColor = [UIColor whiteColor];
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.poiDetailsView.frame = CGRectMake(0, 0, self.poiDetailsView.frame.size.width, self.poiDetailsView.frame.size.height);
        self.poiDetailsView.alpha = 1.0;
        
    } completion:^(BOOL finshied){
        
//        self.moreView.backgroundColor = [UIColor clearColor];
        
        //Blur content under bottom view
//        blurBackground = [[UIToolbar alloc] initWithFrame:self.moreView.frame];
//        blurBackground.barStyle = UIBarStyleDefault;
//        [self.moreView.superview insertSubview:blurBackground belowSubview:self.moreView];
    }];
}

-(void)hideMoreView {
    
    [self showTrendsingLabel];
    
//    [blurBackground removeFromSuperview];
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.poiDetailsView.frame = CGRectMake(0, -self.poiDetailsView.frame.size.height, self.poiDetailsView.frame.size.width, self.poiDetailsView.frame.size.height);
        self.poiDetailsView.alpha = 0.0;
        self.gMapView.region = beforeShowingDetailsRegion;
    }];
}



#pragma mark - Get directions clicked

-(void)getDirections:(UIButton*)infoButton {
    
    isShowingRoute = YES;
    
    POI* poi = [pointsOfInterest objectAtIndex:infoButton.tag];
    
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
    
    isShowingRoute = NO;
}


- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 2;
    return renderer;
}

#pragma mark - Edit POI clicked & delegates called

-(void)editPOI:(int)tag {
    
    POI* poi = [pointsOfInterest objectAtIndex:tag];
    NSLog(@"Editing poi %d",tag);
    
    EditPOIViewController* editVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EditPOIViewID"];
    editVC.delegate = self;
    editVC.poi = poi;
    editVC.nearMeMap = YES;
    editVC.tag = tag;
    [self.navigationController pushViewController:editVC animated:YES];
}


-(void)updatePinWithTag:(NSInteger)tag name:(NSString*)name location:(CLLocation*)location descriptiom:(NSString*)description publicity:(BOOL)publicity andKeywords:(NSArray*)keywords {
    
    POI* poi = [pointsOfInterest objectAtIndex:tag];
    poi.name = name;
    poi.location = location;
    poi.comment = description;
    poi.publicity = publicity;
    poi.keywords = keywords;
    
    NSMutableArray* pois = [NSMutableArray arrayWithArray:pointsOfInterest];
    [pois replaceObjectAtIndex:tag withObject:poi];
    pointsOfInterest = pois;
    
    [self updateMap];
}


-(void)removePinWithTag:(NSInteger)tag {
    
    //Clear directions that might are present
    [self.gMapView removeOverlays:[self.gMapView overlays]];
    
    POI* poi = [pointsOfInterest objectAtIndex:tag];
    
    NSMutableArray* pois = [NSMutableArray arrayWithArray:pointsOfInterest];
    [pois removeObject:poi];
    
    pointsOfInterest = pois;
    
    [self updateMap];
}




#pragma mark - Set tab bar titles

- (void)setTabBarTitles
{
    //Set titles to tab view controllers
    //Avoid localization of the storyboard file
    
    int counter=1;
    for (UIViewController *vc in self.tabBarController.viewControllers)
    {
        switch (counter)
        {
            case 1:
            {
                vc.title = L(NEARME);
                break;
            }
            case 2:
            {
                vc.title = L(SEARCH);
                break;
            }
            case 3:
            {
                vc.title = L(BLOGS);
                break;
            }
            case 4:
            {
                vc.title = L(SETTINGS);
                break;
            }
            case 5:
            {
                vc.title = L(PROFILE);
                break;
            }
        }
        counter++;
    }
}


#pragma mark - Location update delegate

-(void)locationUpdated {
    
    locationUpdated = YES;
    
    CLLocationCoordinate2D coord[2];
//    coord[0] = myPreviousLocation;    //Uncomment this and remove the below line for straight line overlay. This will show up dots
    coord[0] = Eng.locationTracker.currentlocation.coordinate;
    coord[1] = Eng.locationTracker.currentlocation.coordinate;
    
    polyline = [MKPolyline polylineWithCoordinates:coord count:2];
    [self.gMapView addOverlay:polyline];
    
    myPreviousLocation = Eng.locationTracker.currentlocation.coordinate;
}


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    
    if (!isShowingRoute)    //Tracking path
    {
        MKPolylineView *polyLineView = [[MKPolylineView alloc] initWithPolyline:polyline];
        polyLineView.fillColor = [UIColor blueColor];
        polyLineView.strokeColor = [UIColor blueColor];
        polyLineView.lineWidth = 6;
        locationUpdated = NO;
        return polyLineView;
    }
    else                    //Showing route to POI
    {
        MKPolylineView *polyLineView = [[MKPolylineView alloc] initWithPolyline:overlay];
        polyLineView.fillColor = [UIColor blueColor];
        polyLineView.strokeColor = [UIColor blueColor];
        polyLineView.lineWidth = 4;
        return polyLineView;
    }
}

#pragma mark - Trace sent delegate

-(void) traceSent {
    [self showGPSTraceLog];
}


-(void) showGPSTraceLog {
    info = [[UIView alloc] initWithFrame:CGRectMake(5,60, 120,70)];
    info.backgroundColor = [UIColor whiteColor];
    info.layer.opacity = 1.0;
    
    CALayer * infoLayer = info.layer;
    [infoLayer setMasksToBounds:YES];
    [infoLayer setCornerRadius:5.0];
    
    UILabel *infoLabel;
    infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5,info.frame.size.width-10,info.frame.size.height-10)];
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.numberOfLines = 0;
    infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    infoLabel.textAlignment = NSTextAlignmentLeft;
    infoLabel.textColor = [UIColor blackColor];
    infoLabel.font = [UIFont systemFontOfSize:13];
    
    infoLabel.text = [NSString stringWithFormat:@"%d trace(s) sent\nLat: %f \nLng: %f", Eng.locationTracker.tracesSent, Eng.locationTracker.currentlocation.coordinate.latitude, Eng.locationTracker.currentlocation.coordinate.longitude];
    
    [info addSubview:infoLabel];
    
    [self.gMapView addSubview: info];
    
    [self.view bringSubviewToFront:info];
    
    
    [UIView animateWithDuration:1.0 animations:^{
        info.frame = CGRectMake(5,5,120,70);
    }];
    
    [UIView animateWithDuration:4.0 animations:^{
        info.layer.opacity = 0.0;
    } completion:^(BOOL finished){
        [info removeFromSuperview];
    }];
}




#pragma mark - Friends selection

-(void)showFriendsList {
    
    if (Eng.user.twitterFriends.count>0 || Eng.user.facebookFriends.count>0 || Eng.user.foursquareFriends.count>0)
    {
        UINavigationController * friendsNav = [self.storyboard instantiateViewControllerWithIdentifier:@"UserSelectionNavID"];
        
        //Get the Friends View Controller
        UserSelectionViewController *friendsVC = [friendsNav.viewControllers objectAtIndex:0];
        friendsVC.delegate = self;
        
        //        friendsNav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:friendsNav animated:YES completion:nil];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:L(NOFRIENDSAVAILABLE)];
    }
}

- (IBAction)showMapSettings:(id)sender {
    
    if (Eng.user.twitterFriends.count>0 || Eng.user.facebookFriends.count>0 || Eng.user.foursquareFriends.count>0)
    {
        UINavigationController * friendsNav = [self.storyboard instantiateViewControllerWithIdentifier:@"UserSelectionNavID"];
        
        //Get the Friends View Controller
        UserSelectionViewController *friendsVC = [friendsNav.viewControllers objectAtIndex:0];
        friendsVC.delegate = self;
        
//        friendsNav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:friendsNav animated:YES completion:nil];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:L(NOFRIENDSAVAILABLE)];
    }
}


//UserSelectionVC delegate
-(void) friendsSelected {
    
    [self searchForPOIS];
}

// Update the map (map settings delegate)
- (void)updateMap  {
    
    //Clear directions that might are present
    [self.gMapView removeOverlays:[self.gMapView overlays]];
    
    [self viewWillAppear:YES];
}


#pragma mark - Add a location clicked & delegate

//This is commented out
- (void)addNewPOIClicked {
    
    AddPOIViewController *vc =[self.storyboard instantiateViewControllerWithIdentifier:@"AddBlogRecordID"];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}


-(void)newPOIAdded:(POI*)poi {
    [self searchForPOIS];
}



#pragma mark - Show trending POIs call & delegate

-(void) searchForTrendingPOIS {
    
    friendsBtn.tintColor = [[[[UIApplication sharedApplication] delegate] window] tintColor];
    
    zoomin = NO;
//    mapRegion.center = Eng.locationTracker.currentlocation.coordinate;   // Current location
    mapRegion = self.gMapView.region;
    
    /*************/
    //Add spinner to trending view
    if (!trendingSpinner)
        trendingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    trendingSpinner.frame = CGRectMake(self.trendingNowImage.frame.size.width / 2 - trendingSpinner.frame.size.width / 2,
                               self.trendingNowImage.frame.size.height / 2 - trendingSpinner.frame.size.height / 2,
                               trendingSpinner.frame.size.width, trendingSpinner.frame.size.height);
    
    self.trendingNowImage.image = [UIImage imageNamed:@""];
    [self.trendingNowImage addSubview:trendingSpinner];
    [trendingSpinner startAnimating];
    /*************/
    
    //Get map rect area for search
    northWestCorner.latitude  = self.gMapView.region.center.latitude  - (self.gMapView.region.span.latitudeDelta  / 2.0);
    northWestCorner.longitude = self.gMapView.region.center.longitude - (self.gMapView.region.span.longitudeDelta / 2.0);
    southEastCorner.latitude  = self.gMapView.region.center.latitude  + (self.gMapView.region.span.latitudeDelta  / 2.0);
    southEastCorner.longitude = self.gMapView.region.center.longitude + (self.gMapView.region.span.longitudeDelta / 2.0);
    
    NSLog(@"Selected Map rect:");
    NSLog(@"North West coordinates Lat:%f Lng:%f",northWestCorner.latitude,northWestCorner.longitude);
    NSLog(@"South East coordinates Lat:%f Lng:%f",southEastCorner.latitude,southEastCorner.longitude);
    
    NSMutableArray* mapRect = [NSMutableArray array];
    [mapRect addObject:[NSNumber numberWithDouble:northWestCorner.latitude]];
    [mapRect addObject:[NSNumber numberWithDouble:northWestCorner.longitude]];
    [mapRect addObject:[NSNumber numberWithDouble:southEastCorner.latitude]];
    [mapRect addObject:[NSNumber numberWithDouble:southEastCorner.longitude]];
    
    POIEngine* poiEngine = [[POIEngine alloc] init];
    poiEngine.delegate=self;
    [poiEngine getTrendingPOISInArea:mapRect];
}


-(void)gotTrendingPOIs:(NSArray*)poiList {
    
    refreshBtn.tintColor = [UIColor redColor];
    
    if (poiList==nil || poiList.count==0)
        [SVProgressHUD showImage:[UIImage imageNamed:@"trendswhite"] status:L(NOTHINGTRENDING)];
    
    if (!isTrending)
        [self showTrendsingLabel];
    
    self.title = L(TRENDING);
    self.trendingNowLabel.text = L(CLOSE);
    
    isTrending = YES;
    
    if (trendingSpinner)
    {
        [trendingSpinner stopAnimating];
        [trendingSpinner removeFromSuperview];
    }
    
    self.trendingNowImage.image = [UIImage imageNamed:@"trendswhite"];
    
    pointsOfInterest = poiList;
    [self updateMap];
}


#pragma mark - Search for POIs

-(void) searchForPOIS {
    
    refreshBtn.tintColor = [[[[UIApplication sharedApplication] delegate] window] tintColor];
    
    zoomin = NO;
//    mapRegion.center = Eng.locationTracker.currentlocation.coordinate;   // Current location
    mapRegion = self.gMapView.region;
    
    if (Eng.preferences.selectedFriendIDs.count>0)
    {
        [self getPOISBasedOnFriends];
        friendsBtn.tintColor = [UIColor redColor];
    }
    
    else
    {
        [self getNearestNeighbours];
        friendsBtn.tintColor = [[[[UIApplication sharedApplication] delegate] window] tintColor];
    }
}



#pragma mark - Get friends call & delegate

- (void)getFriends {
    
    UserEngine* userEng = [[UserEngine alloc] init];
    userEng.delegate=self;
    [userEng getFriendsForUser:Eng.user.userId showLoader:YES];
}

//Delegate
- (void)gotFriends {
    
    NSLog(@"Main account: %@",Eng.user.mainAccount);
    
    //We have user's friends
    //Now search for POIS
    [self searchForPOIS];
}




#pragma mark - Get nearest neighbours call & delegate

-(void) getNearestNeighbours {
    zoomin = YES;
    mapRegion.center = Eng.locationTracker.currentlocation.coordinate;   // Current location
    
    POIEngine* poiEngine = [[POIEngine alloc] init];
    poiEngine.delegate=self;
    [poiEngine getNearestNeighbours];
}


-(void) gotNearestNeighbours:(NSArray*) poiList {
    
//    [self restoreNavigationColor];
    
    //Hide trending label
    if (isTrending)
        [self hideTrendsingLabel];
    
    self.title = L(NEARME);
    self.trendingNowLabel.text = L(SHOWTRENDS);
    
    isTrending = NO;
    
    pointsOfInterest = poiList;
    [self updateMap];
}


#pragma mark - Get POIS call & delegate

-(void) getPOISBasedOnFriends {
    
    MKCoordinateRegion mapReg = self.gMapView.region;
    northWestCorner.latitude  = mapReg.center.latitude  - (mapReg.span.latitudeDelta  / 2.0);
    northWestCorner.longitude = mapReg.center.longitude - (mapReg.span.longitudeDelta / 2.0);
    southEastCorner.latitude  = mapReg.center.latitude  + (mapReg.span.latitudeDelta  / 2.0);
    southEastCorner.longitude = mapReg.center.longitude + (mapReg.span.longitudeDelta / 2.0);
    
    NSMutableArray* mapRect = [NSMutableArray array];
    [mapRect addObject:[NSNumber numberWithDouble:northWestCorner.latitude]];
    [mapRect addObject:[NSNumber numberWithDouble:northWestCorner.longitude]];
    [mapRect addObject:[NSNumber numberWithDouble:southEastCorner.latitude]];
    [mapRect addObject:[NSNumber numberWithDouble:southEastCorner.longitude]];
    
    POIEngine* poiEngine = [[POIEngine alloc] init];
    poiEngine.delegate=self;
    [poiEngine getPOIsIn:mapRect withKeywords:nil forFriends:Eng.preferences.selectedFriendIDs fromDate:nil toDate:nil withOrder:HOTNESS andNoOfResults:DEFAULTNOFRESUTLS];
    
    NSLog(@"Selected Map rect:");
    NSLog(@"North West coordinates Lat:%f Lng:%f",northWestCorner.latitude,northWestCorner.longitude);
    NSLog(@"South East coordinates Lat:%f Lng:%f",southEastCorner.latitude,southEastCorner.longitude);
}


-(void)gotPOIs:(NSArray*) poiList {
    
//    [self restoreNavigationColor];
    
    //Hide trending label
    if (isTrending)
        [self hideTrendsingLabel];
    
    self.title = L(SEARCH);
    self.trendingNowLabel.text = L(SHOWTRENDS);
    
    isTrending = NO;
    
    pointsOfInterest = poiList;
    [self updateMap];
}


#pragma mark - More View buttons

- (IBAction)closeMoreView:(id)sender {
    [self hideMoreView];
}

- (IBAction)editPOIBtnClicked:(UIButton*)sender {
    [self hideMoreView];
    [self editPOI:sender.tag];
}



#pragma mark - Navigation Color

-(void) makeNavigationRed {
    
    //Title color
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor redColor] forKey:NSForegroundColorAttributeName]];
    /*
    //Back button color
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    
    //Back button arrow color
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    self.navigationController.navigationBar.barTintColor = NAVIGATIONREDCOLOR;
     */
}


-(void) restoreNavigationColor {
    
    //Title color
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    /*
    //Back button color
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    
    //Back button arrow color
    [self.navigationController.navigationBar setTintColor:DEFAULTTINTCOLOR];
    
    self.navigationController.navigationBar.barTintColor = NAVCOLOR;
     */
}

@end
