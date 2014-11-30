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
#import "POI.h"
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
             
             POI* poi = [[POI alloc] init];
             poi.name = [poiObject objectForKey:NAMESMALL];
             
             NSNumber* lat = [poiObject objectForKey:@"x"];
             NSNumber* lng = [poiObject objectForKey:@"y"];
             
             poi.location = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lng doubleValue]];
             
             NSNumber* interest = [poiObject objectForKey:INTEREST];
             poi.interest = [interest intValue];
             NSNumber* hotness = [poiObject objectForKey:HOTNESS];
             poi.hotness = [hotness intValue];
             
             poi.publicity =  [[poiObject objectForKey:PUBLICITY] boolValue];
             
             NSArray* keywords = [poiObject objectForKey:KEYWORDS];
             poi.keywords = keywords;
             
             poi.description = [poiObject objectForKey:DESCRIPTION];
             
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
            
            if (poiList.count==0)
                [SVProgressHUD showImage:[UIImage imageNamed:@"location_service"] status:L(NOTHINGFOUND)];
            
            NSMutableArray* POIObjectList = [[NSMutableArray alloc] init];
            
            for ( int i=0 ; i<poiList.count ; i++)
            {
                NSDictionary* poiObject = [poiList objectAtIndex:i];
                
                POI* poi = [[POI alloc] init];
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
                
                poi.description = [poiObject objectForKey:DESCRIPTION];
                
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


-(void)addNewPOIWithName:(NSString*)name location:(CLLocation*)location publicity:(BOOL)publicity keywords:(NSArray*)keywords andDescription:(NSString*)description {
    
    [Eng.apiClient addNewPOIWithName:name location:location publicity:publicity keywords:keywords description:description
       onSuccess:^(NSDictionary* json){
           
           NSString* success = [json objectForKey:RESULT];
           
           if ([success isEqualToString:@"true"])
           {
               [SVProgressHUD showSuccessWithStatus:L(POIADDED)];
               
               //Call the delegate
               if (self.delegate && [self.delegate respondsToSelector:@selector(poiAdded)]) {
                   [self.delegate poiAdded];
               }
           }
           else
               [SVProgressHUD showErrorWithStatus:L(FAILED)];
           
       }];
}



-(void)editPOIWithName:(NSString*)name location:(CLLocation*)location publicity:(BOOL)publicity keywords:(NSArray*)keywords andDescription:(NSString*)description {
    
    [Eng.apiClient editPOIWithName:name location:location publicity:publicity keywords:keywords description:description
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
               [SVProgressHUD showErrorWithStatus:L(NOTAUTHORIZEDFORTHISACTION)];
           
       }];
}


-(void)deletePOIWithLocation:(CLLocation*)location {
    
    [Eng.apiClient deletePOIWithLocation:location
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
                 [SVProgressHUD showErrorWithStatus:L(NOTAUTHORIZEDFORTHISACTION)];
             
         }];
}


-(void)findDuplicatesInLocation:(CLLocation*)location {
    
    [Eng.apiClient findDuplicatesInLocation:location
        onSuccess:^(NSDictionary* json){
        
            //Array of POI objects
            NSArray* poiList = [json objectForKey:POILIST];
            
            if (poiList.count==0)
                [SVProgressHUD showImage:[UIImage imageNamed:@"location_service"] status:L(NOTHINGFOUND)];
            
            NSMutableArray* POIObjectList = [[NSMutableArray alloc] init];
            
            for ( int i=0 ; i<poiList.count ; i++)
            {
                NSDictionary* poiObject = [poiList objectAtIndex:i];
                
                POI* poi = [[POI alloc] init];
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
                
                poi.description = [poiObject objectForKey:DESCRIPTION];
                
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
