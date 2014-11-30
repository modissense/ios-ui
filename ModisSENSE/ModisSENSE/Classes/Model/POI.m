//
//  BlogRecord.m
//  MoDisSence
//
//  Created by Panagiotis Kokkinakis on 4/12/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "POI.h"
#import "Engine.h"

@implementation POI


- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:self.poi_id forKey:@"poi_id"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.location forKey:@"location"];
    [encoder encodeObject:self.timestamp forKey:@"timestamp"];
    [encoder encodeObject:[NSNumber numberWithInt:self.interest] forKey:@"interest"];
    [encoder encodeObject:[NSNumber numberWithInt:self.hotness] forKey:@"hotness"];
    [encoder encodeObject:[NSNumber numberWithBool:self.publicity] forKey:@"publicity"];
    [encoder encodeObject:self.keywords forKey:@"keywords"];
    [encoder encodeObject:self.description forKey:@"description"];
    
    [encoder encodeObject:self.startDate forKey:@"startDate"];
    [encoder encodeObject:self.endDate forKey:@"endDate"];
}

- (id) initWithCoder:(NSCoder*)decoder {
    if (self = [super init]) {
        self.poi_id = [decoder decodeObjectForKey:@"poi_id"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.location = [decoder decodeObjectForKey:@"location"];
        self.timestamp = [decoder decodeObjectForKey:@"timestamp"];
        self.interest = [(NSNumber*)[decoder decodeObjectForKey:@"interest"] intValue];
        self.hotness = [(NSNumber*)[decoder decodeObjectForKey:@"hotness"] intValue];
        self.publicity = [(NSNumber*)[decoder decodeObjectForKey:@"publicity"] boolValue];
        self.keywords = [decoder decodeObjectForKey:@"keywords"];
        self.description = [decoder decodeObjectForKey:@"description"];
        
        self.startDate = [decoder decodeObjectForKey:@"startDate"];
        self.endDate = [decoder decodeObjectForKey:@"endDate"];
    }
    return self;
}

@end
