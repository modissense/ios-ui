//
//  User.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 8/27/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (strong,nonatomic) NSString* userId;
@property (strong,nonatomic) NSString* userName;
@property (strong,nonatomic) NSMutableArray* socialAccounts;

//Arrays of Friend objects
@property (strong,nonatomic) NSMutableArray* twitterFriends;
@property (strong,nonatomic) NSMutableArray* facebookFriends;
@property (strong,nonatomic) NSMutableArray* foursquareFriends;

@property (assign,nonatomic) BOOL connected;
@property (assign,nonatomic) BOOL isInBackground;

@end
