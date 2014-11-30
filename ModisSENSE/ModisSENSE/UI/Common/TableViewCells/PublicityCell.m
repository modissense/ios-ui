//
//  PublicityCell.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 9/19/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "PublicityCell.h"


@implementation PublicityCell

__strong NSArray *publicityValues = nil;

+ (void)initialize {
    Publicity* public = [[Publicity alloc] initWithPublicity:YES];
    Publicity* private = [[Publicity alloc] initWithPublicity:NO];
    
	publicityValues = [NSArray arrayWithObjects:public,private, nil];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		self.picker.delegate = self;
		self.picker.dataSource = self;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
		self.picker.delegate = self;
		self.picker.dataSource = self;
    }
    return self;
}

- (void)setValue:(Publicity *) publicity {
	self.publicity = publicity;
	self.detailTextLabel.text = publicity.description;
	[self.picker selectRow:[publicityValues indexOfObject:publicity] inComponent:0 animated:YES];
}

#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [publicityValues count];
}

#pragma mark -
#pragma mark UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [[publicityValues objectAtIndex:row] description];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
	return 44.0f;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
	return 300.0f; //pickerView.bounds.size.width - 20.0f;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	self.publicity = [publicityValues objectAtIndex:row];
    
	if (self.delegate && [self.delegate respondsToSelector:@selector(tableViewCell:didEndEditingWithPublicity:)]) {
		[self.delegate tableViewCell:self didEndEditingWithPublicity:self.publicity];
	}
}

@end
