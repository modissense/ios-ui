//
//  ClassificationCell.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 9/19/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Classification.h"
#import "PickerInputTableViewCell.h"
#import "ApiClient.h"

@class ClassificationCell;

@protocol ClassificationCellDelegate <NSObject>
@optional
- (void)tableViewCell:(ClassificationCell *)cell didEndEditingWithClassification:(Classification *)value;
@end

@interface ClassificationCell : PickerInputTableViewCell <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) Classification *orderby;
@property (weak) IBOutlet id <ClassificationCellDelegate> delegate;

@end
