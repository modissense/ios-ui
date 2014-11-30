//
//  Classification.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 9/19/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "Classification.h"
#import "ApiClient.h"
#import "Engine.h"

@implementation Classification

- (id)init {
    self.classification = 0;
    
    return self;
}

- (id)initWithOrder:(NSString*)classification {
    self.classification = classification;
    
    return self;
}


- (NSString *)description {
    
    if ([self.classification isEqualToString:HOTNESS])
        return L(HOTNESS);
    else
        return L(INTEREST);
}

@end
