//
//  EditPOIViewController.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 9/20/13.
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

@protocol EditPOIViewControllerDelegate <NSObject>

@optional
-(void)updatePinWithTag:(NSInteger)tag name:(NSString*)name location:(CLLocation*)location descriptiom:(NSString*)description publicity:(BOOL)publicity andKeywords:(NSArray*)keywords;
-(void)removePinWithTag:(NSInteger)tag;
@end

@interface EditPOIViewController : UITableViewController <StringInputTableViewCellDelegate,DateInputTableViewCellDelegate,PickLocationViewControllerDelegate,AddressCoordinatesDelegate,UIAlertViewDelegate,StepperDelegate,POIEngineDelegate,UIActionSheetDelegate,DuplicatesViewControllerDelegate,PublicityCellDelegate>

@property (nonatomic, weak) id <EditPOIViewControllerDelegate> delegate;

//POI data
@property (assign,nonatomic) NSInteger tag;
@property (strong,nonatomic) NSString* name;
@property (strong,nonatomic) CLLocation *poiLocation;
@property (strong,nonatomic) NSArray* keywords;
@property (strong,nonatomic) NSString* description;

//Where the edit is coming from
@property (assign,nonatomic) BOOL nearMeMap;

@end
