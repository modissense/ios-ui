//
//  HomeViewController.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/12/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMapView.h"
#import "HomeSettingsViewController.h"
#import "LocationTracker.h"
#import "POIEngine.h"

@interface HomeViewController : UIViewController <GMapViewDelegate,LocationUpdatedDelegate,MKOverlay,MapSettingsDelegate,UserEngineDelegate,POIEngineDelegate>


@property (weak, nonatomic) IBOutlet GMapView *gMapView;

- (IBAction)showMapSettings:(id)sender;
- (IBAction)addNewPOIClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *addLocation;
@end
