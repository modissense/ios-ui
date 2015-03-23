//
//  PublicityCell.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 9/19/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Publicity.h"
#import "PickerInputTableViewCell.h"

@class PublicityCell;

@protocol PublicityCellDelegate <NSObject>
@optional
- (void)tableViewCell:(PublicityCell *)cell didEndEditingWithPublicity:(Publicity *)value;
@end

@interface PublicityCell : PickerInputTableViewCell <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) Publicity *publicity;
@property (weak) IBOutlet id <PublicityCellDelegate> delegate;

-(void)setPickerRow:(int)row;

@end