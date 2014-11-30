//
//  GMapView.m
//  MobileXO
//
//  Created by George Giaslas on 6/24/09.
//  Copyright 2009 ATC. All rights reserved.
//

#import "GMapView.h"


@implementation GMapView

@synthesize span = iSpan;
@synthesize centerLatitude = iCenterLatitude;
@synthesize centerLongitude = iCenterLongitude;
@synthesize selectedItemOnLoad = iSelectedItemOnLoad;
@synthesize gMapDelegate;
@synthesize captureThumbs = iCaptureThumbs;
@synthesize captureThumbSize = iCaptureThumbSize;
@synthesize polylineDashedLine = iPolylineDashedLine;

// initializer method for a single fixed pin
- (id)initWithFrame:(CGRect)frame latitude:(CLLocationDegrees)lat longitude:(CLLocationDegrees)lng callout:(NSString*)calloutStr calloutSub:(NSString*)calloutSubStr accessory:(BOOL)accessory pinType:(PinType)type {
	return [self initWithFrame:frame latitude:lat longitude:lng callout:calloutStr calloutSub:calloutSubStr accessory:accessory pinType:type draggable:NO selectTarget:nil selectAction:nil];
}

// initializer method for a single draggable pin
- (id)initWithFrame:(CGRect)frame latitude:(CLLocationDegrees)lat longitude:(CLLocationDegrees)lng callout:(NSString*)calloutStr calloutSub:(NSString*)calloutSubStr accessory:(BOOL)accessory pinType:(PinType)type draggable:(BOOL)draggable selectTarget:(id)target selectAction:(SEL)action {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
												[NSNumber numberWithDouble:lat],		MAP_LATITUDE_KEY,
												[NSNumber numberWithDouble:lng],		MAP_LONGITUDE_KEY,
												calloutStr ? calloutStr : @"",			MAP_CALLOUT_KEY,
												calloutSubStr ? calloutSubStr : @"",	MAP_CALLOUT_SUB_KEY,
												[NSNumber numberWithInt:type],			MAP_PIN_TYPE_KEY,
												[NSNumber numberWithBool:accessory],	MAP_ACCESSORY_KEY,
												nil];
	return [self initWithFrame:frame locations:[NSArray arrayWithObject:dict] polyline:nil draggable:draggable selectTarget:target selectAction:action];
}

// initializer method for multiple fixed pins
- (id)initWithFrame:(CGRect)frame locations:(NSArray*)locations {
	return [self initWithFrame:frame locations:locations polyline:nil draggable:NO selectTarget:nil selectAction:nil];
}

// initializer method for multiple fixed pins and a polyline
- (id)initWithFrame:(CGRect)frame locations:(NSArray*)locations polyline:(NSArray*)polyline {
	return [self initWithFrame:frame locations:locations polyline:polyline draggable:NO selectTarget:nil selectAction:nil];
}

// initializer method for multiple draggable pins and a polyline
- (id)initWithFrame:(CGRect)frame locations:(NSArray*)locations polyline:(NSArray*)polyline draggable:(BOOL)draggable selectTarget:(id)target selectAction:(SEL)action {
	if ((self = [super initWithFrame:frame])) {
		// save the selection delegate
		iDraggable = draggable;
		iSelectTarget = target;
		iSelectAction = action;
		
		// set default values
		iCaptureThumbs = NO;
		iCaptureThumbSize = 40;
		iPolylineDashedLine = NO;
		
		// set locations & polyline to be displayed
		[self setLocations:locations polyline:polyline];
		
		// display user location by default
		self.showsUserLocation = YES;
	}
	return self;
}

- (void)show {
    [self show:YES];
}

