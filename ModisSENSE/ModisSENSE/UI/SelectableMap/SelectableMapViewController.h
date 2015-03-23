//
//  SelectableMapViewController.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 10/24/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMapView.h"
#import "POI.h"

@protocol SelectableMapViewControllerDelegate <NSObject>
@optional
-(void)selectedPOIFromMap:(POI*)poi;
-(void)wantsNewPOI;
@end


@interface SelectableMapViewController : UIViewController <GMapViewDelegate>

@property (nonatomic, weak) id <SelectableMapViewControllerDelegate> delegate;

//Array of POI objects
@property (strong,nonatomic) NSArray* pointsOfInterest;

@property (weak, nonatomic) IBOutlet GMapView *gMapView;

@end
