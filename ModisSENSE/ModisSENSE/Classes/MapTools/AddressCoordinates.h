//
//  AddressCoordinates.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 8/19/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "AddressCoordinates.h"
#import <MapKit/MapKit.h>

@protocol AddressCoordinatesDelegate <NSObject>
@optional
- (void)addressFound: (MKPlacemark *)placemark;
@end


@interface AddressCoordinates : NSObject

@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) MKPlacemark *placemark;
@property (weak) IBOutlet id<AddressCoordinatesDelegate> delegate;

-(void)getAddress: (CLLocation *)location;

@end
