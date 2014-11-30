//
//  Engine.h
//  MoDisSence
//
//  Created by Panagiotis Kokkinakis on 4/12/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationTracker.h"
#import "UserPreferences.h"
#import "User.h"
#import "ApiClient.h"

@interface Engine : NSObject

@property (nonatomic, strong) LocationTracker *locationTracker;
@property (nonatomic, strong) ApiClient *apiClient;
@property (nonatomic, strong) UserPreferences *preferences;
@property (nonatomic, strong) User *user;

+ (Engine *)sharedInstance;

- (void)saveState;

// convenience declaration to get the singleton instance
#define Eng [Engine sharedInstance]

// convenience declaration to get translated strings
#define L(key) NSLocalizedString(@#key, nil)

@end
