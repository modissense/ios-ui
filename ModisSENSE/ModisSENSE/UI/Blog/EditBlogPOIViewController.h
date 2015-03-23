//
//  EditBlogPOIViewController.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 10/3/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMapView.h"
#import "DateInputTableViewCell.h"
#import "AddressCoordinates.h"
#import "BlogEngine.h"
#import "POI.h"

@protocol EditBlogPOIViewControllerDelegate <NSObject>
@optional
-(void)refreshBlog;
-(void)newVisitAdded;
@end

@interface EditBlogPOIViewController : UIViewController <GMapViewDelegate,DateInputTableViewCellDelegate,UIAlertViewDelegate,BlogEngineDelegate,AddressCoordinatesDelegate>

@property (nonatomic, weak) id <EditBlogPOIViewControllerDelegate> delegate;

@property (strong,nonatomic) POI* selectedPOI;
@property (strong,nonatomic) NSString* blogDate;
@property (assign,nonatomic) int newSeqID;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (weak, nonatomic) IBOutlet GMapView *gMapView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) BOOL isNewVisit;
@end
