//
//  Blog.h
//  MoDisSence
//
//  Created by Panagiotis Kokkinakis on 4/12/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum  {
    BlogStatusPrivate = 0,
    BlogStatusPending = 1,
    BlogStatusPublished = 2
} BlogStatusType;

@interface Blog : NSObject <NSCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic) BlogStatusType status;
@property (nonatomic, strong) NSMutableArray *POIS;

@end
