//
//  Blog.m
//  MoDisSence
//
//  Created by Panagiotis Kokkinakis on 4/12/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "Blog.h"

@implementation Blog

@synthesize name;
@synthesize creationDate;
@synthesize status;
@synthesize POIS;

- (id)init {
    self = [super init];
    if (self) {
        name = @"";
        creationDate = [NSDate date];
        POIS = [NSMutableArray array];
        status = BlogStatusPrivate;
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:name forKey:@"name"];
    [encoder encodeObject:creationDate forKey:@"creationDate"];
    [encoder encodeObject:POIS forKey:@"pois"];
    [encoder encodeInt:status forKey:@"status"];
}

- (id) initWithCoder:(NSCoder*)decoder {
    if (self = [super init]) {
        name = [decoder decodeObjectForKey:@"name"];
        creationDate = [decoder decodeObjectForKey:@"creationDate"];
        POIS = [decoder decodeObjectForKey:@"pois"];
        status = [decoder decodeIntForKey:@"status"];
    }
    return self;
}

@end
