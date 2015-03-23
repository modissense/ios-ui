//
//  UserSelectionViewController.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/12/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserEngine.h"

@protocol UserSelectionDelegate <NSObject>

@optional
-(void)friendsSelected;
@end

@interface UserSelectionViewController : UITableViewController <UserEngineDelegate>

@property (nonatomic, weak) id <UserSelectionDelegate> delegate;

@end
