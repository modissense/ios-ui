//
//  MapPolylineView.m
//  MobileXO
//
//  Created by George Giaslas on 7/7/09.
//  Copyright 2009 ATC. All rights reserved.
//



#import "MapPolylineView.h"
#import "MapConstants.h"


@implementation MapPolylineView

- (id)initWithMapView:(MKMapView*)map polyline:(NSArray*)polyline dashed:(BOOL)dashed {
	if ((self = [super initWithFrame:CGRectMake(0, 0, map.frame.size.width, map.frame.size.height)])) {
		// retain map & polyline reference
		iMap = map;
		iPolyline = polyline;
		iDashed = dashed;
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = NO;
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	// only draw our lines if we're not in the moddie of a transition and we
	// acutally have some points to draw.
	if(!self.hidden && iPolyline && [iPolyline count]) {
		CGContextRef context = UIGraphicsGetCurrentContext();
		
		CGContextSetRGBStrokeColor(context, 0.0, 0.0, 1.0, 0.7);
		CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 0.7);
		CGContextSetLineJoin(context, kCGLineJoinRound);
		
		// Set the stroke width depending on the zoom level
		CGContextSetLineWidth(context, iMap.region.span.latitudeDelta < 0.05 ? 4.0 : iMap.region.span.latitudeDelta < 0.1 ? 3.0 : 2.0);
		
		if (iDashed) {
			CGFloat dash1[] = {9.0, 5.0};
			CGFloat dash2[] = {13.0, 7.0};
			CGFloat dash3[] = {17.0, 9.0};
			CGContextSetLineDash(context, 0.0, iMap.region.span.latitudeDelta < 0.05 ? dash3 : iMap.region.span.latitudeDelta < 0.1 ? dash2 : dash1, 2);
		}
		else
			CGContextSetLineCap(context, kCGLineCapRound);

		for(int idx = 0; idx < [iPolyline count]; ++idx) {
			CLLocationCoordinate2D coord;
			coord.latitude = [(NSNumber*)[(NSDictionary*)[iPolyline objectAtIndex:idx] objectForKey:MAP_LATITUDE_KEY] doubleValue];
			coord.longitude = [(NSNumber*)[(NSDictionary*)[iPolyline objectAtIndex:idx] objectForKey:MAP_LONGITUDE_KEY] doubleValue];
			CGPoint point = [iMap convertCoordinate:coord toPointToView:self];
			
			if(idx == 0) {
				// move to the first point
				CGContextMoveToPoint(context, point.x, point.y);
			}
			else {
				CGContextAddLineToPoint(context, point.x, point.y);
			}
		}
		
		CGContextStrokePath(context);
	}
}

@end



