//
//  POIEngine.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 8/30/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "POIEngine.h"
#import "Engine.h"
#import "SVProgressHUD.h"
#import "Util.h"

@implementation POIEngine


-(void)getNearestNeighbours {
    
    [Eng.apiClient getNearestNeighboursonSuccess:^(NSDictionary* json)
     {
         //Array of POI objects
         NSArray* poiList = [json objectForKey:POILIST];
         
         if (poiList.count==0)
             [SVProgressHUD showImage:[UIImage imageNamed:@"location_service"] status:L(NOTHINGFOUND)];
         
         NSMutableArray* POIObjectList = [[NSMutableArray alloc] init];
         
         for ( int i=0 ; i<poiList.count ; i++)
         {
             NSDictionary* poiObject = [poiList objectAtIndex:i];
             
             /***************/
             //Check if it's a valid geographic location and not trash pois
             if ([[poiObject objectForKey:@"x"] floatValue]<-90 ||
                 [[poiObject objectForKey:@"x"] floatValue]>90 ||
                 [[poiObject objectForKey:@"y"] floatValue]<-180 ||
                 [[poiObject objectForKey:@"y"] floatValue]>180)
                 continue;
             /***************/
             
             POI* poi = [[POI alloc] init];
             
             poi.poi_id = [[poiObject objectForKey:POIID] intValue];
             poi.name = [poiObject objectForKey:NAMESMALL];
             
             NSString* lat = [poiObject objectForKey:@"x"];
             NSString* lng = [poiObject objectForKey:@"y"];
             
             poi.location = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lng doubleValue]];
             
             NSNumber* interest = [poiObject objectForKey:INTEREST];
             poi.interest = [interest intValue];
             NSNumber* hotness = [poiObject objectForKey:HOTNESS];
             poi.hotness = [hotness intValue];
             
             poi.publicity =  [[poiObject objectForKey:PUBLICITY] boolValue];
             
             poi.isMine =  [[poiObject objectForKey:ISMINE] boolValue];
             
             NSArray* keywords = [poiObject objectForKey:KEYWORDS];
             poi.keywords = keywords;
             
             poi.comment = [poiObject objectForKey:DESCRIPTION];
             
             poi.timestamp = [poiObject objectForKey:TIMESTAMP];
             
             //Add POI to the poi list for the delegate
             [POIObjectList addObject:poi];
         }
         
         //Call the delegate
         if (self.delegate && [self.delegate respondsToSelector:@selector(gotNearestNeighbours:)])
             [self.delegate gotNearestNeighbours:POIObjectList];
     }];
}


-(void)getPOIsIn:(NSArray*)rectArea withKeywords:(NSArray*)keywords forFriends:(NSArray*)friends fromDate:(NSString*)from toDate:(NSString*)to withOrder:(NSString*)orderby andNoOfResults:(int)numberOfResuts {
    
    [Eng.apiClient getPOIsIn:rectArea withKeywords:keywords forFriends:friends fromDate:from toDate:to withOrder:orderby andNoOfResults:numberOfResuts
        onSuccess:^(NSDictionary* json){
            
            //Array of POI objects
            NSArray* poiList = [json objectForKey:POILIST];
            
            NSMutableArray* POIObjectList = [[NSMutableArray alloc] init];
            
            for ( int i=0 ; i<poiList.count ; i++)
            {
                NSDictionary* poiObject = [poiList objectAtIndex:i];
                
                /***************/
                //Check if it's a valid geographic location and not trash pois
                if ([[poiObject objectForKey:@"x"] floatValue]<-90 ||
                    [[poiObject objectForKey:@"x"] floatValue]>90 ||
                    [[poiObject objectForKey:@"y"] floatValue]<-180 ||
                    [[poiObject objectForKey:@"y"] floatValue]>180)
                    continue;
                /***************/
                
                
                POI* poi = [[POI alloc] init];
                
                poi.poi_id = [[poiObject objectForKey:POIID] intValue];
                poi.name = [poiObject objectForKey:NAMESMALL];
                
                NSNumber* lat = [poiObject objectForKey:@"x"];
                NSNumber* lng = [poiObject objectForKey:@"y"];
                
                CLLocation* loc = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lng doubleValue]];
                poi.location = loc;
                
                NSNumber* interest = [poiObject objectForKey:INTEREST];
                poi.interest = [interest intValue];
                NSNumber* hotness = [poiObject objectForKey:HOTNESS];
                poi.hotness = [hotness intValue];
                
                poi.publicity = [[poiObject objectForKey:PUBLICITY] boolValue];
                
                poi.isMine =  [[poiObject objectForKey:ISMINE] boolValue];
                
                NSArray* keywords = [poiObject objectForKey:KEYWORDS];
                poi.keywords = keywords;
                
                poi.comment = [poiObject objectForKey:DESCRIPTION];
                
                poi.timestamp = [poiObject objectForKey:TIMESTAMP];
                
                
                //Add POI to the poi list for the delegate
                [POIObjectList addObject:poi];
            }
            
            //Call the delegate
            if (self.delegate && [self.delegate respondsToSelector:@selector(gotPOIs:)]) {
                [self.delegate gotPOIs:POIObjectList];
            }
        }];
}


