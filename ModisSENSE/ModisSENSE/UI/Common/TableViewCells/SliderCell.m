//
//  StepperCell.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 9/5/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "SliderCell.h"
#import "UIConstants.h"
#import "Engine.h"

@implementation SliderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
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

}

- (IBAction)sliderMoved:(UISlider*)sender {
    
    int value = [sender value];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(valueFromSlider:)]) {
        [self.delegate valueFromSlider:value];
    }
}

@end