- (void)show: (BOOL)showPins {
	// set the center location and span
	MKCoordinateSpan span; span.latitudeDelta = iSpan, span.longitudeDelta = iSpan;	
	MKCoordinateRegion region;
    
    CLLocationCoordinate2D tmpCenter;
    tmpCenter.latitude = iCenterLatitude;
    tmpCenter.longitude = iCenterLongitude;
    
    region.center = tmpCenter;
    
    region.span = span;
	
    self.region = region;
	
	// remove old annotations except for user's location
	NSMutableArray *oldAnnotations = [NSMutableArray arrayWithArray:self.annotations];
	for (int i=0; i<[oldAnnotations count]; ++i)
		if ([[oldAnnotations objectAtIndex:i] class] == MKUserLocation.class) {
			[oldAnnotations removeObjectAtIndex:i];
			break;
		}
	[self removeAnnotations:oldAnnotations];

    
    if (showPins) {
        // create the annotations
        for (NSInteger i=0; i<[iLocations count]; i++) {
            NSDictionary *dict = (NSDictionary*)[iLocations objectAtIndex:i];
            
            NSString *calloutStr = (NSString*)[dict objectForKey:MAP_CALLOUT_KEY];
            if (iDraggable && (!calloutStr || ![calloutStr length]))
                calloutStr = @"Drag to move";
            NSString *calloutSubStr = (NSString*)[dict objectForKey:MAP_CALLOUT_SUB_KEY];
            if (![calloutSubStr length]) calloutSubStr = nil;
            
            NSInteger tag = [dict objectForKey:MAP_TAG_KEY] ? [(NSNumber*)[dict objectForKey:MAP_TAG_KEY] intValue] : 0;
            
            MapAnnotation *annotation = [[MapAnnotation alloc] initWithTitle:calloutStr subTitle:calloutSubStr latitude:[(NSNumber*)[dict objectForKey:MAP_LATITUDE_KEY] doubleValue] longitude:[(NSNumber*)[dict objectForKey:MAP_LONGITUDE_KEY] doubleValue] index:i tag:tag];

            [self addAnnotation:annotation];
        }
    }
	
	// set myself as delegate
	//self.delegate = self;
	
	// create a polyline view if polyline points were specified
	// and add it as a subview of the map view
	if (iPolylineView) [iPolylineView removeFromSuperview], iPolylineView = nil;
	if (iPolyline) {
		iPolylineView = [[MapPolylineView alloc] initWithMapView:self polyline:iPolyline dashed:iPolylineDashedLine];
		[self addSubview:iPolylineView];
	}
}

// updates the locations displayed
- (void) setLatitude:(CLLocationDegrees)lat longitude:(CLLocationDegrees)lng callout:(NSString*)calloutStr calloutSub:(NSString*)calloutSubStr accessory:(BOOL)accessory pinType:(PinType)type leftIconPath:(NSString*)leftIconPath{
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSNumber numberWithDouble:lat],		MAP_LATITUDE_KEY,
						  [NSNumber numberWithDouble:lng],		MAP_LONGITUDE_KEY,
						  calloutStr ? calloutStr : @"",		MAP_CALLOUT_KEY,
						  calloutSubStr ? calloutSubStr : @"",	MAP_CALLOUT_SUB_KEY,
						  [NSNumber numberWithInt:type],		MAP_PIN_TYPE_KEY,
						  [NSNumber numberWithBool:accessory],	MAP_ACCESSORY_KEY,
						  leftIconPath ? leftIconPath : @"",	MAP_LEFT_ICON_KEY,
						  nil];
	return [self setLocations:[NSArray arrayWithObject:dict]];
}

- (void) setLocations:(NSArray*)locations {
	return [self setLocations:locations polyline:nil];
}

- (void) setLocations:(NSArray*)locations polyline:(NSArray*)polyline {
	// save the locations specified
	iLocations = locations ? locations : [NSArray array];
	// save the polyline specified
    iPolyline = polyline;

	// compute region to fit all locations by default
	[self computeRegionToFitLocations];
	
	// by default no selection
	iSelectedItemOnLoad = -1;
}

//Recreates map using existing frame
- (void)reloadMapWithLocations: (NSArray*)locations polyline:(NSArray*)polyline draggable:(BOOL)draggable selectTarget:(id)target selectAction:(SEL)action {
    // save the selection delegate
    iDraggable = draggable;
    iSelectTarget = target;
    iSelectAction = action;
    
    // set default values
    iCaptureThumbs = NO;
    iCaptureThumbSize = 40;
    iPolylineDashedLine = NO;
    
    // set locations & polyline to be displayed
    [self setLocations:locations polyline:polyline];
}

