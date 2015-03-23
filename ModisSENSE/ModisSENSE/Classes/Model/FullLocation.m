//
//  FullLocation.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 10/7/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "FullLocation.h"

@implementation FullLocation

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:[NSNumber numberWithDouble:self.latitude] forKey:@"fullLatitude"];
    [encoder encodeObject:[NSNumber numberWithDouble:self.longtitude] forKey:@"fullLongtitude"];
}

- (id) initWithCoder:(NSCoder*)decoder {
    if (self = [super init]) {
        self.latitude = [(NSNumber*)[decoder decodeObjectForKey:@"fullLatitude"] doubleValue];
        self.longtitude = [(NSNumber*)[decoder decodeObjectForKey:@"fullLongtitude"] doubleValue];
    }
    return self;
}

@end
