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


@interface ApiClient()
                       
@end


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
              self.serviceSucceeded=YES;
              success(operation, response);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              self.serviceSucceeded = NO;
              MyLog(@"%@", [error localizedDescription]);
//              completionBlock(FAILURE_RESPONSE(L(CONNECTIONERROR)));
              [SVProgressHUD showErrorWithStatus:L(CONNECTIONERROR)];
          }];
}

- (void)postMethod:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success onCompletion:(JSONResponseBlock)completionBlock {
    [self postPath:path
        parameters:parameters
           success:^(AFHTTPRequestOperation *operation, id response){
               self.serviceSucceeded=YES;
               success(operation, response);
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error){
               self.serviceSucceeded = NO;
               MyLog(@"%@", [error localizedDescription]);
//               completionBlock(FAILURE_RESPONSE(L(CONNECTIONERROR)));
               
               //Post is used here only for the logGPSTraces service. So we don't need the user to see if the service fails.
               //Sending GPR traces should be invisible to the user
//               [SVProgressHUD showErrorWithStatus:L(CONNECTIONERROR)];
               
               NSLog(@"CAUTION: GPS trace could not be sent !");
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
//ModisSENSE service calls

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



-(void)getFriendsForUser:(NSString*)userId showLoader:(BOOL)loader onSuccess:(JSONResponseBlock)successblock {
    
    if (loader)
        [SVProgressHUD showWithStatus:L(GETTINGFRIENDS) maskType:SVProgressHUDMaskTypeBlack];
    
//    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
//                                userId, TOKEN,
//                                JSON, FORMAT,
//                                nil];
    
    NSString* params = [NSString stringWithFormat:@"?%@=%@&%@=%@",TOKEN,Eng.user.userId,FORMAT,JSON];
    
    NSString *path = [GETFRIENDS stringByAppendingString:params];
    
    [self getMethod:path parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                if (loader)
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



-(void)deleteSocial:(NSString*)social fromUserId:(NSString*)userId onSuccess:(JSONResponseBlock)successblock {
    
    NSString* params;
    
    if (social==nil)
    {
        [SVProgressHUD showWithStatus:L(SIGNINGOUT) maskType:SVProgressHUDMaskTypeBlack];
        
        params = [NSString stringWithFormat:@"?%@=%@&%@=%@",TOKEN,Eng.user.userId,FORMAT,JSON];
    }
    else
    {
        [SVProgressHUD showWithStatus:L(REMOVINGACCOUNT) maskType:SVProgressHUDMaskTypeBlack];
        
        params = [NSString stringWithFormat:@"?%@=%@&%@=%@&%@=%@",TOKEN,Eng.user.userId,FORMAT,JSON,@"network",social];
    }
    
    NSString *path = [DELETE stringByAppendingString:params];
    
    [self getMethod:path parameters:nil
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
    
    NSString* x1 = [NSString stringWithFormat:@"%.15g",[(NSNumber*)[rectArea objectAtIndex:0] doubleValue]];
    NSString* y1 = [NSString stringWithFormat:@"%.15g",[(NSNumber*)[rectArea objectAtIndex:1] doubleValue]];
    NSString* x2 = [NSString stringWithFormat:@"%.15g",[(NSNumber*)[rectArea objectAtIndex:2] doubleValue]];
    NSString* y2 = [NSString stringWithFormat:@"%.15g",[(NSNumber*)[rectArea objectAtIndex:3] doubleValue]];
    
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


-(void)getTrendingPOISInArea:(NSArray*)area onSuccess:(JSONResponseBlock)successblock {
    
//    [SVProgressHUD showWithStatus:L(GETTINGTRENDS) maskType:SVProgressHUDMaskTypeBlack];
    
    NSString* x = [NSString stringWithFormat:@"%.15g",Eng.locationTracker.currentlocation.coordinate.latitude];
    NSString* y = [NSString stringWithFormat:@"%.15g",Eng.locationTracker.currentlocation.coordinate.longitude];
    
    NSString* x1 = [NSString stringWithFormat:@"%.15g",[(NSNumber*)[area objectAtIndex:0] doubleValue]];
    NSString* y1 = [NSString stringWithFormat:@"%.15g",[(NSNumber*)[area objectAtIndex:1] doubleValue]];
    NSString* x2 = [NSString stringWithFormat:@"%.15g",[(NSNumber*)[area objectAtIndex:2] doubleValue]];
    NSString* y2 = [NSString stringWithFormat:@"%.15g",[(NSNumber*)[area objectAtIndex:3] doubleValue]];
    
    NSString* params = [NSString stringWithFormat:@"?%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",TOKEN,Eng.user.userId,FORMAT,JSON,@"xpos",x,@"ypos",y,@"x1",x1,@"y1",y1,@"x2",x2,@"y2",y2];
    
    NSString* path = [TRENDS stringByAppendingString:params];
    
    [self getMethod:path parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
//                [SVProgressHUD dismiss];
                
                successblock(responseObject);
            }
       onCompletion:successblock];
}


-(void)addNewPOIWithName:(NSString*)name location:(CLLocation*)location publicity:(BOOL)publicity keywords:(NSArray*)keywords description:(NSString*)description onSuccess:(JSONResponseBlock)successblock {
    
    name = [name urlEncodeUsingEncoding:NSUTF8StringEncoding];
    description = [description urlEncodeUsingEncoding:NSUTF8StringEncoding];
    
    [SVProgressHUD showWithStatus:L(ADDINGNEWPOI) maskType:SVProgressHUDMaskTypeBlack];
    
    NSString* x = [NSString stringWithFormat:@"%.15g",location.coordinate.latitude];
    NSString* y = [NSString stringWithFormat:@"%.15g",location.coordinate.longitude];
    
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
    
    NSString *path = [ADDPOI stringByAppendingString:params];

    
    [self getMethod:path parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [SVProgressHUD dismiss];
                
                successblock(responseObject);
            }
       onCompletion:successblock];
}



-(void)getPOIDetails:(int)poiID onSuccess:(JSONResponseBlock)successblock {
    
    NSString* params = [NSString stringWithFormat:@"?%@=%@&%@=%@&%@=%d",TOKEN,Eng.user.userId,FORMAT,JSON,POIID,poiID];
    
    NSString *path = [GETPOIDETAILS stringByAppendingString:params];
    
    [self getMethod:path parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [SVProgressHUD dismiss];
                
                successblock(responseObject);
            }
       onCompletion:successblock];
    
}



-(void)editPOIWithID:(int)poiid name:(NSString*)name publicity:(BOOL)publicity keywords:(NSArray*)keywords description:(NSString*)description onSuccess:(JSONResponseBlock)successblock {
    
    [SVProgressHUD showWithStatus:L(UPDATINGPOI) maskType:SVProgressHUDMaskTypeBlack];
    
    name = [name urlEncodeUsingEncoding:NSUTF8StringEncoding];
    description = [description urlEncodeUsingEncoding:NSUTF8StringEncoding];
    
    NSString* poi_id = [NSString stringWithFormat:@"%d",poiid];
    
    NSString* publicityString;
    if (publicity)
        publicityString = @"true";
    else
        publicityString = @"false";
    
    NSString* keys = @"";
    if (![Util isNull:keywords] && keywords.count>0)
    {
        keys = [keys stringByAppendingString:[[keywords valueForKey:@"description"] componentsJoinedByString:@","]];
        keys = [keys urlEncodeUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSString* params = [NSString stringWithFormat:@"?%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",TOKEN,Eng.user.userId,FORMAT,JSON,NAMESMALL,name,POIID,poi_id,PUBLICITY,publicityString,KEYWORDS,keys,DESCRIPTION,description];
    
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



-(void)deletePOIWithID:(int)poiid onSuccess:(JSONResponseBlock)successblock {
    
    [SVProgressHUD showWithStatus:L(DELETINGPOI) maskType:SVProgressHUDMaskTypeBlack];
    
    NSString* poi_id = [NSString stringWithFormat:@"%d",poiid];
    
    NSString* params = [NSString stringWithFormat:@"?%@=%@&%@=%@&%@=%@",TOKEN,Eng.user.userId,FORMAT,JSON,POIID,poi_id];
    
    NSString *path = [DELETEPOI stringByAppendingString:params];
    
    [self getMethod:path parameters:nil
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
    
    NSString* path = GETBLOGS;
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                Eng.user.userId, TOKEN,
                                JSON, FORMAT,
                                nil];
    
    [self getMethod:path parameters:parameters
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                successblock(responseObject);
            }
       onCompletion:successblock];
}


-(void)getBlogForDate:(NSString*)date onSuccess:(JSONResponseBlock)successblock {
    
    [SVProgressHUD showWithStatus:L(GETTINGTRAJECTORY) maskType:SVProgressHUDMaskTypeBlack];
    
    NSString* params = [NSString stringWithFormat:@"?%@=%@&%@=%@&%@=%@",TOKEN,Eng.user.userId,FORMAT,JSON,DATE,date];
    
    NSString *path = [GETBLOG stringByAppendingString:params];
    
    [self getMethod:path parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [SVProgressHUD dismiss];
                
                successblock(responseObject);
            }
       onCompletion:successblock];
}


-(void)updateBlogPOIForDate:(NSString*)blogDate withPOIId:(int)poiid andDescription:(NSString*)description withStartDate:(NSString*)startDate andEndDate:(NSString*)endDate withSeqId:(int)currentSeqID moveToSeqId:(int)newSeqId shouldBeDeleted:(BOOL)del onSuccess:(JSONResponseBlock)successblock {
    
    [SVProgressHUD showWithStatus:L(UPDATINGBLOG) maskType:SVProgressHUDMaskTypeBlack];
    
//    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
//                                Eng.user.userId, TOKEN,
//                                JSON, FORMAT,
//                                blogDate, DATE,
//                                [NSNumber numberWithInt:poiid], @"poid",
//                                description, @"comment",
//                                startDate, @"arrived",
//                                endDate, @"off",
//                                [NSNumber numberWithInt:currentSeqID], @"seqid",
//                                [NSNumber numberWithInt:newSeqId], @"newseq",
//                                del, @"delete",
//                                nil];
    
    NSString* poi_id = [NSString stringWithFormat:@"%d",poiid];
    NSString* seqid = [NSString stringWithFormat:@"%d",currentSeqID];
    NSString* newseq = [NSString stringWithFormat:@"%d",newSeqId];
    
    if ([Util isEmptyString:description])
        description = @"";
    else
        description = [description urlEncodeUsingEncoding:NSUTF8StringEncoding];
    
    if ([Util isEmptyString:startDate])
        startDate = @"";
    else
        startDate = [startDate urlEncodeUsingEncoding:NSUTF8StringEncoding];
    
    if ([Util isEmptyString:endDate])
        endDate = @"";
    else
        endDate = [endDate urlEncodeUsingEncoding:NSUTF8StringEncoding];
    
    
    NSString* deleteString;
    if (del)
        deleteString=@"true";
    else
        deleteString=@"false";
    
    
    NSString* params;
    
    if ([description isEqualToString:@""] && [startDate isEqualToString:@""] && [endDate isEqualToString:@""])
    {
        params = [NSString stringWithFormat:@"?%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",TOKEN,Eng.user.userId,FORMAT,JSON,DATE,blogDate,@"poid",poi_id,@"seqid",seqid,@"newseq",newseq,@"delete",deleteString];
    }
    else
    {
        params = [NSString stringWithFormat:@"?%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",TOKEN,Eng.user.userId,FORMAT,JSON,DATE,blogDate,@"poid",poi_id,@"comment",description,@"arrived",startDate,@"off",endDate,@"seqid",seqid,@"newseq",newseq,@"delete",deleteString];
    }
    
    NSString *path = [UPDATEBLOG stringByAppendingString:params];
    
    [self getMethod:path parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [SVProgressHUD dismiss];
                
                successblock(responseObject);
            }
       onCompletion:successblock];
    
}

-(void)addNewVisitForBlogDate:(NSString*)blogdate withPOIId:(int)poiid toSeqPlace:(int)seqnum withstartDate:(NSString*)startDate andEndDate:(NSString*)endDate withComment:(NSString*)comment andPublicity:(BOOL)publicity onSuccess:(JSONResponseBlock)successblock {
    
    [SVProgressHUD showWithStatus:L(ADDINGNEWVISIT) maskType:SVProgressHUDMaskTypeBlack];
    
    NSString* poi_id = [NSString stringWithFormat:@"%d",poiid];
    NSString* newseqnum = [NSString stringWithFormat:@"%d",seqnum];
    
    if ([Util isEmptyString:comment])
        comment = @"";
    else
        comment = [comment urlEncodeUsingEncoding:NSUTF8StringEncoding];
    
    if ([Util isEmptyString:startDate])
        startDate = @"";
    else
        startDate = [startDate urlEncodeUsingEncoding:NSUTF8StringEncoding];
    
    if ([Util isEmptyString:endDate])
        endDate = @"";
    else
        endDate = [endDate urlEncodeUsingEncoding:NSUTF8StringEncoding];
    
    NSString* publicityString;
    if (publicity)
        publicityString = @"true";
    else
        publicityString = @"false";
    
    NSString* params = [NSString stringWithFormat:@"?%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",TOKEN,Eng.user.userId,FORMAT,JSON,DATE,blogdate,POIID,poi_id,@"comments",comment,@"arrived",startDate,@"off",endDate,@"seq_num",newseqnum,@"public",publicityString];
    
    
    NSString *path = [ADDNEWVISIT stringByAppendingString:params];
    
    [self getMethod:path parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [SVProgressHUD dismiss];
                
                successblock(responseObject);
            }
       onCompletion:successblock];
}



-(void)shareBlogToSocialMedia:(NSArray*)selectedMedia forDate:(NSString*)blogDate onSuccess:(JSONResponseBlock)successblock {
    
    [SVProgressHUD showWithStatus:L(SHARINGBLOG) maskType:SVProgressHUDMaskTypeBlack];
    
    NSString* selectedMediaString = @"";
    if (selectedMedia.count>1)
        selectedMediaString = [NSString stringWithFormat:@"&network=%@&network=%@",selectedMedia[0],selectedMedia[1]];
    else if (selectedMedia.count==1)
        selectedMediaString = [NSString stringWithFormat:@"&network=%@",selectedMedia[0]];
    else
        selectedMediaString = @"";
    
    NSString* params = [NSString stringWithFormat:@"?%@=%@&%@=%@%@",TOKEN, Eng.user.userId, DATE, blogDate,selectedMediaString];
    
    NSString *path = [SHAREBLOG stringByAppendingString:params];
    
    [self getMethod:path parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [SVProgressHUD dismiss];
                
                successblock(responseObject);
            }
       onCompletion:successblock];
}


-(void)retrieveGPSTraceForDate:(NSString*)blogDate onSuccess:(JSONResponseBlock)successblock {
    
    NSString* params = [NSString stringWithFormat:@"?%@=%@&%@=%@&%@=%@",TOKEN, Eng.user.userId, DATE, blogDate,FORMAT,JSON];
    
    NSString *path = [GETGPSTRACE stringByAppendingString:params];
    
    [self getMethod:path parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [SVProgressHUD dismiss];
                
                successblock(responseObject);
            }
       onCompletion:successblock];
}

@end
