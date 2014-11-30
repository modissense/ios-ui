//
//  SettingsViewController.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/12/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwitchCell.h"
#import "UserEngine.h"

@interface SettingsViewController : UITableViewController <SwitchCellDelegate, UserEngineDelegate>

- (void)getConnectedAccounts;

@end
