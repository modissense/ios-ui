//
//  HomeViewController.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/12/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeSettingsViewController.h"
#import "PostToSocialViewController.h"
#import "POI.h"
#import "AddPOIViewController.h"
#import "Engine.h"
#import "Config.h"
#import "Util.h"
#import "EditPOIViewController.h"

@interface HomeViewController () {
    
    //Array of POI objects
    NSArray* pointsOfInterest;
    
    //Array of POI locations
    NSArray* gMapLocations;
    
    //This will store my previous location
    CLLocationCoordinate2D myPreviousLocation;
    
    //Line that will show up user's path on the map
    MKPolyline *polyline;
    
    NSDateFormatter* dateFormatter;
    
    UIView* info;
}

@end

@implementation HomeViewController

//Properties in MKOverlay protocol. Must be synthesized to supress warning.
@synthesize coordinate;
@synthesize boundingMapRect;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //For iOS7
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
        ADJUST_IOS7_LAYOUT
    
    self.title = L(NEARME);
    
    self.addLocation.text = L(ADD_RECORD);
    
    UIBarButtonItem* socialp = [[UIBarButtonItem alloc] initWithTitle:L(POST) style:UIBarButtonItemStylePlain target:self action:@selector(socialPost)];
    self.navigationItem.rightBarButtonItem = socialp;
    
    UIBarButtonItem* refreshBtn = [[UIBarButtonItem alloc] initWithTitle:L(REFRESH) style:UIBarButtonItemStylePlain target:self action:@selector(searchForPOIS)];
    self.navigationItem.leftBarButtonItem = refreshBtn;
    
    //Retrieve friends from service
    [self getFriends];
    
    // Set initial user preferences
    Eng.preferences.showCurrentLocation = YES;
    Eng.preferences.showPointsOfInterest = YES;
    
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
    
    [self setTabBarTitles];
    
    //Set delegate to self
    self.gMapView.gMapDelegate = self;
    
    /**************************************************/
    //TO BE DELETED
//    NSMutableArray* arr = [[NSMutableArray alloc] init];
//    POI* poi = [[POI alloc] init];
//    poi.name = @"Hard Rock Cafe";
//    poi.description = @"Get the fredoccino, it's awesome.";
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
    
    
    // Show current location according to preference
    if (Eng.preferences.showCurrentLocation)
    {
        self.gMapView.showsUserLocation = YES;
        
        // Show path line
        Eng.locationTracker.locationUpdateDelegate=self;
    }
    else
    {
        self.gMapView.showsUserLocation = NO;
        
        // Show path line
        Eng.locationTracker.locationUpdateDelegate=nil;
    }
    
    // Show favorites according to preference
    if (Eng.preferences.showPointsOfInterest)
    {
        //Show with pins
        [self.gMapView show:YES];
    }
    else
    {
        //Show without pins
        [self.gMapView show:NO];
    }
    
    
    //Set map zoom level
    MKCoordinateRegion region;
    region.center = Eng.locationTracker.currentlocation.coordinate;   // Current location
    MKCoordinateSpan span;
    span.latitudeDelta = 0.02;                                       // From 0.001 to 120
    span.longitudeDelta = 0.02;
    region.span=span;
    [self.gMapView setRegion:region animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Create locations array

-(NSArray *)createMapLocations {
    
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    
    if (!pointsOfInterest || pointsOfInterest.count == 0)
        return nil;
    
    
    for(int i = 0; i < pointsOfInterest.count; i++)
    {
        POI *p = [pointsOfInterest objectAtIndex:i];
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [[NSNumber alloc] initWithDouble:p.location.coordinate.latitude],    MAP_LATITUDE_KEY,
                              [[NSNumber alloc] initWithDouble:p.location.coordinate.longitude],   MAP_LONGITUDE_KEY,
                              p.name,                                                              MAP_CALLOUT_KEY,
                              p.description,                                                       MAP_CALLOUT_SUB_KEY,
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
    
    if (pointsOfInterest.count>0)
    {
        //Set an edit button as the right accessory view
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        rightButton.frame = CGRectMake(0.0, 0.0, 16.0, 16.0);
        [rightButton setImage:[UIImage imageNamed:@"pencil"] forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(editPOI:) forControlEvents:UIControlEventTouchUpInside];
        
        //Set a tag to the info button so we know what button was pressed
        rightButton.tag = [(MapAnnotation *)annotation tag];
        
        pinView.rightCalloutAccessoryView = rightButton;
        
        
        //Set the left accessory annotation view according to hotness or interest
        POI* poi = [pointsOfInterest objectAtIndex:rightButton.tag];
        
        UIImageView* leftView;
        
        if (poi.hotness > poi.interest)
            leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hot"]];
        else if (poi.hotness < poi.interest)
            leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"interesting"]];
        else
            leftView = nil;
        
        pinView.leftCalloutAccessoryView = leftView;
        
        //Green color
        pinView.pinColor = MKPinAnnotationColorGreen;
    }
    return pinView;
}



