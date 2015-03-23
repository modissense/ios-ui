//
//  EditBlogViewController.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/12/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlogEngine.h"
#import "PickLocationViewController.h"
#import "EditBlogPOIViewController.h"
#import "POIEngine.h"
#import "AddPOIViewController.h"
#import "SelectableMapViewController.h"
#import "UserEngine.h"
#import "RNFrostedSidebar.h"

@interface EditBlogViewController : UITableViewController <BlogEngineDelegate,PickLocationViewControllerDelegate,EditBlogPOIViewControllerDelegate,POIEngineDelegate,AddPOIViewControllerDelegate,SelectableMapViewControllerDelegate,UserEngineDelegate,RNFrostedSidebarDelegate,UIAlertViewDelegate>

//Array of POI objects
@property (strong,nonatomic) NSArray* pointsOfInterest;

//Story
@property (strong,nonatomic) NSString* story;
@property (strong,nonatomic) NSString* blogDate;

-(void)refreshBlog;
-(void) startNewVisitProcess;

@end
