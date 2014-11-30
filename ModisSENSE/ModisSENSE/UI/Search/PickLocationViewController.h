//
//  PickLocationViewController.h
//  Agrotypos
//
//  Created by mac1 on 11/8/12.
//  Copyright (c) 2012 mac1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMapView.h"
#import <MapKit/MapKit.h>

@protocol PickLocationViewControllerDelegate <NSObject>
@optional
- (void) didEndEditingWithCoordinates:(CLLocation *)coordinates;
- (void) didEndEditingWithRegion:(MKCoordinateRegion)region;
@end

@interface PickLocationViewController : UIViewController <MKMapViewDelegate> {
@private
    GMapView *iMapView;
    UIView* infoView;
}

@property (nonatomic, readonly) GMapView *mapView;

@property (strong,nonatomic) CLLocation* location;

@property (assign,nonatomic) BOOL showPin;

@property (weak) IBOutlet id<PickLocationViewControllerDelegate> delegate;

@end
