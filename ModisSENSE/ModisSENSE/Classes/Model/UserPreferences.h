//
//  UserPreferences.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 8/23/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserPreferences : NSObject

@property (assign,nonatomic) BOOL trackUserPosition;

//Dictionaries of Friend objects
@property (strong,nonatomic) NSMutableDictionary *selectedTwitterUsers;
@property (strong,nonatomic) NSMutableDictionary *selectedFacebookUsers;
@property (strong,nonatomic) NSMutableDictionary *selectedFoursquareUsers;

@property (strong,nonatomic) NSMutableArray* selectedFriendIDs;

@end
