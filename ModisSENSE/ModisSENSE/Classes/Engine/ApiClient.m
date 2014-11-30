//
//  ApiClient.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 6/20/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "ApiClient.h"
#import "Config.h"
#import "Engine.h"
#import "SVProgressHUD.h"
#import "Util.h"
#import "POI.h"


@implementation ApiClient

- (id)init {
    self = [super initWithBaseURL:[NSURL URLWithString:SERVICEHOST]];
	if (self) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        self.parameterEncoding = AFJSONParameterEncoding;
    }
    
    return self;
}

#pragma mark - Call method implementations
- (void)getMethod:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success onCompletion:(JSONResponseBlock)completionBlock {
    [self getPath:path
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id response){
              success(operation, response);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              MyLog(@"%@", [error localizedDescription]);
//              completionBlock(FAILURE_RESPONSE(L(CONNECTIONERROR)));
              [SVProgressHUD showErrorWithStatus:L(CONNECTIONERROR)];
          }];
}

- (void)postMethod:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success onCompletion:(JSONResponseBlock)completionBlock {
    [self postPath:path
        parameters:parameters
           success:^(AFHTTPRequestOperation *operation, id response){
               success(operation, response);
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error){
               MyLog(@"%@", [error localizedDescription]);
//               completionBlock(FAILURE_RESPONSE(L(CONNECTIONERROR)));
               [SVProgressHUD showErrorWithStatus:L(CONNECTIONERROR)];
           }];
}

- (void)putMethod:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success onCompletion:(JSONResponseBlock)completionBlock {
    [self putPath:path
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id response){
              success(operation, response);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
              MyLog(@"%@", [error localizedDescription]);
//              completionBlock(FAILURE_RESPONSE(L(CONNECTIONERROR)));
              [SVProgressHUD showErrorWithStatus:L(CONNECTIONERROR)];
          }];
}

- (void)deleteMethod:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success onCompletion:(JSONResponseBlock)completionBlock {
    [self deletePath:path
          parameters:parameters
             success:^(AFHTTPRequestOperation *operation, id response){
                 success(operation, response);
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error){
                 
                 MyLog(@"%@", [error localizedDescription]);
//                 completionBlock(FAILURE_RESPONSE(L(CONNECTIONERROR)));
                 [SVProgressHUD showErrorWithStatus:L(CONNECTIONERROR)];
             }];
}

/*****************************************************************************************************/
//ModiSENSE service calls

#pragma mark - User Management

-(void)connectWithSocialMedia:(NSString*)social userid:(NSString*)userId {
    
    NSString* params = [NSString stringWithFormat:@"?%@=%@&%@=%@&%@=%@",NETWORK,social,CALLBACK,SIGNINCALLBACK,TOKEN,userId];
    NSString *path = [SOCIALLOGINURL stringByAppendingString:params];
    
    MyLog(@"Authorizing %@",social);
    
    if ([userId isEqualToString:@"null"])
        MyLog(@"Connecting user..");
    else
        MyLog(@"Adding social media to user with token %@",userId);
    
    NSURL* url = [NSURL URLWithString:path];
    
    //Open safari and call it
    [[UIApplication sharedApplication] openURL:url];
}


-(void)getConnectedAccounts:(NSString*)userId onSuccess:(JSONResponseBlock)successblock {
    
    [SVProgressHUD showWithStatus:L(GETTINGACTIVEACCOUNTS) maskType:SVProgressHUDMaskTypeBlack];
    
    NSString *path = GETACTIVEACCOUNTS;
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                userId, TOKEN,
                                JSON, FORMAT,
                                nil];
    
    
    [self getMethod:path parameters:parameters
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [SVProgressHUD dismiss];

                successblock(responseObject);
            }
       onCompletion:successblock];
    
}



-(void)getFriendsForUser:(NSString*)userId onSuccess:(JSONResponseBlock)successblock {
    
    [SVProgressHUD showWithStatus:L(GETTINGFRIENDS) maskType:SVProgressHUDMaskTypeBlack];
    
    NSString *path = GETFRIENDS;
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                userId, TOKEN,
                                JSON, FORMAT,
                                nil];
    
    
    [self getMethod:path parameters:parameters
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [SVProgressHUD dismiss];
                
                successblock(responseObject);
            }
       onCompletion:successblock];
}


-(void)signOutUserId:(NSString*)userId onSuccess:(JSONResponseBlock)successblock {
    
    [SVProgressHUD showWithStatus:L(SIGNINGOUT) maskType:SVProgressHUDMaskTypeBlack];
    
    NSString *path = SIGNOUT;
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                userId, TOKEN,
                                JSON, FORMAT,
                                nil];
    
    [self getMethod:path parameters:parameters
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [SVProgressHUD dismiss];

                successblock(responseObject);
            }
       onCompletion:successblock];

}



#pragma mark - POI management


