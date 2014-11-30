//
//  PinAnnotationView.m
//  MobileXO
//
//  Created by George Giaslas on 6/24/09.
//  Copyright 2009 ATC. All rights reserved.
//



#import "PinAnnotationView.h"
#import "MapAnnotation.h"


@implementation PinAnnotationView

@synthesize map;


// initialize a non-draggable pin / default type
- (id)initWithAnnotation:(id <MKAnnotation>)annotation {
	return [self initWithAnnotation:annotation pinType:EPinDefault pinIcon:nil accessory:NO accessoryIcon:nil leftIcon:nil draggable:NO selectTarget:nil selectAction:nil];
}

// initialize a non-draggable pin with the specified type
- (id)initWithAnnotation:(id <MKAnnotation>)annotation pinType:(PinType)pintype {
	return [self initWithAnnotation:annotation pinType:pintype pinIcon:nil accessory:NO accessoryIcon:nil leftIcon:nil draggable:NO selectTarget:nil selectAction:nil];
}

// initialize a non-draggable pin with the specified type and accessory
- (id)initWithAnnotation:(id <MKAnnotation>)annotation pinType:(PinType)pintype accessory:(BOOL)accessory leftIcon:(NSString*)leftIcon {
	return [self initWithAnnotation:annotation pinType:pintype pinIcon:nil accessory:accessory accessoryIcon:nil leftIcon:leftIcon draggable:NO selectTarget:nil selectAction:nil];
}

// initialize a non-draggable pin with custom type and accessory
- (id)initWithAnnotation:(id <MKAnnotation>)annotation pinIcon:(NSString*)pinIcon accessoryIcon:(NSString*)accessoryIcon leftIcon:(NSString*)leftIcon {
    return [self initWithAnnotation:annotation pinType:EPinCustom pinIcon:pinIcon accessory:YES accessoryIcon:accessoryIcon leftIcon:leftIcon draggable:NO selectTarget:nil selectAction:nil];
}

// initialize a draggable pin
- (id)initWithAnnotation:(id <MKAnnotation>)annotation pinType:(PinType)pintype accessory:(BOOL)accessory leftIcon:(NSString*)leftIcon draggable:(BOOL)draggable selectTarget:(id)target selectAction:(SEL)action {
    return [self initWithAnnotation:annotation pinType:pintype pinIcon:nil accessory:accessory accessoryIcon:nil leftIcon:leftIcon draggable:draggable selectTarget:target selectAction:action];
}

// initializer
- (id)initWithAnnotation:(id <MKAnnotation>)annotation pinType:(PinType)pintype pinIcon:(NSString*)pinIcon accessory:(BOOL)accessory accessoryIcon:(NSString*)accessoryIcon leftIcon:(NSString*)leftIcon draggable:(BOOL)draggable selectTarget:(id)target selectAction:(SEL)action {
    if ((self = [super initWithAnnotation:annotation reuseIdentifier:@"PinAnnotation"])) {
		// pin settings
		NSString *pinImg;
		switch (pintype) {
            case EPinCustom: pinImg = pinIcon; break;
			case EPinRed: pinImg = @"pin_red.png"; break;
			case EPinPurple: pinImg = @"pin_purple.png"; break;
			case EPinGreen: pinImg = @"pin_green.png"; break;
			case EPinGray: pinImg = @"pin_gray.png"; break;
			case EPinYellow: pinImg = @"pin_yellow.png"; break;
			case EPinCircle: pinImg = @"pin_circle.png"; break;
			case EPinStart: pinImg = @"pin_start.png"; break;
			case EPinEnd: pinImg = @"pin_end.png"; break;
			case EPinBlue: case EPinDefault: default: pinImg = @"pin_blue.png"; break;
		}
		self.image = [UIImage imageNamed:pinImg];
		self.canShowCallout = annotation.title && [annotation.title length];	// show callout if annotation has a title set
        self.multipleTouchEnabled = NO;
		// set a right accessory button if requested
		if (accessory) {
            UIButton *btn;
            if (!accessoryIcon)
                btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            else {
                UIImage *btnImg = [UIImage imageNamed:accessoryIcon];
                btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setImage:btnImg forState:UIControlStateNormal];
                btn.frame = CGRectMake(0, 0, btnImg.size.width, btnImg.size.height);
            }
            self.rightCalloutAccessoryView = btn;
        }
		// set left accessory icon, if available
		if (leftIcon && [leftIcon length] > 0)
			self.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:leftIcon]];
			
		// save selection delegate
		iDraggable = draggable;
		iSelectTarget = target;
		iSelectAction = action;
    }
    return self;
}

