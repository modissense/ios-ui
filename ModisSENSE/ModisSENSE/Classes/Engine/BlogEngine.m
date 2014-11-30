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

@implementation BlogEngine


-(void)getBlogs {
    
    [Eng.apiClient getBlogsOnSuccess:^(NSDictionary* json)
     {
         //This will hold the blog dates (strings)
         NSMutableArray* blogDates = [NSMutableArray array];
         
         NSArray* blogs = [json objectForKey:BLOGS];
         
         if (blogs.count==0)
             [SVProgressHUD showErrorWithStatus:L(NOBLOGSAVAILABLE)];
         
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
            
            if (blog.count==0)
                [SVProgressHUD showImage:[UIImage imageNamed:@"location_service"] status:L(NOTHINGFOUND)];
            
            for (int i=0 ; i<blog.count ; i++)
            {
                NSDictionary* poiResponse = [blog objectAtIndex:i];
                POI* poi = [[POI alloc] init];
                
                poi.startDate = [poiResponse objectForKey:@"start"];
                poi.endDate = [poiResponse objectForKey:@"end"];
                poi.poi_id = [poiResponse objectForKey:@"poi_id"];
                poi.name = [poiResponse objectForKey:@"name"];
                
                NSString* lat = [poiResponse objectForKey:@"lat"];
                NSString* lng = [poiResponse objectForKey:@"long"];
                
                CLLocation* loc = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lng doubleValue]];
                poi.location = loc;
                
                poi.description = [poiResponse objectForKey:@"comment"];
                poi.publicity = [[poiResponse objectForKey:@"publicity"] boolValue];
                poi.interest = [[poiResponse objectForKey:@"interest"] intValue];
                poi.hotness = [[poiResponse objectForKey:@"hotness"] intValue];
                
                NSArray* keywords = [poiResponse objectForKey:KEYWORDS];
                poi.keywords = keywords;
                
                [poiList addObject:poi];
            }
            
            //Call the delegate
            if (self.delegate && [self.delegate respondsToSelector:@selector(gotPOISforBlogDate:)])
                [self.delegate gotPOISforBlogDate:poiList];
    }];
}

@end
