//
//  ClassificationCell.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 9/19/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "ClassificationCell.h"

@implementation ClassificationCell

__strong NSArray *orderbyValues = nil;

+ (void)initialize {
    Classification* hotness = [[Classification alloc] initWithOrder:HOTNESS];
    Classification* interest = [[Classification alloc] initWithOrder:INTEREST];
    
	orderbyValues = [NSArray arrayWithObjects:hotness,interest, nil];
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

- (void)setValue:(Classification *) order {
	self.orderby = order;
	self.detailTextLabel.text = order.description;
	[self.picker selectRow:[orderbyValues indexOfObject:order] inComponent:0 animated:YES];
}

#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [orderbyValues count];
}

#pragma mark -
#pragma mark UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [[orderbyValues objectAtIndex:row] description];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
	return 44.0f;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
	return 300.0f; //pickerView.bounds.size.width - 20.0f;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	self.orderby = [orderbyValues objectAtIndex:row];
    
	if (self.delegate && [self.delegate respondsToSelector:@selector(tableViewCell:didEndEditingWithClassification:)]) {
		[self.delegate tableViewCell:self didEndEditingWithClassification:self.orderby];
	}
}

@end