// sets the callout and moves the pin
- (void)setCalloutState:(BOOL)dragging updatePosition:(BOOL)updatePos {
	self.canShowCallout = !dragging;
	if (!dragging) {
		[self.map deselectAnnotation:self.annotation animated:NO];
		[self.map selectAnnotation:self.annotation animated:NO];	// !! settings animated to YES causes problems when done with dragging
	}
	else
		[self.map deselectAnnotation:self.annotation animated:NO];
	
	if (updatePos) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		CGPoint p = self.center;
		p.y += (dragging ? -1 : 1)*self.bounds.size.height/2;
		self.center = p;
		[UIView commitAnimations];
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	// inform delegate about selection change
	if (selected && self.map.delegate && [self.map.delegate respondsToSelector:@selector(mapView:selectedAnnotation:)])
		[self.map.delegate performSelector:@selector(mapView:selectedAnnotation:) withObject:self.map withObject:self.annotation];
	[super setSelected:selected animated:animated];
}

// methods for handling user gestures
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (iDraggable) {
		// update callout for dragging
		[self setCalloutState:YES updatePosition:YES];
		
		// The view is configured for single touches only.
		UITouch* aTouch = [touches anyObject];
		iStartLocation = [aTouch locationInView:[self superview]];
		iOriginalCenter = self.center;
	}
	
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (iDraggable) {
		UITouch* aTouch = [touches anyObject];
		CGPoint newLocation = [aTouch locationInView:[self superview]];
		CGPoint newCenter;
		
		// If the user's finger moved more than 5 pixels, begin the drag.
		if ( (abs(newLocation.x - iStartLocation.x) > 5.0) ||
			(abs(newLocation.y - iStartLocation.y) > 5.0) )
			iIsMoving = YES;
		
		// If dragging has begun, adjust the position of the view.
		if (iIsMoving) {
			newCenter.x = iOriginalCenter.x + (newLocation.x - iStartLocation.x);
			newCenter.y = iOriginalCenter.y + (newLocation.y - iStartLocation.y);
			self.center = newCenter;
			return;
		}
	}
	
	[super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {	
//	if (iDraggable) {
//		if (iIsMoving) {
//			// Update the map coordinate to reflect the new position.
//			CGPoint newCenter = self.center;
//			MapAnnotation* theAnnotation = self.annotation;
//			CLLocationCoordinate2D newCoordinate = [self.map convertPoint:newCenter
//															toCoordinateFromView:self.superview];
//			
//			[theAnnotation changeCoordinate:newCoordinate];
//			
//			// inform delegate for location selection
//			if (iSelectTarget)
//				[iSelectTarget performSelector:iSelectAction withObject:[NSNumber numberWithDouble:newCoordinate.latitude] withObject:[NSNumber numberWithDouble:newCoordinate.longitude]];
//			
//			// restore call-out
//			[self setCalloutState:NO updatePosition:NO];
//			
//			// Clean up the state information.
//			iStartLocation = CGPointZero;
//			iOriginalCenter = CGPointZero;
//			iIsMoving = NO;
//			return;
//		}
//		else {
//			// restore call-out
//			[self setCalloutState:NO updatePosition:YES];
//		}
//	}
//	
//	[super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	if (iDraggable) {
		if (iIsMoving) {
			// Move the view back to its starting point.
			self.center = iOriginalCenter;
			
			// restore call-out
			[self setCalloutState:NO updatePosition:NO];
			
			// Clean up the state information.
			iStartLocation = CGPointZero;
			iOriginalCenter = CGPointZero;
			iIsMoving = NO;
			return;
		}
		else {
			// restore call-out
			[self setCalloutState:NO updatePosition:YES];
		}
	}
	
	[super touchesCancelled:touches withEvent:event];
}

@end



