//
//  ApiClient.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 6/20/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "NSString+URLEncoding.h"


#define RESPONSE_STATUS_KEY         @"status"
#define RESPONSE_ERROR_KEY          @"error"
#define RESPONSE_ERROR_CODE_KEY     @"errorCode"
#define RESPONSE_RESULT_KEY         @"result"
#define RESPONSE_OK_KEY             @"Ok"
#define RESPONSE_ID_KEY             @"Id"

#define RESPONSE(status, error, errorCode, result) @{RESPONSE_STATUS_KEY : status, RESPONSE_ERROR_KEY : error, RESPONSE_ERROR_CODE_KEY : errorCode, RESPONSE_RESULT_KEY : result}
#define FAILURE_RESPONSE(error) RESPONSE(@NO, error, @11, @"")
#define SUCCESS_RESPONSE(result) RESPONSE(@YES, @"", @0, result)

//Pop to social web page to sign ing
#define SOCIALLOGINURL              @"http://snf-97398.vm.okeanos.grnet.gr/user/register"

//URL scheme callback
#define SIGNINCALLBACK              @"modissense://?signing=true"

//Query to be used at all times during calls
#define FORMAT                      @"format"
#define JSON                        @"json"

//Services URLs
//#define SERVICEHOST                 @"http://83.212.123.55"
#define SERVICEHOST                 @"http://snf-97398.vm.okeanos.grnet.gr"
#define GETACTIVEACCOUNTS           @"user/getnetworks"
#define GETFRIENDS                  @"user/userinfo"
#define SIGNOUT                     @"user/logout"
#define GETPOIS                     @"poi/getpois"
#define NEARESTNEIGHBOURS           @"poi/getnn"
#define ADDPOI                      @"poi/addnewpois"
#define EDITPOI                     @"poi/updatepoi"
#define DELETEPOI                   @"poi/deletepoi"
#define GETDUPLICATES               @"poi/findduplicates"
#define LOGGPSTRACES                @"poi/loggpstraces"
#define GETBLOGS                    @"user/blog/getblogs"
#define GETBLOG                     @"user/blog/getmicroblog"

//Connection call keys
#define NETWORK                     @"network"
#define USERID                      @"userid"
#define TOKEN                       @"token"
#define CALLBACK                    @"callback"
#define NETWORKS                    @"networks"
#define NETWORK                     @"network"
#define FRIENDS                     @"friends"
#define NAME                        @"Name"
#define NAMESMALL                   @"name"
#define RESULT                      @"result"
#define ID                          @"id"
#define POIID                       @"poi_id"
#define USER                        @"user"
#define USERNAME                    @"username"
#define CONNECTIONS                 @"connections"
#define KEYWORDS                    @"keywords"
#define FRIENDS                     @"friends"
#define ENDTIME                     @"etime"
#define STARTTIME                   @"stime"
#define ORDERBY                     @"orderby"
#define NOFRESULTS                  @"nresults"
#define POILIST                     @"poiList"
#define PUBLICITY                   @"publicity"
#define DESCRIPTION                 @"description"
#define TIMESTAMP                   @"tmstamp"
#define RESULT                      @"result"
#define GPSTIMESTAMP                @"timestamp"
#define TRACES                      @"traces"
#define DATE                        @"date"
#define BLOGS                       @"blogs"
#define BLOG                        @"blog"


//Interest & hotness of a POI
#define INTEREST                    @"interest"
#define HOTNESS                     @"hotness"

@interface ApiClient : AFHTTPClient

//User Management Calls
-(void)connectWithSocialMedia:(NSString*)social userid:(NSString*)userId;
-(void)getConnectedAccounts:(NSString*)userId onSuccess:(JSONResponseBlock)successblock;
-(void)getFriendsForUser:(NSString*)userId onSuccess:(JSONResponseBlock)successblock;
-(void)signOutUserId:(NSString*)userId onSuccess:(JSONResponseBlock)successblockd;

//POI Management Calls
-(void)getNearestNeighboursonSuccess:(JSONResponseBlock)successblock;
-(void)getPOIsIn:(NSArray*)rectArea withKeywords:(NSArray*)keywords forFriends:(NSArray*)friends fromDate:(NSString*)from toDate:(NSString*)to withOrder:(NSString*)orderby andNoOfResults:(int)numberOfResuts onSuccess:(JSONResponseBlock)successblock;
-(void)addNewPOIWithName:(NSString*)name location:(CLLocation*)location publicity:(BOOL)publicity keywords:(NSArray*)keywords description:(NSString*)description onSuccess:(JSONResponseBlock)successblock;
-(void)editPOIWithName:(NSString*)name location:(CLLocation*)location publicity:(BOOL)publicity keywords:(NSArray*)keywords description:(NSString*)description onSuccess:(JSONResponseBlock)successblock;
-(void)deletePOIWithLocation:(CLLocation*)location onSuccess:(JSONResponseBlock)successblock;
-(void)findDuplicatesInLocation:(CLLocation*)location onSuccess:(JSONResponseBlock)successblock;
-(void)logGPSTraces:(NSArray*)traces onSuccess:(JSONResponseBlock)successblock;

//Blog Management calls
-(void)getBlogsOnSuccess:(JSONResponseBlock)successblock;
-(void)getBlogForDate:(NSString*)date onSuccess:(JSONResponseBlock)successblock;

@end
