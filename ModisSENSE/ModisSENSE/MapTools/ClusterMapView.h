//
//  ClusterMapView.h
//
//  Created by George Giaslas on 6/24/09.
//  Copyright 2009 ATC. All rights reserved.
//

#ifdef TK_MAP_SUPPORT

#import <MapKit/MapKit.h>
#import "PinAnnotationView.h"
#import "MapPolylineView.h"
#import "MapConstants.h"
#import "REVClusterMap.h"
#import "REVAnnotationsCollection.h"


@protocol ClusterMapViewSelectionDelegate <NSObject>

@optional
-(void) didSelectPin:(MKAnnotationView *)view onMap:(MKMapView *)mapView;
@end


@protocol ClusterMapViewDelegate;

@interface ClusterMapView : REVClusterMapView <MKMapViewDelegate> {
	
@private
	MapPolylineView				*iPolylineView;
	NSArray						*iLocations;
	NSArray						*iPolyline;
	BOOL						iDraggable;
	id							iSelectTarget;
	SEL							iSelectAction;
	double						iSpan;
	CLLocationDegrees           iCenterLatitude;
    CLLocationDegrees           iCenterLongitude;
	NSInteger					iSelectedItemOnLoad;
	BOOL						iLoading;
	BOOL						iCaptureThumbs;
	NSInteger					iCaptureThumbSize;
	NSMutableDictionary			*iCapturedThumbs;
	BOOL						iPolylineDashedLine;
	
}

@property (nonatomic,assign) double span;
@property (nonatomic,assign) CLLocationDegrees centerLatitude;
@property (nonatomic,assign) CLLocationDegrees centerLongitude;
@property (nonatomic,assign) NSInteger selectedItemOnLoad;
@property (nonatomic,assign) id<ClusterMapViewDelegate> gMapDelegate;
@property (nonatomic,assign) id<ClusterMapViewSelectionDelegate> selectionDelegate;
@property (nonatomic,assign) BOOL captureThumbs;
@property (nonatomic,assign) NSInteger captureThumbSize;
@property (nonatomic,assign) BOOL polylineDashedLine;

//Recreates map using existing frame
- (void)reloadMapWithLocations: (NSArray*)locations polyline:(NSArray*)polyline draggable:(BOOL)draggable selectTarget:(id)target selectAction:(SEL)action;

// initializer method for a single fixed pin
- (id)initWithFrame:(CGRect)frame latitude:(CLLocationDegrees)lat longitude:(CLLocationDegrees)lng callout:(NSString*)calloutStr calloutSub:(NSString*)calloutSubStr accessory:(BOOL)accessory pinType:(PinType)type;

// initializer method for a single draggable pin
- (id)initWithFrame:(CGRect)frame latitude:(CLLocationDegrees)lat longitude:(CLLocationDegrees)lng callout:(NSString*)calloutStr calloutSub:(NSString*)calloutSubStr accessory:(BOOL)accessory pinType:(PinType)type draggable:(BOOL)draggable selectTarget:(id)target selectAction:(SEL)action;

// initializer method for multiple fixed pins
- (id)initWithFrame:(CGRect)frame locations:(NSArray*)locations;

// initializer method for multiple fixed pins and a polyline
- (id)initWithFrame:(CGRect)frame locations:(NSArray*)locations polyline:(NSArray*)polyline;

// initializer method for multiple draggable pins and a polyline
- (id)initWithFrame:(CGRect)frame locations:(NSArray*)locations polyline:(NSArray*)polyline draggable:(BOOL)draggable selectTarget:(id)target selectAction:(SEL)action;

// updates the locations displayed
- (void) setLatitude:(CLLocationDegrees)lat longitude:(CLLocationDegrees)lng callout:(NSString*)calloutStr calloutSub:(NSString*)calloutSubStr accessory:(BOOL)accessory pinType:(PinType)type leftIconPath:(NSString*)leftIconPath;
- (void) setLocations:(NSArray*)locations;
- (void) setLocations:(NSArray*)locations polyline:(NSArray*)polyline;
- (void) removeLocations;

// shows the map
- (void)show;
- (void)show: (BOOL)showPins;

// get captured thumb
- (UIImage*) getThumbFor:(NSInteger)tag;

// private methods
- (void) computeRegionToFitLocations;

@end


// Protocol to handle GMap events
@protocol ClusterMapViewDelegate <NSObject>

@optional

// Invoked when an annotation is selected
- (void)accessoryTappedForAnnotation:(NSInteger)tag;

// Invoked when the callout of an annotation is tapped
- (void)selectedAnnotation:(NSInteger)tag;

@end

#endif

