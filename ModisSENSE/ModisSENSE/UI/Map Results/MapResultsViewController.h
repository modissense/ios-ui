//
//  MapResultsViewController.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 9/4/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClusterMapView.h"
#import "EditPOIViewController.h"
#import "POIDetailsView.h"

@interface MapResultsViewController : UIViewController <ClusterMapViewSelectionDelegate,ClusterMapViewDelegate,MKMapViewDelegate,EditPOIViewControllerDelegate,UIActionSheetDelegate,POIEngineDelegate>

//Array of POI objects
@property (strong,nonatomic) NSArray* pointsOfInterest;

//Zoom area region
@property (assign,nonatomic) MKCoordinateRegion region;

@property (assign,nonatomic) BOOL notEditable;


@property (weak, nonatomic) IBOutlet ClusterMapView *gMapView;

//More view
//POI details view
@property (weak, nonatomic) IBOutlet POIDetailsView *poiDetailsView;

@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

- (IBAction)closeMoreView:(id)sender;
- (IBAction)editPOIBtnClicked:(id)sender;
@end
