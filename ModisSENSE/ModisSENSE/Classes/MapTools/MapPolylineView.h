//
//  MapPolylineView.h
//  MobileXO
//
//  Created by George Giaslas on 7/7/09.
//  Copyright 2009 ATC. All rights reserved.
//



#import <MapKit/MapKit.h>


@interface MapPolylineView : UIView {

@private
	MKMapView	*iMap;
	NSArray		*iPolyline;
	BOOL		iDashed;

}

- (id)initWithMapView:(MKMapView*)map polyline:(NSArray*)polyline dashed:(BOOL)dashed;

@end


