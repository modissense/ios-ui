//
//  StringInputTableViewCell.m
//  ShootStudio
//
//  Created by Tom Fewster on 19/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "StringInputTableViewCell.h"
#import "UIConstants.h"

@implementation StringInputTableViewCell {
    UITableViewCellStyle savedStyle;
}

@synthesize delegate;
@synthesize stringValue;
@synthesize textField;
@synthesize allowEnabledOnlyWhenEditing;

- (void)initalizeInputView {
	// Initialization code
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
	self.textField.autocorrectionType = UITextAutocorrectionTypeDefault;
	self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.textField.textAlignment = NSTextAlignmentLeft;
	self.textField.font = [UIFont systemFontOfSize:17.0f];
	self.textField.clearButtonMode = UITextFieldViewModeNever;
	self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textField.clearButtonMode = UITextFieldViewModeAlways;
    self.textField.textColor = CELLCOLOR;
    self.textField.font = CELLFONT;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
	[self addSubview:self.textField];
	
	self.accessoryType = UITableViewCellAccessoryNone;
	
	self.textField.delegate = self;
    
    self.allowEnabledOnlyWhenEditing = NO;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        savedStyle = style;
		[self initalizeInputView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
		[self initalizeInputView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	if (selected) {
		[self.textField becomeFirstResponder];
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	if (selected) {
		[self.textField becomeFirstResponder];
	}
}

- (void)setStringValue:(NSString *)value {
	self.textField.text = value;
}

- (NSString *)stringValue {
	return self.textField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (delegate && [delegate respondsToSelector:@selector(endedEditingStringCell)]) {
		[delegate endedEditingStringCell];
	}
	[self.textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (delegate && [delegate respondsToSelector:@selector(tableViewCell:didEndEditingWithString:)]) {
		[delegate tableViewCell:self didEndEditingWithString:self.stringValue];
	}
    
//	UITableView *tableView = (UITableView *)self.superview;
//	[tableView deselectRowAtIndexPath:[tableView indexPathForCell:self] animated:YES];
    [self resignFirstResponder];
}

- (void)layoutSubviews {
	[super layoutSubviews];
    
    CGRect editFrame = CGRectInset(self.contentView.frame, CELLPADDING, CELLPADDING);
//    editFrame.origin.y += 3;    //Customize it as you wish
    editFrame.size.height +=3;
    
    if (savedStyle == UITableViewCellStyleValue2) {
        self.textField.frame = CGRectMake(110, CGRectGetMinY(editFrame), CGRectGetWidth(editFrame)-110, CGRectGetHeight(editFrame));
    } else {
        
        
        if (self.imageView.image) {
            CGSize imgSize = self.imageView.image.size;
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
                editFrame.origin.x += imgSize.width + 15;
            else
                editFrame.origin.x += imgSize.width + 6;
            
            editFrame.size.width -= imgSize.width + 10;
        }
        
        if (self.textLabel.text && [self.textLabel.text length] != 0) {
            CGSize textSize = [self.textLabel sizeThatFits:CGSizeZero];
            editFrame.origin.x += textSize.width + 10;
            editFrame.size.width -= textSize.width + 10;
            self.textField.textAlignment = NSTextAlignmentRight;
        } else {
            self.textField.textAlignment = NSTextAlignmentLeft;
        }
        
        self.textField.frame = editFrame;
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    if (self.allowEnabledOnlyWhenEditing) {
        if (editing) {
            self.textField.enabled = YES;
        }
        else {
            self.textField.enabled = NO;
        }
    }
    [super setEditing:editing animated:animated];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *) textField
{
    if (delegate && [delegate respondsToSelector:@selector(stratedEditingStringCell)]) {
		[delegate stratedEditingStringCell];
	}
    
    return YES;
}

@end
