//
//  POIEngine.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 8/30/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "POI.h"
#import "POIDetails.h"

@protocol POIEngineDelegate <NSObject>

@optional
-(void)gotPOIs:(NSArray*)poiList;
-(void)gotNearestNeighbours:(NSArray*)poiList;
-(void)gotTrendingPOIs:(NSArray*)poiList;
-(void)gotDuplicates:(NSArray*)poiList;
-(void)traceSent;
-(void)poiAdded:(POI*)poi;
-(void)gotPOIDetails:(POIDetails*)poiDetails;
-(void)poiEdited;
-(void)poiDeleted;
@end

@interface POIEngine : NSObject

@property (nonatomic, weak) id <POIEngineDelegate> delegate;

-(void)getNearestNeighbours;
-(void)getPOIsIn:(NSArray*)rectArea withKeywords:(NSArray*)keywords forFriends:(NSArray*)friends fromDate:(NSString*)from toDate:(NSString*)to withOrder:(NSString*)orderby andNoOfResults:(int)numberOfResuts;
-(void)getTrendingPOISInArea:(NSArray*)area;
-(void)addNewPOIWithName:(NSString*)name location:(CLLocation*)location publicity:(BOOL)publicity keywords:(NSArray*)keywords andDescription:(NSString*)description;
-(void)getPOIDetails:(int)poiID;
-(void)editPOIWithID:(int)poiid name:(NSString*)name publicity:(BOOL)publicity keywords:(NSArray*)keywords description:(NSString*)description;
-(void)deletePOIWithID:(int)poiid;
-(void)findDuplicatesInLocation:(CLLocation*)location;
-(void)logGPSTraces:(NSArray*)traces;

@end
