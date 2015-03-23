//
//  BlogViewController.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/12/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlogEngine.h"
#import "FlatDatePicker.h"

@interface BlogViewController : UITableViewController <BlogEngineDelegate,FlatDatePickerDelegate>

@property (nonatomic, strong) FlatDatePicker *flatDatePicker;

@end
