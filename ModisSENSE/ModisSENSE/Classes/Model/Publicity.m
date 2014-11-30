//
//  Publicity.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 9/19/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "Publicity.h"
#import "Engine.h"

@implementation Publicity

- (id)init {
    self.publicity = YES;
    
    return self;
}

- (id)initWithPublicity:(BOOL)publicity {
    self.publicity = publicity;
    
    return self;
}


- (NSString *)description {
    
    if (self.publicity==YES)
        return L(PUBLIC);
    else
        return L(PRIVATE);
}

@end
