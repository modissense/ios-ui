//
//  AddressCoordinates.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 8/19/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "AddressCoordinates.h"
#import "Engine.h"
#import "SVProgressHUD.h"

@implementation AddressCoordinates

@synthesize delegate;

- (id)init {
	if ((self = [super init])) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    
    return self;
}

-(void)getAddress: (CLLocation *)location {
    
    if (!self.dontShowProgress)
        [SVProgressHUD showWithStatus:L(RETRIEVINGADDRESS)];
    
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        self.placemark = [placemarks objectAtIndex:0];
        
        if (delegate && [delegate respondsToSelector:@selector(addressFound:)]) {
            [delegate addressFound:self.placemark];
        }
        
        if (!self.dontShowProgress)
            [SVProgressHUD dismiss];
    }];
}

@end