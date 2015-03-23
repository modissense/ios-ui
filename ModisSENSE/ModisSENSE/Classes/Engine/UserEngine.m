//
//  UserEngine.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 8/27/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "UserEngine.h"
#import "Config.h"
#import "Friend.h"
#import "SVProgressHUD.h"

@implementation UserEngine


-(void)connectWithSocialMedia:(NSString*)social userid:(NSString*)userId {
    
    [Eng.apiClient connectWithSocialMedia:social userid:userId];
}



-(void)getConnectedAccountsFromUser:(NSString*)userId {

    [Eng.apiClient getConnectedAccounts:userId
      onSuccess:^(NSDictionary* json){
          
          //Clean the array for a refresh
          if (Eng.user.socialAccounts)
              Eng.user.socialAccounts = nil;
          
          //Array of json objects
          NSArray* networks = [json objectForKey:NETWORKS];
          Eng.user.socialAccounts = [[NSMutableArray alloc] init];
          
          for (int i=0 ; i<networks.count ; i++)
          {
              NSDictionary* network = [networks objectAtIndex:i];
              [Eng.user.socialAccounts addObject:[network objectForKey:NAME]];
          }
          
          //Call the delegate
          if (self.delegate && [self.delegate respondsToSelector:@selector(gotConnectedAccounts)]) {
              [self.delegate gotConnectedAccounts];
          }
      }];
}



-(void)getFriendsForUser:(NSString*)userId showLoader:(BOOL)loader {
    
    [Eng.apiClient getFriendsForUser:userId showLoader:loader
       onSuccess:^(NSDictionary* json){
           
           //Clean friends for a refresh
           Eng.user.twitterFriends = nil;
           Eng.user.facebookFriends = nil;
           Eng.user.foursquareFriends = nil;
           
           Eng.user.twitterFriends = [[NSMutableArray alloc] init];
           Eng.user.facebookFriends = [[NSMutableArray alloc] init];
           Eng.user.foursquareFriends = [[NSMutableArray alloc] init];
           
           NSDictionary* user = [json objectForKey:USER];
           
           //Get primary account for ModisSENSE
           Eng.user.mainAccount = [user objectForKey:PRIMARYACCOUNT];
           
           //Get user name
           NSString* username = [user objectForKey:USERNAME];
           if (username!=nil && username != (id)[NSNull null] && ![username isEqualToString:@"null"])
               Eng.user.userName = username;
           else
               Eng.user.userName = nil;
           
           //Avatar URL
           Eng.user.avatarURL = [user objectForKey:IMAGE];
           
           //Get user's friends
           NSArray* connections = [user objectForKey:CONNECTIONS];
           
           for (int i=0 ; i<connections.count ; i++)
           {
               NSDictionary* friendObject = [connections objectAtIndex:i];
               
               NSString* network = [friendObject objectForKey:NETWORK];
               
               NSArray* friends = [friendObject objectForKey:FRIENDS];
               
               if ([network isEqualToString:TWITTER])
               {
                   for (int j=0 ; j<friends.count ; j++)
                   {
                       NSDictionary* friendJSON = [friends objectAtIndex:j];
                       Friend* friend = [[Friend alloc] init];
                       friend.friendId = [friendJSON objectForKey:ID];
                       friend.name = [friendJSON objectForKey:NAMESMALL];
                       friend.avatarImgURL = [friendJSON objectForKey:URL];
                       
                       [Eng.user.twitterFriends addObject:friend];
                   }
               }
               else if ([network isEqualToString:FACEBOOK])
               {
                   for (int j=0 ; j<friends.count ; j++)
                   {
                       NSDictionary* friendJSON = [friends objectAtIndex:j];
                       Friend* friend = [[Friend alloc] init];
                       friend.friendId = [friendJSON objectForKey:ID];
                       friend.name = [friendJSON objectForKey:NAMESMALL];
                       friend.avatarImgURL = [friendJSON objectForKey:URL];
                       
                       [Eng.user.facebookFriends addObject:friend];
                   }
               }
               else
               {
                   for (int j=0 ; j<friends.count ; j++)
                   {
                       NSDictionary* friendJSON = [friends objectAtIndex:j];
                       Friend* friend = [[Friend alloc] init];
                       friend.friendId = [friendJSON objectForKey:ID];
                       friend.name = [friendJSON objectForKey:NAMESMALL];
                       friend.avatarImgURL = [friendJSON objectForKey:URL];
                       
                       [Eng.user.foursquareFriends addObject:friend];
                   }
               }
           }
           
           //Call the delegate
           if (self.delegate && [self.delegate respondsToSelector:@selector(gotFriends)]) {
               [self.delegate gotFriends];
           }
       }];
}


-(void)signOutUser {
    /*
    [Eng.apiClient signOutUserId:Eng.user.userId
        onSuccess:^(NSDictionary* json){
        
            NSString* success = [json objectForKey:RESULT];
            
            if ([success isEqualToString:@"true"])
                [SVProgressHUD showSuccessWithStatus:@""];
            else
                [SVProgressHUD showErrorWithStatus:@""];
        }];
    */
    [self clearUserData];
}


-(void)deleteUser {
    
    [Eng.apiClient deleteSocial:nil fromUserId:Eng.user.userId onSuccess:^(NSDictionary *json) {
        
        NSString* success = [json objectForKey:SUCCESS];
        
        if ([success isEqualToString:@"true"])
        {
            [SVProgressHUD showSuccessWithStatus:L(ACCOUNT_DELETED)];
            
            [self clearUserData];
            
            //Call the delegate
            if (self.delegate && [self.delegate respondsToSelector:@selector(userDeleted)]) {
                [self.delegate userDeleted];
            }
        }
        else
            [SVProgressHUD showErrorWithStatus:L(FAILED)];
    }];
}



-(void)removeSocialAccount:(NSString*)account {
    
    [Eng.apiClient deleteSocial:account fromUserId:Eng.user.userId onSuccess:^(NSDictionary *json) {
        
        NSString* success = [json objectForKey:SUCCESS];
        
        if ([success isEqualToString:@"true"])
        {
            [SVProgressHUD showSuccessWithStatus:L(ACCOUNT_DELETED)];
            
            //Call the delegate
            if (self.delegate && [self.delegate respondsToSelector:@selector(accountRemoved)]) {
                [self.delegate accountRemoved];
            }
        }
        else
            [SVProgressHUD showErrorWithStatus:L(FAILED)];
    }];
}

-(void)clearUserData {
    Eng.user.userId = nil;
    Eng.user.userName = nil;
    Eng.user.socialAccounts = nil;
    [Eng.user.socialAccounts removeAllObjects];
    [Eng.user.twitterFriends removeAllObjects];
    [Eng.user.facebookFriends removeAllObjects];
    [Eng.user.foursquareFriends removeAllObjects];
    Eng.user.connected = NO;
}


@end
