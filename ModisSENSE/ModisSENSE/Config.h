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

#define kGPSAccuracyType            kCLLocationAccuracyNearestTenMeters
#define kGPSDistanceFilter          10.0              //10 meters
//#define kLocationShouldRemainTime   10 * 60.0       //10 minutes
#define kLocationShouldRemainTime   0


#define DEFAULTNOFRESUTLS           20

//Social Media
#define TWITTER                     @"twitter"
#define FACEBOOK                    @"facebook"
#define FOURSQUARE                  @"foursquare"

/****************/
//Contact e-mail
#define CONTACTEMAIL                @"contact@mail.modissense.gr"
/****************/