-(void)getTrendingPOISInArea:(NSArray*)area {
    
    [Eng.apiClient getTrendingPOISInArea:area onSuccess:^(NSDictionary* json)
     {
         //Array of POI objects
         NSArray* poiList = [json objectForKey:POILIST];
         
         NSMutableArray* POIObjectList = [[NSMutableArray alloc] init];
         
         for ( int i=0 ; i<poiList.count ; i++)
         {
             NSDictionary* poiObject = [poiList objectAtIndex:i];
             
             /***************/
             //Check if it's a valid geographic location and not trash pois
             if ([[poiObject objectForKey:@"x"] floatValue]<-90 ||
                 [[poiObject objectForKey:@"x"] floatValue]>90 ||
                 [[poiObject objectForKey:@"y"] floatValue]<-180 ||
                 [[poiObject objectForKey:@"y"] floatValue]>180)
                 continue;
             /***************/
             
             POI* poi = [[POI alloc] init];
             
             poi.poi_id = [[poiObject objectForKey:POIID] intValue];
             poi.name = [poiObject objectForKey:NAMESMALL];
             
             NSString* lat = [poiObject objectForKey:@"x"];
             NSString* lng = [poiObject objectForKey:@"y"];
             
             poi.location = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lng doubleValue]];
             
             NSNumber* interest = [poiObject objectForKey:INTEREST];
             poi.interest = [interest intValue];
             NSNumber* hotness = [poiObject objectForKey:HOTNESS];
             poi.hotness = [hotness intValue];
             
             poi.publicity =  [[poiObject objectForKey:PUBLICITY] boolValue];
             
             poi.isMine =  [[poiObject objectForKey:ISMINE] boolValue];
             
             NSArray* keywords = [poiObject objectForKey:KEYWORDS];
             poi.keywords = keywords;
             
             poi.comment = [poiObject objectForKey:DESCRIPTION];
             
             poi.timestamp = [poiObject objectForKey:TIMESTAMP];
             
             //Add POI to the poi list for the delegate
             [POIObjectList addObject:poi];
         }
         
         //Call the delegate
         if (self.delegate && [self.delegate respondsToSelector:@selector(gotTrendingPOIs:)])
             [self.delegate gotTrendingPOIs:POIObjectList];
     }];
}


-(void)addNewPOIWithName:(NSString*)name location:(CLLocation*)location publicity:(BOOL)publicity keywords:(NSArray*)keywords andDescription:(NSString*)description {
    
    [Eng.apiClient addNewPOIWithName:name location:location publicity:publicity keywords:keywords description:description
       onSuccess:^(NSDictionary* json){
           
           NSString* success = [json objectForKey:RESULT];
           
           if (![success isEqualToString:@"false"])
           {
               //Get added POI
               
               POI* poi = [[POI alloc] init];
               
               poi.poi_id = [[json objectForKey:POIID] intValue];
               poi.name = [json objectForKey:NAMESMALL];
               
               NSNumber* lat = [json objectForKey:@"x"];
               NSNumber* lng = [json objectForKey:@"y"];
               
               CLLocation* loc = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lng doubleValue]];
               poi.location = loc;
               
               NSNumber* interest = [json objectForKey:INTEREST];
               poi.interest = [interest intValue];
               NSNumber* hotness = [json objectForKey:HOTNESS];
               poi.hotness = [hotness intValue];
               
               poi.publicity = [[json objectForKey:PUBLICITY] boolValue];
               
               poi.isMine =  [[json objectForKey:ISMINE] boolValue];
               
               NSArray* keywords = [json objectForKey:KEYWORDS];
               poi.keywords = keywords;
               
               poi.comment = [json objectForKey:DESCRIPTION];
               
               
               [SVProgressHUD showSuccessWithStatus:L(POIADDED)];
               
               //Call the delegate
               if (self.delegate && [self.delegate respondsToSelector:@selector(poiAdded:)]) {
                   [self.delegate poiAdded:poi];
               }
           }
           else
               [SVProgressHUD showErrorWithStatus:L(FAILED)];
           
       }];
}



