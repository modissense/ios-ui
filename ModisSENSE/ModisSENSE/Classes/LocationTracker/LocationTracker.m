//
//  LocationTracker.m
//  MoDisSENSE
//
//  Created by Panagiotis Kokkinakis on 4/12/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "LocationTracker.h"
#import <CoreLocation/CoreLocation.h>
#import "Config.h"
#import "POI.h"
#import "Util.h"
#import "UtilURL.h"
#import "Engine.h"

static LocationTracker *_sharedInstance = nil;

@implementation LocationTracker

//Init class with singleton
+ (LocationTracker *)sharedInstance {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[LocationTracker alloc] init];
    });
    
    return _sharedInstance;
}

#pragma mark - Tracker start stop
/*
 * Starts a new blog providing the blogName. If blogname already
 * exists data will append the existing ones
 */
- (void)startLocationTracker: (NSString *)blogName {
    //Start a new tracker only if no tracker is active
    if (!iBlog) {
        //Gets all available blogs from storage
        NSString *key = kSavedBlogsStorageKey;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSData *blogsData = [defaults objectForKey:key];
        NSMutableDictionary *blogs = [NSKeyedUnarchiver unarchiveObjectWithData:blogsData];
        
        if (blogs == nil) {
            blogs = [NSMutableDictionary dictionary];
        }
        
        //Searches to find if blogName already exists
        iBlog = [blogs objectForKey:blogName];

        //If iblog is still nil then init
        if (!iBlog) {
            iBlog = [[Blog alloc] init];
            iBlog.name = blogName;
        }
        
        //Remove all traces
//        [iBlog.POIS removeAllObjects];
        
        //Init location manager if not already initiated
        if (locationManager == nil) {
            locationManager = [[CLLocationManager alloc] init];
            
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kGPSAccuracyType;
            
            // Set a movement threshold for new events.
            locationManager.distanceFilter = kGPSDistanceFilter;
        }
        
        //Start monitoring
        [locationManager startUpdatingLocation];
    }
}

/*
 * Stops currently running tracker
 */
- (void)stop {
    //Stops a tracker only if tracker exists
    if (iBlog) {
        //Stops monitoring
        [locationManager stopUpdatingLocation];
        
        //Gets all available blogs from storage
        NSString *key = kSavedBlogsStorageKey;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
       
        NSData *blogsData = [defaults objectForKey:key];
        NSMutableDictionary *blogs = [NSKeyedUnarchiver unarchiveObjectWithData:blogsData];
        
        if (blogs == nil) {
            blogs = [NSMutableDictionary dictionary];
        }
        
        //Insert/update blog info
        [blogs setObject:iBlog forKey:iBlog.name];
        
        //Saves blogs back to storage
        NSData *saveData = [NSKeyedArchiver archivedDataWithRootObject:blogs];
        [defaults setObject:saveData forKey:key];
        [defaults synchronize];
        
        //Nils iBlog object
        iBlog = nil;
    }
}

#pragma mark - Manage blogs
/*
 * Returns a blog by blog name
 */
- (Blog *)blogByName: (NSString *)blogName {
    NSString *key = kSavedBlogsStorageKey;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSData *blogsData = [defaults objectForKey:key];
    NSMutableDictionary *blogs = [NSKeyedUnarchiver unarchiveObjectWithData:blogsData];
    
    if (blogs == nil) {
        blogs = [NSMutableDictionary dictionary];
    }

    return [blogs objectForKey:blogName];
}

/*
 * Deletes a block providing the blog name
 */
- (void)deleteBlog: (NSString *)blogName {
    NSString *key = kSavedBlogsStorageKey;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSData *blogsData = [defaults objectForKey:key];
    NSMutableDictionary *blogs = [NSKeyedUnarchiver unarchiveObjectWithData:blogsData];
    
    if (blogs == nil) {
        blogs = [NSMutableDictionary dictionary];
    }

    [blogs removeObjectForKey:blogName];
    
    //Saves blogs back to storage
    NSData *saveData = [NSKeyedArchiver archivedDataWithRootObject:blogs];
    [defaults setObject:saveData forKey:key];
    [defaults synchronize];
}

