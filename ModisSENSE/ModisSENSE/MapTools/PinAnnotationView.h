//
//  PinAnnotationView.h
//  MobileXO
//
//  Created by George Giaslas on 6/24/09.
//  Copyright 2009 ATC. All rights reserved.
//



#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>

typedef enum pinType {
	EPinDefault = 0,
	EPinGreen,
	EPinRed,
	EPinBlue,
	EPinPurple,
	EPinGray,
	EPinYellow,
	EPinCircle,
	EPinStart,
	EPinEnd,
    EPinCustom
} PinType;

@interface PinAnnotationView : MKAnnotationView {

@private
	BOOL iIsMoving;
    CGPoint iStartLocation;
    CGPoint iOriginalCenter;
	
	BOOL iDraggable;
	id iSelectTarget;
	SEL iSelectAction;

}

@property (nonatomic, assign) MKMapView* map;

// initialize a non-draggable pin / default type
- (id)initWithAnnotation:(id <MKAnnotation>)annotation;

// initialize a non-draggable pin with the specified type
- (id)initWithAnnotation:(id <MKAnnotation>)annotation pinType:(PinType)pintype;

// initialize a non-draggable pin with the specified type and accessory
- (id)initWithAnnotation:(id <MKAnnotation>)annotation pinType:(PinType)pintype accessory:(BOOL)accessory leftIcon:(NSString*)leftIcon;

// initialize a non-draggable pin with custom type and accessory
- (id)initWithAnnotation:(id <MKAnnotation>)annotation pinIcon:(NSString*)pinIcon accessoryIcon:(NSString*)accessoryIcon leftIcon:(NSString*)leftIcon;

// initialize a draggable pin
- (id)initWithAnnotation:(id <MKAnnotation>)annotation pinType:(PinType)pintype accessory:(BOOL)accessory leftIcon:(NSString*)leftIcon draggable:(BOOL)draggable selectTarget:(id)target selectAction:(SEL)action;

// private method
- (id)initWithAnnotation:(id <MKAnnotation>)annotation pinType:(PinType)pintype pinIcon:(NSString*)pinIcon accessory:(BOOL)accessory accessoryIcon:(NSString*)accessoryIcon leftIcon:(NSString*)leftIcon draggable:(BOOL)draggable selectTarget:(id)target selectAction:(SEL)action;

@end



