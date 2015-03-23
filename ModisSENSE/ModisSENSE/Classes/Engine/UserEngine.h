//
//  UserEngine.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 8/27/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Engine.h"

@protocol UserEngineDelegate <NSObject>

@optional
-(void)gotConnectedAccounts;
-(void)gotFriends;
-(void)userDeleted;
-(void)accountRemoved;
@end

@interface UserEngine : NSObject

@property (nonatomic, weak) id <UserEngineDelegate> delegate;

-(void)connectWithSocialMedia:(NSString*)social userid:(NSString*)userId;
-(void)getConnectedAccountsFromUser:(NSString*)userId;
-(void)getFriendsForUser:(NSString*)userId showLoader:(BOOL)loader;
-(void)signOutUser;
-(void)removeSocialAccount:(NSString*)account;
-(void)deleteUser;

@end
