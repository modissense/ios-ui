//
//  PickLocationViewController.m
//  Agrotypos
//
//  Created by mac1 on 11/8/12.
//  Copyright (c) 2012 mac1. All rights reserved.
//

#import "PickLocationViewController.h"
#import "Engine.h"
#import "UIConstants.h"

@interface PickLocationViewController () {
    UIImageView *pinImageView;
    UIView* info;
}

@end

@implementation PickLocationViewController

@synthesize delegate;
@synthesize mapView = iMapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.title = L(CHOOSE);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //iOS7
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
        ADJUST_IOS7_LAYOUT
    
    self.view.backgroundColor = [UIColor clearColor];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:L(DONE) style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    self.navigationItem.rightBarButtonItems = @[doneBtn];
    
    
    if (self.showPin == YES)
    {
        iMapView = [[GMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) latitude:self.location.coordinate.latitude longitude:self.location.coordinate.longitude callout:L(YOUAREHERE) calloutSub:nil accessory:YES pinType:1 draggable:NO selectTarget:nil selectAction:nil];
        iMapView.showsUserLocation = YES;
        
        
        UIImage *pinImage = [UIImage imageNamed:@"pin_start"];
        pinImageView = [[UIImageView alloc] initWithFrame:CGRectMake(iMapView.frame.size.width / 2 - 33, iMapView.frame.size.height / 2 - 64 - 15, 64, 64)];
        pinImageView.image = pinImage;
        
        [iMapView addSubview: pinImageView];
    }
    else
    {
        //Initialize the map
        iMapView = [[GMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) latitude:Eng.locationTracker.currentlocation.coordinate.latitude longitude:Eng.locationTracker.currentlocation.coordinate.longitude callout:L(YOUAREHERE) calloutSub:nil accessory:YES pinType:1 draggable:NO selectTarget:nil selectAction:nil];
        iMapView.showsUserLocation = YES;
        
        info = [[UIView alloc] initWithFrame:CGRectMake(iMapView.frame.size.width-164,60, 160,90)];
        info.backgroundColor = [UIColor whiteColor];
        info.layer.opacity = 1.0;
        
        CALayer * infoLayer = info.layer;
        [infoLayer setMasksToBounds:YES];
        [infoLayer setCornerRadius:5.0];
        
        UIImageView* pinchImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pinch"]];
        pinchImg.frame = CGRectMake(info.frame.size.width/2-10, 5, 20, 20);
        
        UILabel *infoLabel;
        infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 15,info.frame.size.width-10,info.frame.size.height-10)];
        infoLabel.backgroundColor = [UIColor clearColor];
        infoLabel.numberOfLines = 0;
        infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
        infoLabel.textAlignment = NSTextAlignmentCenter;
        infoLabel.textColor = [UIColor blackColor];
        infoLabel.font = [UIFont systemFontOfSize:13];
        infoLabel.text = L(SELECTARECTAREA);
        
        [info addSubview:pinchImg];
        [info addSubview:infoLabel];
        
        [iMapView addSubview: info];
        
        
        [UIView animateWithDuration:1.0 animations:^{
            info.frame = CGRectMake(iMapView.frame.size.width-164,5, 160,90);
        }];
        
        [UIView animateWithDuration:30.0 animations:^{
            info.layer.opacity = 0.0;
        }];
    }
    
    [iMapView setDelegate:self];
    
    [iMapView show:NO];
    self.view = iMapView;
}


-(void)done:(id)sender {
    
    if (delegate && [delegate respondsToSelector:@selector(didEndEditingWithCoordinates:)]) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:iMapView.region.center.latitude longitude:iMapView.region.center.longitude];
		[delegate didEndEditingWithCoordinates:location];
	}
    
    if (delegate && [delegate respondsToSelector:@selector(didEndEditingWithRegion:)]) {
		[delegate didEndEditingWithRegion:iMapView.region];
	}
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    }

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (infoView)
        [infoView removeFromSuperview];
    
//    [iMapView removeFromSuperview];
//    iMapView = nil;
}



#pragma mark - Orientation delegate

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (self.showPin == YES)
    {
        pinImageView.frame = CGRectMake(self.view.frame.size.width / 2 - 33, self.view.frame.size.height / 2 - 32, 64, 64);
    }
    else
    {
        info.frame = CGRectMake(iMapView.frame.size.width-164,5, 160,70);
    }
}

@end
