//
//  POIEngine.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 8/30/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol POIEngineDelegate <NSObject>

@optional
-(void)gotPOIs:(NSArray*)poiList;
-(void)gotNearestNeighbours:(NSArray*)poiList;
-(void)gotDuplicates:(NSArray*)poiList;
-(void)traceSent;
-(void)poiAdded;
-(void)poiEdited;
-(void)poiDeleted;
@end

@interface POIEngine : NSObject

@property (nonatomic, weak) id <POIEngineDelegate> delegate;

-(void)getNearestNeighbours;
-(void)getPOIsIn:(NSArray*)rectArea withKeywords:(NSArray*)keywords forFriends:(NSArray*)friends fromDate:(NSString*)from toDate:(NSString*)to withOrder:(NSString*)orderby andNoOfResults:(int)numberOfResuts;
-(void)addNewPOIWithName:(NSString*)name location:(CLLocation*)location publicity:(BOOL)publicity keywords:(NSArray*)keywords andDescription:(NSString*)description;
-(void)editPOIWithName:(NSString*)name location:(CLLocation*)location publicity:(BOOL)publicity keywords:(NSArray*)keywords andDescription:(NSString*)description;
-(void)deletePOIWithLocation:(CLLocation*)location;
-(void)findDuplicatesInLocation:(CLLocation*)location;
-(void)logGPSTraces:(NSArray*)traces;

@end
