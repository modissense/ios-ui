//
//  BlogEngine.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 9/24/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BlogEngineDelegate <NSObject>

@optional
-(void)gotBlogsWithDates:(NSArray*)dates;
-(void)gotPOISforBlogDate:(NSArray*)pois withStory:(NSString*)story;
-(void)blogUpdated;
-(void)visitAdded;
-(void)traceRetrieved:(NSArray*)locations;
@end


@interface BlogEngine : NSObject

@property (nonatomic, weak) id <BlogEngineDelegate> delegate;

-(void)getBlogs;
-(void)getBlogForDate:(NSString*)date;
-(void)updateBlogPOIForDate:(NSString*)blogDate withPOIId:(int)poiid andDescription:(NSString*)description withStartDate:(NSString*)startDate andEndDate:(NSString*)endDate withSeqId:(int)currentSeqID moveToSeqId:(int)newSeqId shouldBeDeleted:(BOOL)del;
-(void)addNewVisitForBlogDate:(NSString*)blogdate withPOIId:(int)poiid toSeqPlace:(int)seqnum withstartDate:(NSString*)startDate andEndDate:(NSString*)endDate withComment:(NSString*)comment andPublicity:(BOOL)publicity;
-(void)shareBlogToSocialMedia:(NSArray*)selectedMedia forDate:(NSString*)blogDate;
-(void)retrieveGPSTraceForDate:(NSString*)blogDate;

@end
