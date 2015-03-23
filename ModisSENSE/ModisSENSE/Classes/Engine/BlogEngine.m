//
//  BlogEngine.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 9/24/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "BlogEngine.h"
#import "Engine.h"
#import "SVProgressHUD.h"
#import "POI.h"
#import "Util.h"
#import "Config.h"

@implementation BlogEngine


-(void)getBlogs {
    
    [Eng.apiClient getBlogsOnSuccess:^(NSDictionary* json)
     {
         //This will hold the blog dates (strings)
         NSMutableArray* blogDates = [NSMutableArray array];
         
         NSArray* blogs = [json objectForKey:BLOGS];
         
         for (int i=0 ; i<blogs.count ; i++)
         {
             NSDictionary* dateObject = [blogs objectAtIndex:i];
             NSString* date = [dateObject objectForKey:DATE];
             
             //Add it to our array
             [blogDates addObject:date];
         }
         
         //Call the delegate
         if (self.delegate && [self.delegate respondsToSelector:@selector(gotBlogsWithDates:)])
             [self.delegate gotBlogsWithDates:blogDates];
     }];
    
}


-(void)getBlogForDate:(NSString*)date {
    
    [Eng.apiClient getBlogForDate:date
        onSuccess:^(NSDictionary* json){
        
            //This will hold the blog POIs (POI objects)
            NSMutableArray* poiList = [NSMutableArray array];
            
            NSArray* blog = [json objectForKey:BLOG];
            
//            if (blog.count==0)
//                [SVProgressHUD showImage:[UIImage imageNamed:@"location_service"] status:L(NOTHINGFOUND)];
            
            for (int i=0 ; i<blog.count ; i++)
            {
                NSDictionary* poiResponse = [blog objectAtIndex:i];
                POI* poi = [[POI alloc] init];
                
                poi.seqid = [[poiResponse objectForKey:SEQID] intValue];
                poi.startDate = [poiResponse objectForKey:@"start"];
                poi.endDate = [poiResponse objectForKey:@"end"];
                poi.poi_id = [[poiResponse objectForKey:@"poi_id"] intValue];
                poi.name = [poiResponse objectForKey:@"name"];
                
                NSString* lat = [poiResponse objectForKey:@"lat"];
                NSString* lng = [poiResponse objectForKey:@"long"];
                
                CLLocation* loc = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lng doubleValue]];
                poi.location = loc;
                
                poi.comment = [poiResponse objectForKey:@"comment"];
                poi.publicity = [[poiResponse objectForKey:@"publicity"] boolValue];
                poi.interest = [[poiResponse objectForKey:@"interest"] intValue];
                poi.hotness = [[poiResponse objectForKey:@"hotness"] intValue];
                
                NSArray* keywords = [poiResponse objectForKey:KEYWORDS];
                poi.keywords = keywords;
                
                [poiList addObject:poi];
            }
            
            NSString* story = [json objectForKey:DESCRIPTION];
            
            //Call the delegate
            if (self.delegate && [self.delegate respondsToSelector:@selector(gotPOISforBlogDate:withStory:)])
                [self.delegate gotPOISforBlogDate:poiList withStory:story];
    }];
}



-(void)updateBlogPOIForDate:(NSString*)blogDate withPOIId:(int)poiid andDescription:(NSString*)description withStartDate:(NSString*)startDate andEndDate:(NSString*)endDate withSeqId:(int)currentSeqID moveToSeqId:(int)newSeqId shouldBeDeleted:(BOOL)del {
    
    [Eng.apiClient updateBlogPOIForDate:blogDate withPOIId:poiid andDescription:description withStartDate:startDate andEndDate:endDate withSeqId:currentSeqID moveToSeqId:newSeqId shouldBeDeleted:del onSuccess:^(NSDictionary* json){
        
        
        NSString* success = [json objectForKey:RESULT];
        
        if ([success isEqualToString:@"true"])
            [SVProgressHUD showSuccessWithStatus:L(UPDATED)];
        else
            [SVProgressHUD showErrorWithStatus:L(FAILED)];
        
        //Call the delegate
        if (self.delegate && [self.delegate respondsToSelector:@selector(blogUpdated)])
            [self.delegate blogUpdated];
    }];
}


-(void)addNewVisitForBlogDate:(NSString*)blogdate withPOIId:(int)poiid toSeqPlace:(int)seqnum withstartDate:(NSString*)startDate andEndDate:(NSString*)endDate withComment:(NSString*)comment andPublicity:(BOOL)publicity {
    
    [Eng.apiClient addNewVisitForBlogDate:blogdate withPOIId:poiid toSeqPlace:seqnum withstartDate:startDate andEndDate:endDate withComment:comment andPublicity:publicity onSuccess:^(NSDictionary* json){
        
        NSString* success = [json objectForKey:RESULT];
        
        if ([success isEqualToString:@"true"])
            [SVProgressHUD showSuccessWithStatus:L(MEWVISITADDED)];
        else
            [SVProgressHUD showErrorWithStatus:L(FAILED)];
    
        //Call the delegate
        if (self.delegate && [self.delegate respondsToSelector:@selector(visitAdded)])
            [self.delegate visitAdded];
    }];
}


-(void)shareBlogToSocialMedia:(NSArray*)selectedMedia forDate:(NSString*)blogDate {
    
    [Eng.apiClient shareBlogToSocialMedia:selectedMedia forDate:blogDate
            onSuccess:^(NSDictionary* json){
                
            int sharecount = 0;
                
            if ([selectedMedia containsObject:TWITTER])
            {
                NSString* twitterResponse = [json objectForKey:@"twitter"];
                    
                if ([twitterResponse isEqualToString:@"true"])
                    sharecount++;
            }
                
            if ([selectedMedia containsObject:FACEBOOK])
            {
                NSString* facebookResponse = [json objectForKey:@"facebook"];
                
                if ([facebookResponse isEqualToString:@"true"])
                    sharecount++;
            }
                
            if (sharecount>0)
            {
                if (sharecount>1)
                    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%d %@", sharecount, L(SUCCESSFULSHARES)]];
                else
                    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%d %@", sharecount, L(SUCCESSFULSHARE)]];
            }
            else
                [SVProgressHUD showErrorWithStatus:L(FAILED)];
    }];
}


-(void)retrieveGPSTraceForDate:(NSString*)blogDate {
    
    [Eng.apiClient retrieveGPSTraceForDate:blogDate
         onSuccess:^(NSDictionary* json) {
             
             
             //Get POI list
             NSArray* poiList = [json objectForKey:POILIST];
             
             NSMutableArray* locations = [NSMutableArray array];
             
             for (NSDictionary* trace in poiList)
             {
                 NSString* lat = [trace objectForKey:@"x"];
                 NSString* lng = [trace objectForKey:@"y"];
                 CLLocation* loc = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lng doubleValue]];
                 
                 [locations addObject:loc];
             }
             
             //Call the delegate
             if (self.delegate && [self.delegate respondsToSelector:@selector(traceRetrieved:)])
                 [self.delegate traceRetrieved:locations];
         }];
}

@end
