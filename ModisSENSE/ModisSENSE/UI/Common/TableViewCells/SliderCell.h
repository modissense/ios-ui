//
//  StepperCell.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 9/5/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StepperDelegate <NSObject>
@optional
- (void)valueFromSlider:(int)value;
@end

@interface SliderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (weak) IBOutlet id<StepperDelegate> delegate;

- (IBAction)sliderMoved:(id)sender;

@end