-(void)getNearestNeighboursonSuccess:(JSONResponseBlock)successblock {
    
    [SVProgressHUD showWithStatus:L(GETTINGNEARESTNEIGHBOURS) maskType:SVProgressHUDMaskTypeBlack];
    
    NSString* path = NEARESTNEIGHBOURS;
    
    NSNumber* latitude = [NSNumber numberWithDouble:Eng.locationTracker.currentlocation.coordinate.latitude];
    NSNumber* longitude = [NSNumber numberWithDouble:Eng.locationTracker.currentlocation.coordinate.longitude];
    NSNumber* nresults = [NSNumber numberWithInt:DEFAULTNOFRESUTLS];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                Eng.user.userId, TOKEN,
                                JSON, FORMAT,
                                latitude, @"lat",
                                longitude, @"lon",
                                nresults, @"k",
                                nil];
    
    [self getMethod:path parameters:parameters
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [SVProgressHUD dismiss];
                
                successblock(responseObject);
            }
       onCompletion:successblock];
}



-(void)getPOIsIn:(NSArray*)rectArea withKeywords:(NSArray*)keywords forFriends:(NSArray*)friends fromDate:(NSString*)from toDate:(NSString*)to withOrder:(NSString*)orderby andNoOfResults:(int)numberOfResuts onSuccess:(JSONResponseBlock)successblock {
    
    [SVProgressHUD showWithStatus:L(GETTINGPOIS) maskType:SVProgressHUDMaskTypeBlack];
    
    NSString* x1 = [NSString stringWithFormat:@"%f",[(NSNumber*)[rectArea objectAtIndex:0] doubleValue]];
    NSString* y1 = [NSString stringWithFormat:@"%f",[(NSNumber*)[rectArea objectAtIndex:1] doubleValue]];
    NSString* x2 = [NSString stringWithFormat:@"%f",[(NSNumber*)[rectArea objectAtIndex:2] doubleValue]];
    NSString* y2 = [NSString stringWithFormat:@"%f",[(NSNumber*)[rectArea objectAtIndex:3] doubleValue]];
    
    NSString* keys = @"";
    if (keywords.count>0)
    {
        keys = [keys stringByAppendingString:[[keywords valueForKey:@"description"] componentsJoinedByString:@","]];
        keys = [keys urlEncodeUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSString* frnds = @"";
    if (friends.count>0)
    {
        frnds = [frnds stringByAppendingString:[[friends valueForKey:@"description"] componentsJoinedByString:@","]];
    }
    
    if ([Util isEmptyString:from])
        from = @"";
    else
        from = [from urlEncodeUsingEncoding:NSUTF8StringEncoding];
    
    if ([Util isEmptyString:to])
        to = @"";
    else
        to = [to urlEncodeUsingEncoding:NSUTF8StringEncoding];
    
    NSString* params = [NSString stringWithFormat:@"?%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%d",TOKEN,Eng.user.userId,FORMAT,JSON,@"x1",x1,@"y1",y1,@"x2",x2,@"y2",y2,KEYWORDS,keys,FRIENDS,frnds,STARTTIME,from,ENDTIME,to,ORDERBY,orderby,NOFRESULTS,numberOfResuts];
    
    NSString *path = [GETPOIS stringByAppendingString:params];
    
    
    [self getMethod:path parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [SVProgressHUD dismiss];
                
                successblock(responseObject);
            }
       onCompletion:successblock];
}


-(void)addNewPOIWithName:(NSString*)name location:(CLLocation*)location publicity:(BOOL)publicity keywords:(NSArray*)keywords description:(NSString*)description onSuccess:(JSONResponseBlock)successblock {
    
    name = [name urlEncodeUsingEncoding:NSUTF8StringEncoding];
    description = [description urlEncodeUsingEncoding:NSUTF8StringEncoding];
    
    [SVProgressHUD showWithStatus:L(ADDINGNEWPOI) maskType:SVProgressHUDMaskTypeBlack];
    
    NSString* x = [NSString stringWithFormat:@"%f",location.coordinate.latitude];
    NSString* y = [NSString stringWithFormat:@"%f",location.coordinate.longitude];
    
    NSString* publicityString;
    if (publicity)
        publicityString = @"true";
    else
        publicityString = @"false";
    
    NSString* keys = @"";
    if (keywords.count>0)
    {
        keys = [keys stringByAppendingString:[[keywords valueForKey:@"description"] componentsJoinedByString:@","]];
        keys = [keys urlEncodeUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSString* params = [NSString stringWithFormat:@"?%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",TOKEN,Eng.user.userId,FORMAT,JSON,NAMESMALL,name,@"x",x,@"y",y,PUBLICITY,publicityString,KEYWORDS,keys,DESCRIPTION,description,TOKEN,Eng.user.userId];
    
    NSString *path = [ADDPOI stringByAppendingString:params];

    
    [self getMethod:path parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [SVProgressHUD dismiss];
                
                successblock(responseObject);
            }
       onCompletion:successblock];
}


-(void)editPOIWithName:(NSString*)name location:(CLLocation*)location publicity:(BOOL)publicity keywords:(NSArray*)keywords description:(NSString*)description onSuccess:(JSONResponseBlock)successblock {
    
    name = [name urlEncodeUsingEncoding:NSUTF8StringEncoding];
    description = [description urlEncodeUsingEncoding:NSUTF8StringEncoding];
    
    [SVProgressHUD showWithStatus:L(UPDATINGPOI) maskType:SVProgressHUDMaskTypeBlack];
    
    NSString* x = [NSString stringWithFormat:@"%f",location.coordinate.latitude];
    NSString* y = [NSString stringWithFormat:@"%f",location.coordinate.longitude];
    
    NSString* publicityString;
    if (publicity)
        publicityString = @"true";
    else
        publicityString = @"false";
    
    NSString* keys = @"";
    if (keywords.count>0)
    {
        keys = [keys stringByAppendingString:[[keywords valueForKey:@"description"] componentsJoinedByString:@","]];
        keys = [keys urlEncodeUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSString* params = [NSString stringWithFormat:@"?%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",TOKEN,Eng.user.userId,FORMAT,JSON,NAMESMALL,name,@"x",x,@"y",y,PUBLICITY,publicityString,KEYWORDS,keys,DESCRIPTION,description];
    
    NSString *path = [EDITPOI stringByAppendingString:params];
    
    
    [self getMethod:path parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [SVProgressHUD dismiss];
                
                successblock(responseObject);
            }
       onCompletion:successblock];
}


-(void)findDuplicatesInLocation:(CLLocation*)location onSuccess:(JSONResponseBlock)successblock {
    
    [SVProgressHUD showWithStatus:L(CHECKINGDUPLICATES) maskType:SVProgressHUDMaskTypeBlack];
    
    NSString* path = GETDUPLICATES;
    
    NSNumber* latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
    NSNumber* longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                Eng.user.userId, TOKEN,
                                JSON, FORMAT,
                                latitude, @"lat",
                                longitude, @"lon",
                                nil];
    
    [self getMethod:path parameters:parameters
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [SVProgressHUD dismiss];
                
                successblock(responseObject);
            }
       onCompletion:successblock];
}



-(void)deletePOIWithLocation:(CLLocation*)location onSuccess:(JSONResponseBlock)successblock {
    
    [SVProgressHUD showWithStatus:L(DELETINGPOI) maskType:SVProgressHUDMaskTypeBlack];
    
    NSString* path = DELETEPOI;
    
    NSNumber* latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
    NSNumber* longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                Eng.user.userId, TOKEN,
                                JSON, FORMAT,
                                latitude, @"x",
                                longitude, @"y",
                                nil];
    
    [self getMethod:path parameters:parameters
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [SVProgressHUD dismiss];
                
                successblock(responseObject);
            }
       onCompletion:successblock];
}


