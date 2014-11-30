//
//  Classification.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 9/19/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Classification : NSObject

@property (nonatomic,strong) NSString* classification;
@property (nonatomic,strong) NSString* description;

- (id) initWithOrder:(NSString*)classification;

@end
