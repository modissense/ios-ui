//
//  Config.h
//  MoDisSence
//
//  Created by Panagiotis Kokkinakis on 4/12/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#define IS_PHONE5() ([UIScreen mainScreen].bounds.size.height == 568.0f && [UIScreen mainScreen].scale == 2.f && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define kSavedBlogsStorageKey       @"SAVED BLOGS"
#define TRACINGBLOG                 @"TracingBlog"
#define kGPSAccuracyType            kCLLocationAccuracyHundredMeters
#define kGPSDistanceFilter          30.0              //30 meters
//#define kLocationShouldRemainTime   10 * 60.0       //10 minutes
#define kLocationShouldRemainTime   0


#define DEFAULTNOFRESUTLS           50

//Social Media
#define TWITTER                     @"twitter"
#define FACEBOOK                    @"facebook"
#define FOURSQUARE                  @"foursquare"