-(void)getPOIDetails:(int)poiID {
    
    [Eng.apiClient getPOIDetails:poiID onSuccess:^(NSDictionary* json){
        
        //Initialize poi details object
        POIDetails* poiDetails = [[POIDetails alloc] init];
        
        poiDetails.poiID = [[json objectForKey:@"id"] intValue];
        
        //General info
        poiDetails.generalHotness = [[json objectForKey:@"hotness"] floatValue];
        poiDetails.generalInterest = [[json objectForKey:@"interest"] floatValue];
        
        poiDetails.poiImageURL = [json objectForKey:@"image"];
        
        poiDetails.poiName = [json objectForKey:@"name"];
        
        poiDetails.numberOfComments = [[json objectForKey:@"number_of_comments"] intValue];
        
        //Personalized
        NSDictionary* personalized = [json objectForKey:@"personalized"];
        
        poiDetails.personalizedHotness = [[personalized objectForKey:@"hotness"] floatValue];
        poiDetails.personalizedInterest = [[personalized objectForKey:@"interest"] floatValue];
        
        NSDictionary* comment = [personalized objectForKey:@"comment"];
        
        poiDetails.userNameComment = [comment objectForKey:@"user"];
        poiDetails.userImageCommentURL = [comment objectForKey:@"user_picture"];
        poiDetails.userComment = [comment objectForKey:@"text"];
        
        //Call the delegate
        if (self.delegate && [self.delegate respondsToSelector:@selector(gotPOIDetails:)]) {
            [self.delegate gotPOIDetails:poiDetails];
        }
        
    }];
}


-(void)editPOIWithID:(int)poiid name:(NSString*)name publicity:(BOOL)publicity keywords:(NSArray*)keywords description:(NSString*)description {
    
    [Eng.apiClient editPOIWithID:poiid name:name publicity:publicity keywords:keywords description:description
       onSuccess:^(NSDictionary* json){
           
           NSString* success = [json objectForKey:RESULT];
           
           if ([success isEqualToString:@"true"])
           {
               [SVProgressHUD showSuccessWithStatus:L(POIUPDATED)];
               
               //Call the delegate
               if (self.delegate && [self.delegate respondsToSelector:@selector(poiEdited)]) {
                   [self.delegate poiEdited];
               }
           }
           else
               [SVProgressHUD showErrorWithStatus:L(FAILED)];
           
       }];
}


-(void)deletePOIWithID:(int)poiid {
    
    [Eng.apiClient deletePOIWithID:poiid
         onSuccess:^(NSDictionary* json){
             
             NSString* success = [json objectForKey:RESULT];
             
             if ([success isEqualToString:@"true"])
             {
                 [SVProgressHUD showSuccessWithStatus:L(POIDELETED)];
                
                 //Call the delegate
                 if (self.delegate && [self.delegate respondsToSelector:@selector(poiDeleted)]) {
                     [self.delegate poiDeleted];
                 }
             }
             else
                 [SVProgressHUD showErrorWithStatus:L(NOTOWNINGPOI)];
             
         }];
}


-(void)findDuplicatesInLocation:(CLLocation*)location {
    
    [Eng.apiClient findDuplicatesInLocation:location
        onSuccess:^(NSDictionary* json){
        
            //Array of POI objects
            NSArray* poiList = [json objectForKey:POILIST];
            
//            if (poiList.count==0)
//                [SVProgressHUD showImage:[UIImage imageNamed:@"location_service"] status:L(NOTHINGFOUND)];
            
            NSMutableArray* POIObjectList = [[NSMutableArray alloc] init];
            
            for ( int i=0 ; i<poiList.count ; i++)
            {
                NSDictionary* poiObject = [poiList objectAtIndex:i];
                
                POI* poi = [[POI alloc] init];
                
                poi.poi_id = [[poiObject objectForKey:POIID] longValue];
                poi.name = [poiObject objectForKey:NAMESMALL];
                
                NSNumber* lat = [poiObject objectForKey:@"x"];
                NSNumber* lng = [poiObject objectForKey:@"y"];
                
                CLLocation* loc = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lng doubleValue]];
                poi.location = loc;
                
                NSNumber* interest = [poiObject objectForKey:INTEREST];
                poi.interest = [interest intValue];
                NSNumber* hotness = [poiObject objectForKey:HOTNESS];
                poi.hotness = [hotness intValue];
                
                poi.publicity = [[poiObject objectForKey:PUBLICITY] boolValue];
                
                NSArray* keywords = [poiObject objectForKey:KEYWORDS];
                poi.keywords = keywords;
                
                poi.comment = [poiObject objectForKey:DESCRIPTION];
                
                poi.timestamp = [poiObject objectForKey:TIMESTAMP];
                
                
                //Add POI to the poi list for the delegate
                [POIObjectList addObject:poi];
            }
            
            //Call the delegate
            if (self.delegate && [self.delegate respondsToSelector:@selector(gotDuplicates:)]) {
                [self.delegate gotDuplicates:POIObjectList];
            }
        
        }];
}



-(void)logGPSTraces:(NSArray*)traces {
 
    [Eng.apiClient logGPSTraces:traces
        onSuccess:^(NSDictionary* json){
        
            NSString* success = [json objectForKey:RESULT];
            
            if ([success isEqualToString:@"true"])
            {
                if (self.delegate && [self.delegate respondsToSelector:@selector(traceSent)]) {
                    [self.delegate traceSent];
                }
            }
    
    }];
}

@end