/*
 * Returns all saved blogs
 */
- (NSMutableDictionary *)allBlogs {
    NSString *key = kSavedBlogsStorageKey;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSData *blogsData = [defaults objectForKey:key];
    NSMutableDictionary *blogs = [NSKeyedUnarchiver unarchiveObjectWithData:blogsData];
    
    if (blogs == nil) {
        blogs = [NSMutableDictionary dictionary];
    }
    
    return blogs;
}


#pragma mark - LocationManager delegate
/*
 * Monitors user location changes and updates blog's records
 */
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    //Get current location
    CLLocation *newLocation = [locations lastObject];
    self.currentlocation = newLocation;
    
    //If location started just now, update last visited location and return
    if (!lastVisitedLocation) {
        lastVisitedLocation = newLocation;
        return;
    }
    
    //Time of the last location visit
    NSDate *lastVisitedLocationDate = lastVisitedLocation.timestamp;
    
    //How long did the user stayed at this location
    NSTimeInterval howLong = abs([lastVisitedLocationDate timeIntervalSinceNow]);
    
    //How far this location is for last visited location
    CLLocationDistance howFar = abs([newLocation distanceFromLocation:lastVisitedLocation]);
    
    NSLog(@"Stayed: %i seconds", abs(howLong));
    NSLog(@"Moved: %.02f meters", howFar);
    NSLog(@"Accuracy: %.02f meters", newLocation.horizontalAccuracy);
    NSLog(@"Accuracy: %.02f meters", newLocation.verticalAccuracy);
    
    //Check if previous location is a venue and should be added to venues list. To consider
    //a location as a venue howLong should be gte to a predefined value
    if (howLong >= kLocationShouldRemainTime && howFar >= kGPSDistanceFilter) {
        
        //Create POI (will be used as trace here)
        POI *poi = [[POI alloc] init];
        poi.location = newLocation;         //Change this to lastVisitedLocation if you're going to check how long he stayed in the last location (now kLocationShouldRemainTime = 0)
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [dateFormatter setDateFormat:@"yyy-MM-dd HH:mm:ss"];
        
        poi.timestamp = [dateFormatter stringFromDate:newLocation.timestamp];
        
        //Adds record to iBlog
        [iBlog.POIS addObject:poi];
        
        NSLog(@"Trace found at %f %f %@", poi.location.coordinate.latitude, poi.location.coordinate.longitude, poi.timestamp);
        
        //Send it to ModisSENSE server
        [self sendTrace];
    }
    
    //Reset last visited location
    lastVisitedLocation = newLocation;
    
    //Call our delegate so someone knows the location is updated
    if (self.locationUpdateDelegate && [self.locationUpdateDelegate respondsToSelector:@selector(locationUpdated)]) {
        [self.locationUpdateDelegate locationUpdated];
    }
}



#pragma mark - Trace call & delegate

-(void)sendTrace {
    if (Eng.user.connected && ![Util isEmptyString:Eng.user.userId] && !Eng.user.isInBackground)
    {
        //Send trace
        NSLog(@"Trying to send trace");
        POIEngine* poiEngine = [[POIEngine alloc] init];
        poiEngine.delegate = self;
        [poiEngine logGPSTraces:iBlog.POIS];
    }
}

-(void)traceSent {
    
    self.tracesSent = iBlog.POIS.count;
    
    //POIs are sent to the server, clear the storage
    [iBlog.POIS removeAllObjects];
    
    if (self.locationUpdateDelegate && [self.locationUpdateDelegate respondsToSelector:@selector(traceSent)]) {
        [self.locationUpdateDelegate traceSent];
    }
    
    NSLog(@"Trace(s) sent to the server! Memory cleared");
}

@end
