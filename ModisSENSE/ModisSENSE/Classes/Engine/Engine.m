//
//  Engine.m
//  MoDisSence
//
//  Created by Panagiotis Kokkinakis on 4/12/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "Engine.h"

static Engine *_sharedInstance = nil;

@implementation Engine
@synthesize locationTracker;

+ (Engine *)sharedInstance {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[Engine alloc] init];
    });
    
    return _sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        //Initialize the Location Tracker
        locationTracker = [LocationTracker sharedInstance];
        
        //Initialize the api client
        self.apiClient = [[ApiClient alloc] init];
        
        //Initialize the user preferences
        self.preferences = [[UserPreferences alloc] init];
        
        //Initialize the user model
        self.user = [[User alloc] init];
        
    }
    
    return self;
}

// saves the engine state in persistent files in disk
- (void)saveState {

}

@end
