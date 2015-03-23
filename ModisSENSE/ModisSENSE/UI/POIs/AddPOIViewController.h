//
//  AddBlogRecordViewController.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 6/17/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Engine.h"
#import "RightDetailedCell.h"
#import "DateInputTableViewCell.h"
#import "UIConstants.h"
#import "PickLocationViewController.h"
#import "AddressCoordinates.h"
#import "LocationMarqueeCell.h"
#import "StringInputTableViewCell.h"
#import "SliderCell.h"
#import "SVProgressHUD.h"
#import "POIEngine.h"
#import "POI.h"
#import "DuplicatesViewController.h"
#import "PublicityCell.h"
#import "Publicity.h"

@protocol AddPOIViewControllerDelegate <NSObject>
@optional
- (void)newPOIAdded:(POI*)poi;
@end

@interface AddPOIViewController : UITableViewController <StringInputTableViewCellDelegate,DateInputTableViewCellDelegate,PickLocationViewControllerDelegate,AddressCoordinatesDelegate,UIAlertViewDelegate,StepperDelegate,POIEngineDelegate,UIActionSheetDelegate,DuplicatesViewControllerDelegate,PublicityCellDelegate>

@property (nonatomic, weak) id <AddPOIViewControllerDelegate> delegate;

@property (strong,nonatomic) CLLocation *poiLocation;;

@property (weak, nonatomic) IBOutlet UILabel *tellUsAboutIt;

@property (assign, nonatomic) BOOL dontSearchForDuplicates;
@property (assign, nonatomic) BOOL isModal;

-(void)loadAddressFromCoordinates:(CLLocation *)coordinates;

@end
