//
//  RightDetailedCell.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/19/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "RightDetailedCell.h"
#import "UIConstants.h"

@implementation RightDetailedCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    //Cell must be subtitled
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        style = UITableViewCellStyleSubtitle;
        
        //Cell not colored when selected
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //Set proper fonts
        self.textLabel.font = CELLFONT;
        
        self.detailTextLabel.textColor = DEFAULTBLUE;
        self.detailTextLabel.font = CELLFONT;
    }
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected) {

	}
    else {

    }
}


- (void)layoutSubviews
{
	[super layoutSubviews];
    
    //Text frame left aligned
    if (self.animated) {
        CGRect textFrame = CGRectMake(3*CELLPADDING,2, self.contentView.frame.size.width - CGRectGetWidth(self.detailTextLabel.frame), self.contentView.bounds.size.height-3);
        self.textLabel.frame = textFrame;
    }
    else {
        CGRect textFrame = CGRectMake(CELLPADDING,2, self.contentView.frame.size.width - CGRectGetWidth(self.detailTextLabel.frame), self.contentView.bounds.size.height-3);
        self.textLabel.frame = textFrame;
    }
    
    //Animation
    if (self.animated)
    {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frame = self.textLabel.frame;
            frame.origin.x = CELLPADDING;
            self.textLabel.frame = frame;
        }];
    }
    

    
    //Subtitle frame right aligned
    CGRect detailedTextFrame = CGRectMake(self.contentView.frame.size.width-CELLPADDING-CGRectGetWidth(self.detailTextLabel.frame), 1, self.detailTextLabel.frame.size.width , self.contentView.bounds.size.height-3);
    
    self.detailTextLabel.frame = detailedTextFrame;
    
    //Set accessory indicator
    if (self.arrow)
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else
        self.accessoryType = 0;
}

@end
