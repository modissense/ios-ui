//
//  SignInViewController.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/15/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "SignInViewController.h"
#import "Engine.h"
#import "Config.h"
#import "AppDelegate.h"
#import "WebViewController.h"
#import "AboutViewController.h"
#import "SVProgressHUD.h"

@interface SignInViewController ()

@end

@implementation SignInViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    [_scroller setContentSize:self.view.frame.size];
//    [_scroller setScrollEnabled:YES];
    
    
    if(![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
        [SVProgressHUD showImage:[UIImage imageNamed:@"location_service"] status:L(NOLOCATIONSERVICES)];
    
    self.title = L(SIGNIN);
    
    self.navigationController.navigationBarHidden = YES;


    if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
        self.bgImageView.image = [UIImage imageNamed:(IS_PHONE5()) ? @"bg-568h@2x.png" : @"bg"];
     else if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        self.bgImageView.image = [UIImage imageNamed:(IS_PHONE5()) ? @"bg_landscape-568h@2x.png" : @"bg_landscape"];
    
    [UIView animateWithDuration:1.0 animations:^() {
        self.bgImageView.alpha = 0.1;
    }];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Orientation delegate

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
//    [_scroller setContentSize:self.view.frame.size];
    
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        self.bgImageView.image = [UIImage imageNamed:(IS_PHONE5()) ? @"bg_landscape-568h@2x.png" : @"bg_landscape"];
    }
    else
    {
        self.bgImageView.image = [UIImage imageNamed:(IS_PHONE5()) ? @"bg-568h@2x.png" : @"bg"];
    }
}

#pragma mark - Sign in to social media

- (IBAction)connectWithTwitter:(id)sender {
    [self connectWithSocial:TWITTER withUserId:@"null"];
}

- (IBAction)connectWithFacebook:(id)sender {
    [self connectWithSocial:FACEBOOK withUserId:@"null"];
}

- (IBAction)connectWithFoursquare:(id)sender {
    [self connectWithSocial:FOURSQUARE withUserId:@"null"];
}

- (void)connectWithSocial:(NSString*)social withUserId:(NSString*)userId {
    
    UserEngine* userEng = [[UserEngine alloc] init];
    [userEng connectWithSocialMedia:social userid:userId];

//    [self openModissense];
}


#pragma mark - Connect to modissense

- (void)openModissense {
    
    //User is considered connected
    Eng.user.connected = YES;
    
    UITabBarController *tabBar = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarID"];
    
    //Give the AppDelegate our tabbarcontroller so we can have access from it
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.modissenseTabController = tabBar;
    
    tabBar.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:tabBar animated:YES completion:nil];
}

- (IBAction)infoButtonClicked:(id)sender {
    
    AboutViewController* aboutVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutViewID"];
    [self.navigationController pushViewController:aboutVC animated:YES];
}
@end
