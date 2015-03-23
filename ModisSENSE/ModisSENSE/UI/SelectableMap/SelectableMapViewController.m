//
//  SelectableMapViewController.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 10/24/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "SelectableMapViewController.h"
#import "Engine.h"
#import "UIConstants.h"


@interface SelectableMapViewController () {
    
    //Array of POI locations
    NSArray* gMapLocations;
}

@end

@implementation SelectableMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //For ios7
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
        ADJUST_IOS7_LAYOUT
	
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:L(CANCEL) style:UIBarButtonItemStylePlain target:self action:@selector(closeModal)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem* addNewButton = [[UIBarButtonItem alloc] initWithTitle:L(ADDNEW) style:UIBarButtonItemStylePlain target:self action:@selector(addNew)];
    self.navigationItem.rightBarButtonItem = addNewButton;
    
    //For iOS7
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
        ADJUST_IOS7_LAYOUT
        
    self.title = L(DUPLICATEPOIS);
    
    //Set delegate to self
    self.gMapView.gMapDelegate = self;
    
    
    //Create map locations
    gMapLocations = [self createMapLocations];
    
    //Set them
    [self.gMapView setLocations:gMapLocations];
    
    //Show with pins
    [self.gMapView show];
    
    //Show info
    [self showInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) showInfo {
    UIView* info = [[UIView alloc] initWithFrame:CGRectMake(self.gMapView.frame.size.width-194,60, 190,90)];
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
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.textColor = [UIColor blackColor];
    infoLabel.font = [UIFont systemFontOfSize:13];
    
    infoLabel.text = L(SELECTABLEMAPINFO);
    
    [info addSubview:infoLabel];
    
    [self.gMapView addSubview: info];
    
    [UIView animateWithDuration:1.0 animations:^{
        info.frame = CGRectMake(self.gMapView.frame.size.width-194,5, 190,90);
    }];
    
    [UIView animateWithDuration:20.0 animations:^{
        info.layer.opacity = 0.0;
    }];
}



#pragma mark - Create locations array

-(NSArray *)createMapLocations {
    
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    
    if (!self.pointsOfInterest || self.pointsOfInterest.count == 0)
        return nil;
    
    POI *poi;
    
    NSString* name = poi.name;
    if (name.length > 19)
    {
        name = [NSString stringWithFormat:@"%@..", [name substringToIndex:17]];
    }
    
    for(int i = 0; i < self.pointsOfInterest.count; i++)
    {
        poi = [self.pointsOfInterest objectAtIndex:i];
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [[NSNumber alloc] initWithDouble:poi.location.coordinate.latitude],       MAP_LATITUDE_KEY,
                              [[NSNumber alloc] initWithDouble:poi.location.coordinate.longitude],      MAP_LONGITUDE_KEY,
                              name,                                                                     MAP_CALLOUT_KEY,
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
        //Set an info button to the right accessory view
        UIButton* rightSelectButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        rightSelectButton.frame = CGRectMake(0.0, 0.0, 16.0, 16.0);
        [rightSelectButton setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
        [rightSelectButton addTarget:self action:@selector(selectPOI:) forControlEvents:UIControlEventTouchUpInside];
        rightSelectButton.tag = [(MapAnnotation *)annotation tag];
        
        pinView.rightCalloutAccessoryView = rightSelectButton;
        
        pinView.pinColor = MKPinAnnotationColorGreen;
        
        /*
        pinView.image = [UIImage imageNamed:@"pinblue"];
        
        UILabel* number = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, 20, 10)];
        number.font = CELLFONTSMALL;
        number.textColor = [UIColor whiteColor];
        number.textAlignment = NSTextAlignmentCenter;
        number.text = [NSString stringWithFormat:@"%d",[(MapAnnotation *)annotation tag]];
        
        [pinView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
        [pinView addSubview:number];
         */
    }
    return pinView;
}



#pragma mark - Show pin info clicked

-(void)selectPOI:(UIButton*)infoButton {
    NSLog(@"Seelcted pin %d ",infoButton.tag);
    
    POI* poi = [self.pointsOfInterest objectAtIndex:infoButton.tag];
    
    [self dismissViewControllerAnimated:YES completion:
     ^{if (self.delegate && [self.delegate respondsToSelector:@selector(selectedPOIFromMap:)]) {
        [self.delegate selectedPOIFromMap:poi];
    }}];
}


#pragma mark - Add a new POI

-(void)addNew {
    [self dismissViewControllerAnimated:YES completion:
     ^{if (self.delegate && [self.delegate respondsToSelector:@selector(wantsNewPOI)]) {
        [self.delegate wantsNewPOI];
    }}];
}


#pragma mark - Close Modal

-(void)closeModal {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
