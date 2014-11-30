//
//  HomeSettingsViewController.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/15/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwitchCell.h"
#import "UserSelectionViewController.h"
#import "UIConstants.h"
#import "Engine.h"

@protocol MapSettingsDelegate <NSObject>

@optional
-(void)searchForPOIS;
-(void)updateMap;
@end

@interface HomeSettingsViewController : UITableViewController <SwitchCellDelegate, UserSelectionDelegate>

@property (nonatomic, weak) id <MapSettingsDelegate> delegate;

@end
