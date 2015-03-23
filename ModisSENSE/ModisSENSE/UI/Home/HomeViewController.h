//
//  HomeViewController.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/12/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClusterMapView.h"
#import "LocationTracker.h"
#import "POIEngine.h"
#import "UserEngine.h"
#import "EditPOIViewController.h"
#import "AddPOIViewController.h"
#import "UserSelectionViewController.h"
#import "POIDetailsView.h"

@interface HomeViewController : UIViewController <ClusterMapViewSelectionDelegate,ClusterMapViewDelegate,MKMapViewDelegate,LocationUpdatedDelegate,MKOverlay,UserEngineDelegate,POIEngineDelegate,EditPOIViewControllerDelegate,AddPOIViewControllerDelegate,UIActionSheetDelegate,UserSelectionDelegate>

@property (weak, nonatomic) IBOutlet ClusterMapView *gMapView;

//Trending now
@property (weak, nonatomic) IBOutlet UIView *trendingNowView;
@property (weak, nonatomic) IBOutlet UILabel *trendingNowLabel;
@property (weak, nonatomic) IBOutlet UIImageView *trendingNowImage;


//POI details view
@property (weak, nonatomic) IBOutlet POIDetailsView *poiDetailsView;

@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

- (IBAction)closeMoreView:(id)sender;
- (IBAction)editPOIBtnClicked:(id)sender;


@end
