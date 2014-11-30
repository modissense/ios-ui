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
-(void)gotPOISforBlogDate:(NSArray*)pois;
@end


@interface BlogEngine : NSObject

@property (nonatomic, weak) id <BlogEngineDelegate> delegate;

-(void)getBlogs;
-(void)getBlogForDate:(NSString*)date;

@end