- (void) removeLocations {	
	// release locations & polyline
	iLocations = nil;
	iPolyline = nil;
	
	// keep current center & span
	iCenterLatitude = self.region.center.latitude;
    iCenterLongitude = self.region.center.longitude;
    
	iSpan = MIN(self.region.span.latitudeDelta, self.region.span.longitudeDelta);
	
	// by default no selection
	iSelectedItemOnLoad = -1;
}

- (void) computeRegionToFitLocations {
	if (!iLocations || ![iLocations count]) {
		iCenterLatitude = iCenterLongitude = 0.0;
		iSpan = 180;
		return;
	}
	
	// compute center & span based on the min/max of all pin locations & polyline points
	// minimum span is 0.04	
	double minLat = 1000.0;
	double minLng = 1000.0;
	double maxLat = -1000.0;
	double maxLng = -1000.0;
	for (NSDictionary *dict in iLocations) {
		minLat = MIN(minLat, [(NSNumber*)[dict objectForKey:MAP_LATITUDE_KEY] doubleValue]);
		minLng = MIN(minLng, [(NSNumber*)[dict objectForKey:MAP_LONGITUDE_KEY] doubleValue]);
		maxLat = MAX(maxLat, [(NSNumber*)[dict objectForKey:MAP_LATITUDE_KEY] doubleValue]);
		maxLng = MAX(maxLng, [(NSNumber*)[dict objectForKey:MAP_LONGITUDE_KEY] doubleValue]);
	}
	if (iPolyline)
		for (NSDictionary *dict in iPolyline) {
			minLat = MIN(minLat, [(NSNumber*)[dict objectForKey:MAP_LATITUDE_KEY] doubleValue]);
			minLng = MIN(minLng, [(NSNumber*)[dict objectForKey:MAP_LONGITUDE_KEY] doubleValue]);
			maxLat = MAX(maxLat, [(NSNumber*)[dict objectForKey:MAP_LATITUDE_KEY] doubleValue]);
			maxLng = MAX(maxLng, [(NSNumber*)[dict objectForKey:MAP_LONGITUDE_KEY] doubleValue]);
		}
	iCenterLatitude = minLat + (maxLat - minLat)/2.0;
	iCenterLongitude = minLng + (maxLng - minLng)/2.0;
	double maxDelta = MAX(maxLat - minLat, maxLng - minLng);
	iSpan = MIN(MAX(maxDelta*1.05, 0.02), 180);
}

// get captured thumb
- (UIImage*) getThumbFor:(NSInteger)tag {
	return iCaptureThumbs ? [iCapturedThumbs objectForKey:[NSString stringWithFormat:@"thumb_%d", tag]] : nil;
}

