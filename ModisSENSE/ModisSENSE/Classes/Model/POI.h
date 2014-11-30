//
//  BlogRecord.h
//  MoDisSence
//
//  Created by Panagiotis Kokkinakis on 4/12/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface POI : NSObject <NSCoding>

@property (strong,nonatomic) NSString* poi_id;
@property (strong,nonatomic) NSString* name;
@property (strong,nonatomic) CLLocation* location;
@property (strong,nonatomic) NSString *timestamp;
@property (assign,nonatomic) int interest;
@property (assign,nonatomic) int hotness;
@property (assign,nonatomic) BOOL publicity;
@property (strong,nonatomic) NSArray* keywords;     //Array of keyword strings
@property (strong,nonatomic) NSString* description;

@property (strong,nonatomic) NSString *startDate;
@property (strong,nonatomic) NSString *endDate;

@end
