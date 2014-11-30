//
//  LocationTracker.h
//  MoDisSence
//
//  Created by Panagiotis Kokkinakis on 4/12/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Blog.h"
#import <CoreLocation/CoreLocation.h>
#import "POIEngine.h"

@protocol LocationUpdatedDelegate <NSObject>

@optional
-(void) locationUpdated;
-(void) traceSent;
@end


@interface LocationTracker : NSObject <CLLocationManagerDelegate,POIEngineDelegate> {
    Blog *iBlog;
    CLLocationManager *locationManager;
    CLLocation* lastVisitedLocation;
}

//Start - Stop location tracker
- (void)startLocationTracker: (NSString *)blogName;
- (void)stop;

//Manage blogs
- (Blog *)blogByName: (NSString *)blogName;
- (void)deleteBlog: (NSString *)blogName;
- (NSArray *)allBlogs;

//Access to our current location
@property (nonatomic,strong) CLLocation* currentlocation;
//Access to our previous location
@property (nonatomic,strong) CLLocation* previousLocation;
//Location update delegate
@property (nonatomic, weak) id <LocationUpdatedDelegate> locationUpdateDelegate;

@property (nonatomic,assign) int tracesSent;

+ (LocationTracker *)sharedInstance;

// convenience declaration to get the singleton instance
#define LocTrck [LocationTracker sharedInstance]

@end
