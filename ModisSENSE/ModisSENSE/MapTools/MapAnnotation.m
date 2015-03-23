//
//  MapAnnotation.m
//  MobileXO
//
//  Created by George Giaslas on 6/24/09.
//  Copyright 2009 ATC. All rights reserved.
//



#import "MapAnnotation.h"


@implementation MapAnnotation

@dynamic coordinate;
@synthesize index = iIndex;
@synthesize tag = iTag;


- (id) initWithTitle:(NSString*)title subTitle:(NSString*)subtitle latitude:(double)lat longitude:(double)lng index:(NSInteger)index tag:(NSInteger)tag {
	if ((self = [super init])) {
		// save the title
		iTitle = title;
		iSubTitle = subtitle;
		// save the latitude/longitude specified
		iLatitude = lat;
		iLongitude = lng;
		// save the index & tag
		iIndex = index;
		iTag = tag;
	}
	return self;
}

- (CLLocationCoordinate2D) coordinate {
	CLLocationCoordinate2D ret;
	ret.latitude = iLatitude;
	ret.longitude = iLongitude;
	return ret;
}

- (NSString *)title {
	return iTitle;
}

- (NSString *)subtitle {
	return iSubTitle;
}

- (void) changeCoordinate:(CLLocationCoordinate2D)coord {
	iLatitude = coord.latitude;
	iLongitude = coord.longitude;
}

@end



