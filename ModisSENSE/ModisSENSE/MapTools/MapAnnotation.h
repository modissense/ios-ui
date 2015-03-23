//
//  MapAnnotation.h
//  MobileXO
//
//  Created by George Giaslas on 6/24/09.
//  Copyright 2009 ATC. All rights reserved.
//



#import <MapKit/MapKit.h>


@interface MapAnnotation : NSObject <MKAnnotation> {

@private
	NSString *iTitle;
	NSString *iSubTitle;
	double iLatitude;
	double iLongitude;
	NSInteger iIndex;
	NSInteger iTag;
}

@property (nonatomic,readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic,readonly) NSInteger index;
@property (nonatomic,readonly) NSInteger tag;

- (id) initWithTitle:(NSString*)title subTitle:(NSString*)subtitle latitude:(double)lat longitude:(double)lng index:(NSInteger)index tag:(NSInteger)tag;

- (void) changeCoordinate:(CLLocationCoordinate2D)coord;

@end


