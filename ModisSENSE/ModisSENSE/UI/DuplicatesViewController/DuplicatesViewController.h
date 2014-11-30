//
//  DuplicatesViewController.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 9/17/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DuplicatesViewControllerDelegate <NSObject>
@optional
-(void)addPOI;
@end

@interface DuplicatesViewController : UITableViewController

@property (strong,nonatomic) NSArray* duplicatesList;   //Holds list of duplicate POI objects

@property (weak) IBOutlet id<DuplicatesViewControllerDelegate> delegate;
@end
