//
//  StringInputTableViewCell.h
//  ShootStudio
//
//  Created by Tom Fewster on 19/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StringInputTableViewCell;

@protocol StringInputTableViewCellDelegate <NSObject>
@optional
- (void)tableViewCell:(StringInputTableViewCell *)cell didEndEditingWithString:(NSString *)value;
- (void)stratedEditingStringCell;
- (void)endedEditingStringCell;
@end


@interface StringInputTableViewCell : UITableViewCell <UITextFieldDelegate> {
    UITextField *textField;
}

@property (nonatomic, strong) NSString *stringValue;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, readwrite) BOOL allowEnabledOnlyWhenEditing;
@property (weak) IBOutlet id<StringInputTableViewCellDelegate> delegate;

@end