-(void)editPOI:(UIButton*)infoButton {
    
    POI* poi = [pointsOfInterest objectAtIndex:infoButton.tag];
    NSLog(@"Editing poi %d",infoButton.tag);
    
    EditPOIViewController* editVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EditPOIViewID"];
    editVC.nearMeMap = YES;
    editVC.name = poi.name;
    editVC.poiLocation = poi.location;
    editVC.keywords = poi.keywords;
    editVC.description = poi.description;
    [self.navigationController pushViewController:editVC animated:YES];
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
    
    CLLocationCoordinate2D coord[2];
    coord[0] = myPreviousLocation;
    coord[1] = Eng.locationTracker.currentlocation.coordinate;
    
    polyline = [MKPolyline polylineWithCoordinates:coord count:2];
    [self.gMapView addOverlay:polyline];
    
    myPreviousLocation = Eng.locationTracker.currentlocation.coordinate;
}

//Draw line between locations
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    
    MKPolylineView *polyLineView = [[MKPolylineView alloc] initWithPolyline:polyline];
    polyLineView.fillColor = [UIColor blueColor];
    polyLineView.strokeColor = [UIColor blueColor];
    polyLineView.lineWidth = 5;
    return polyLineView;
}


#pragma mark - Trace sent delegate

-(void) traceSent {
    [self showGPSTraceLog];
}


-(void) showGPSTraceLog {
    info = [[UIView alloc] initWithFrame:CGRectMake(self.gMapView.frame.size.width-124,60, 120,70)];
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
    
    
    [UIView animateWithDuration:1.0 animations:^{
        info.frame = CGRectMake(self.gMapView.frame.size.width-124,5,120,70);
    }];
    
    [UIView animateWithDuration:4.0 animations:^{
        info.layer.opacity = 0.0;
    }];
}



#pragma mark - Post to social clicked

-(void) socialPost {
    PostToSocialViewController *postvc =[self.storyboard instantiateViewControllerWithIdentifier:@"SocialPostViewID"];
    [self.navigationController pushViewController:postvc animated:YES];
}



#pragma mark - Map Settings action & delegate


- (IBAction)showMapSettings:(id)sender {
    
    UINavigationController *mapSettingsNav = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeSettingsNavID"];
    
    //Get the Settings View Controller
    HomeSettingsViewController *mapSettings = [mapSettingsNav.viewControllers objectAtIndex:0];
    mapSettings.delegate=self;
    
    mapSettingsNav.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    [self presentViewController:mapSettingsNav animated:YES completion:nil];
}


// Update the map (map settings delegate)
- (void)updateMap  {
    [self viewWillAppear:YES];
}



#pragma mark - Add a location clicked

- (IBAction)addNewPOIClicked:(id)sender {
    
    AddPOIViewController *vc =[self.storyboard instantiateViewControllerWithIdentifier:@"AddBlogRecordID"];
    [self.navigationController pushViewController:vc animated:YES];
}



#pragma mark - Search for POIs

-(void) searchForPOIS {
    
    if (Eng.preferences.selectedFriendIDs.count>0)
        [self getPOISBasedOnFriends];
    else
        [self getNearestNeighbours];
}



#pragma mark - Get friends call & delegate

- (void)getFriends {
    
    UserEngine* userEng = [[UserEngine alloc] init];
    userEng.delegate=self;
    [userEng getFriendsForUser:Eng.user.userId];
}

//Delegate
- (void)gotFriends {
    
    //We have user's friends
    //Now search for POIS
    [self searchForPOIS];
}




#pragma mark - Get nearest neighbours call & delegate

-(void) getNearestNeighbours {
    
    POIEngine* poiEngine = [[POIEngine alloc] init];
    poiEngine.delegate=self;
    [poiEngine getNearestNeighbours];
}


-(void) gotNearestNeighbours:(NSArray*) poiList {
    
    if (pointsOfInterest.count>0)
        pointsOfInterest = nil;
        
    pointsOfInterest = poiList;
    [self updateMap];
}


#pragma mark - Get POIS call & delegate

-(void) getPOISBasedOnFriends {
    CLLocationCoordinate2D northWestCorner;     //Upper left of the selected rect of the map
    CLLocationCoordinate2D southEastCorner;     //Down right of the selected rect of the map
    
    MKCoordinateRegion mapRegion = self.gMapView.region;
    northWestCorner.latitude  = mapRegion.center.latitude  - (mapRegion.span.latitudeDelta  / 2.0);
    northWestCorner.longitude = mapRegion.center.longitude - (mapRegion.span.longitudeDelta / 2.0);
    southEastCorner.latitude  = mapRegion.center.latitude  + (mapRegion.span.latitudeDelta  / 2.0);
    southEastCorner.longitude = mapRegion.center.longitude + (mapRegion.span.longitudeDelta / 2.0);
    
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
    
    if (pointsOfInterest.count>0)
        pointsOfInterest = nil;
    
    pointsOfInterest = poiList;
    [self updateMap];
}


@end
