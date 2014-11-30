//
//  Publicity.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 9/19/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Publicity : NSObject

@property (nonatomic,assign) BOOL publicity;
@property (nonatomic,strong) NSString* description;

- (id) initWithPublicity:(BOOL)publicity;

@end
