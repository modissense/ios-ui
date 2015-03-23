//
//  TrajectoryMapViewController.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 11/5/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMapView.h"
#import "POI.h"
#import "BlogEngine.h"

@interface TrajectoryMapViewController : UIViewController <GMapViewDelegate,BlogEngineDelegate>

//Array of POI objects
@property (strong,nonatomic) NSArray* pointsOfInterest;
@property (strong,nonatomic) NSString* blogDate;

@property (weak, nonatomic) IBOutlet GMapView *gMapView;

@end
