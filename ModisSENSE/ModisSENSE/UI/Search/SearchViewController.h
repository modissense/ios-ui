//
//  SearchViewController.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/15/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StringInputTableViewCell.h"
#import "PickLocationViewController.h"
#import "AddressCoordinates.h"
#import "DateInputTableViewCell.h"
#import "LocationMarqueeCell.h"
#import "Engine.h"
#import "UIConstants.h"
#import "SearchUserTableViewController.h"
#import "MapResultsViewController.h"
#import "SliderCell.h"
#import "POIEngine.h"
#import "ClassificationCell.h"
#import "SVProgressHUD.h"

@interface SearchViewController : UITableViewController <StringInputTableViewCellDelegate, PickLocationViewControllerDelegate, AddressCoordinatesDelegate, DateInputTableViewCellDelegate, SearchUserTableDelegate,StepperDelegate,POIEngineDelegate,ClassificationCellDelegate>

@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@end
