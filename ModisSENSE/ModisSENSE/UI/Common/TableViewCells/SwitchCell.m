//
//  SwitchCell.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/16/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "SwitchCell.h"
#import "UIConstants.h"

@interface SwitchCell () {
    UILabel *titleLabel;
    UISwitch *switchCtl;
}
@end

@implementation SwitchCell


- (void)initializeView {
	// Initialization code
    
    //Cell not colored when selected
	self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    // layoutSubViews will decide the final frame
    titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    titleLabel.font = CELLFONT;
    [self.contentView addSubview:titleLabel];
    
    switchCtl = [[UISwitch alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:switchCtl];

	
	self.accessoryType = UITableViewCellAccessoryNone;
    
    //What will happen if the switch is changed
    [switchCtl addTarget:self action:@selector(changeSwitchState) forControlEvents:UIControlEventValueChanged];
}



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self initializeView];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)layoutSubviews
{
	[super layoutSubviews];
    
    titleLabel.text = self.textString;

    CGRect labelFrame = CGRectMake(CELLPADDING, 0, self.contentView.bounds.size.width- switchCtl.bounds.size.width-2*CELLPADDING, self.contentView.bounds.size.height);
    
	titleLabel.frame = labelFrame;

    
    CGRect switchFrame = CGRectMake(self.contentView.bounds.size.width - switchCtl.bounds.size.width - CELLPADDING, self.contentView.bounds.size.height/2 - switchCtl.bounds.size.height/2, switchCtl.bounds.size.width, switchCtl.bounds.size.height);
    
	switchCtl.frame = switchFrame;
    
    [switchCtl setOn:self.switchState animated:YES];
}


-(void) changeSwitchState
{
    self.switchState = !self.switchState;
    
    [switchCtl setOn:self.switchState animated:YES];
    
    //Check and call the delegate function
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableViewCell:switchChangedTo:)]) {
		[self.delegate tableViewCell:self switchChangedTo:self.switchState];
	}
}

@end
