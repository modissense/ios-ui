//
//  SwitchCell.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/16/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SwitchCell;

@protocol SwitchCellDelegate <NSObject>

@optional
- (void)tableViewCell:(SwitchCell *)cell switchChangedTo:(BOOL) state;      //The delegate function
@end



@interface SwitchCell : UITableViewCell

@property (nonatomic, strong) NSString *textString;
@property (nonatomic, assign) BOOL switchState;
@property (strong) id <SwitchCellDelegate> delegate;

@end
