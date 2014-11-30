//
//  UITableViewCellFixedMarqueeCell.m
//  Agrotypos
//
//  Created by Panagiotis Kokkinakis on 1/30/13.
//  Copyright (c) 2013 mac1. All rights reserved.
//

#import "LocationMarqueeCell.h"
#import "AutoScrollLabel.h"
#import "UIConstants.h"

@implementation LocationMarqueeCell{
    UITableViewCellStyle savedStyle;
}

@synthesize marqueeLabel = iMarqueeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        savedStyle = style;
        
        CGRect frame;
        
        if (savedStyle == UITableViewCellStyleValue2) {
            CGRect editFrame = CGRectInset(self.contentView.frame, CELLPADDING, 10);
            frame = CGRectMake(46, CGRectGetMinY(editFrame)+3, CGRectGetWidth(editFrame)- CELLPADDING, CGRectGetHeight(editFrame));
            iMarqueeLabel.frame = frame;
            iMarqueeLabel.backgroundColor = [UIColor clearColor];
        } else {
            frame = CGRectMake(20, 0, self.frame.size.width - CELLPADDING * 5 - 20, self.frame.size.height);
            iMarqueeLabel.frame = frame;
            iMarqueeLabel.backgroundColor = [UIColor clearColor];
        }
    
        iMarqueeLabel = [[AutoScrollLabel alloc] initWithFrame:frame];
        iMarqueeLabel.font = CELLFONT;
        
        [self.contentView addSubview:iMarqueeLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (savedStyle == UITableViewCellStyleValue2) {
        CGRect editFrame = CGRectInset(self.contentView.frame, CELLPADDING, 10);
        CGRect frame = CGRectMake(46, CGRectGetMinY(editFrame)+3, CGRectGetWidth(editFrame)- 36, CGRectGetHeight(editFrame));
        iMarqueeLabel.frame = frame;
        iMarqueeLabel.backgroundColor = [UIColor clearColor];
        
        UIImageView *leftImage = [[UIImageView alloc] initWithFrame:CGRectMake(CELLPADDING,frame.size.height/2+3,16,16)]; // set the location and size of your imageview here.
        leftImage.image = [UIImage imageNamed:@"location"];
        
        [self.contentView addSubview:leftImage];
        
    } else {
        CGRect frame = CGRectMake(20, 0, self.frame.size.width - CELLPADDING * 5 - 20, self.frame.size.height);
        iMarqueeLabel.frame = frame;
        iMarqueeLabel.backgroundColor = [UIColor clearColor];
    }
    
    [self.contentView addSubview:iMarqueeLabel];
    
//    if (self.accessoryView)
//        self.accessoryView.frame = CGRectOffset(self.accessoryView.frame, -20, 0);
}

@end
