//
//  SearchUserTableViewController.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 9/4/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchUserTableDelegate <NSObject>

@optional
-(void)selectedFriends:(NSArray*)friendids;
@end

@interface SearchUserTableViewController : UITableViewController

@property (nonatomic, weak) id <SearchUserTableDelegate> delegate;

@property (nonatomic, strong) NSMutableArray* selectedFriendIDs;

@end