-(void)logGPSTraces:(NSArray*)traces onSuccess:(JSONResponseBlock)successblock {
    
    NSString* path = LOGGPSTRACES;
    
    NSMutableArray* tracesArray = [NSMutableArray array];
    
    for (POI* poi in traces)
    {
        NSDictionary *trace = [NSDictionary dictionaryWithObjectsAndKeys:
                                    Eng.user.userId, TOKEN,
                                    [NSNumber numberWithDouble:poi.location.coordinate.latitude], @"lat",
                                    [NSNumber numberWithDouble:poi.location.coordinate.longitude], @"lon",
                                    poi.timestamp, GPSTIMESTAMP,
                                    nil];
        
        [tracesArray addObject:trace];
    }
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:tracesArray forKey:TRACES];
    
    [self postMethod:path parameters:parameters
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                successblock(responseObject);
            }
       onCompletion:successblock];
}


#pragma mark - Blog Management


-(void)getBlogsOnSuccess:(JSONResponseBlock)successblock {
    
    [SVProgressHUD showWithStatus:L(GETTINGBLOGS) maskType:SVProgressHUDMaskTypeBlack];
    
    NSString* path = GETBLOGS;
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
//                                @"TxT7og9YtY48pjfu1G14hSMmon8zm9W7", TOKEN,
                                Eng.user.userId, TOKEN,
                                JSON, FORMAT,
                                nil];
    
    [self getMethod:path parameters:parameters
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [SVProgressHUD dismiss];
                
                successblock(responseObject);
            }
       onCompletion:successblock];
}


-(void)getBlogForDate:(NSString*)date onSuccess:(JSONResponseBlock)successblock {
    
    [SVProgressHUD showWithStatus:L(GETTINGTRAJECTORY) maskType:SVProgressHUDMaskTypeBlack];
    
    NSString* path = GETBLOG;
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
//                                @"TxT7og9YtY48pjfu1G14hSMmon8zm9W7", TOKEN,
                                Eng.user.userId, TOKEN,
                                JSON, FORMAT,
                                date,DATE,
                                nil];
    
    [self getMethod:path parameters:parameters
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [SVProgressHUD dismiss];
                
                successblock(responseObject);
            }
       onCompletion:successblock];
}

@end