// methods from MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	// !! without this check it crashes if self.showsUserLocation = YES
	if ([annotation class] == MKUserLocation.class) {
        return nil;
    }
	
	// return a pin annotation view
	PinAnnotationView *pin;
	NSInteger pinType = [(NSNumber*)[(NSDictionary*)[iLocations objectAtIndex:((MapAnnotation*)annotation).index] objectForKey:MAP_PIN_TYPE_KEY] intValue];
    NSString *pinIcon = [(NSDictionary*)[iLocations objectAtIndex:((MapAnnotation*)annotation).index] objectForKey:MAP_PIN_ICON_KEY];
	BOOL accessory = [(NSNumber*)[(NSDictionary*)[iLocations objectAtIndex:((MapAnnotation*)annotation).index] objectForKey:MAP_ACCESSORY_KEY] boolValue];
    NSString *accessoryIcon = [(NSDictionary*)[iLocations objectAtIndex:((MapAnnotation*)annotation).index] objectForKey:MAP_ACCESSORY_ICON_KEY];
	NSString *leftIcon = [(NSDictionary*)[iLocations objectAtIndex:((MapAnnotation*)annotation).index] objectForKey:MAP_LEFT_ICON_KEY];

    if (pinIcon && [pinIcon length]) pinType = EPinCustom;
    if (accessoryIcon && [accessoryIcon length]) accessory = YES;

	if (iDraggable)
        pin = [[PinAnnotationView alloc] initWithAnnotation:annotation pinType:pinType pinIcon:pinIcon accessory:accessory accessoryIcon:accessoryIcon leftIcon:leftIcon draggable:YES selectTarget:iSelectTarget selectAction:iSelectAction];
	else
        pin = [[PinAnnotationView alloc] initWithAnnotation:annotation pinType:pinType pinIcon:pinIcon accessory:accessory accessoryIcon:accessoryIcon leftIcon:leftIcon draggable:NO selectTarget:nil selectAction:nil];

	pin.map = mapView;
	return pin;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
	// if capture is enabled, capture the image around each annotation
	// and keep it in the dictionary associated with the annotation's tag
	if (iCaptureThumbs) {
		if (!iCapturedThumbs) iCapturedThumbs = [[NSMutableDictionary alloc] initWithCapacity:[views count]];
		else [iCapturedThumbs removeAllObjects];
		
		for (id v in views)
			if ([v isKindOfClass:[PinAnnotationView class]]) {
				CGPoint center = [self convertCoordinate:[[v annotation] coordinate] toPointToView:self];
				center.y -= [v bounds].size.height / 4;
				CGRect r = CGRectIntegral(CGRectMake(center.x - iCaptureThumbSize/2, center.y - iCaptureThumbSize/2, iCaptureThumbSize, iCaptureThumbSize));
				UIImage *thumb = [self captureView:self rect:r];
				NSInteger tag = ((MapAnnotation*)[v annotation]).tag;
				if (thumb)
					[iCapturedThumbs setObject:thumb forKey:[NSString stringWithFormat:@"thumb_%d", tag]];
			}
	}
	
	// select the desired annotation if set
	// !!! in the annotations there is always the user's location
	if (iSelectedItemOnLoad >= 0) {
		NSMutableArray *oldAnnotations = [NSMutableArray arrayWithArray:mapView.annotations];
		for (int i=0; i<[oldAnnotations count]; ++i)
			if ([[oldAnnotations objectAtIndex:i] class] == MKUserLocation.class) {
				continue;
			}
			// show selected by using our own index (MkMapView doesn't keep the array in the same order we add the annotations
			else if ( ((MapAnnotation*)[oldAnnotations objectAtIndex:i]).index == iSelectedItemOnLoad )
				[mapView selectAnnotation:(MapAnnotation*)[oldAnnotations objectAtIndex:i] animated:YES];
	}
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
	// turn off the polyline view as the map is chaning regions. This prevents
	// the polyline from being displayed at an incorrect position on the map during the
	// transition.
	iPolylineView.hidden = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
	// re-enable and re-poosition the polyline display.
	iPolylineView.hidden = NO;
	[iPolylineView setNeedsDisplay];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	// call the delegate passing the tag of the annotation
	if (self.gMapDelegate && [self.gMapDelegate respondsToSelector:@selector(accessoryTappedForAnnotation:)])
		[self.gMapDelegate accessoryTappedForAnnotation:((MapAnnotation*)view.annotation).tag];
}

// custom delegate method
- (void)mapView:(MKMapView *)mapView selectedAnnotation:(id <MKAnnotation>)annotation {
	// call the delegate passing the tag of the annotation
	if (self.gMapDelegate && [self.gMapDelegate respondsToSelector:@selector(selectedAnnotation:)])
		[self.gMapDelegate selectedAnnotation:((MapAnnotation*)annotation).tag];
}

// called every time the region changes and tiles are loaded
- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
	iLoading = YES;
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
	iLoading = NO;
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
	iLoading = NO;
}

// capture the contents of the view in the rect specified
- (UIImage*)captureView:(UIView*)view rect:(CGRect)rect {
	if (rect.size.width == 0 || rect.size.height == 0)
		rect = view.bounds;
	
	UIGraphicsBeginImageContext(view.bounds.size);
	CGContextClipToRect(UIGraphicsGetCurrentContext(), rect);
	[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *anImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	CGImageRef finalImgRef = CGImageCreateWithImageInRect(anImage.CGImage, rect);
	UIImage *finalImg = [UIImage imageWithCGImage:finalImgRef];
	CGImageRelease(finalImgRef);
	
	return finalImg;
}

@end


