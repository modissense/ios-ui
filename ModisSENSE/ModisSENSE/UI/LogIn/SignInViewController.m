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
    
    
    //For ios7
//    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
//        ADJUST_IOS7_LAYOUT
    
    if(![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:L(CAUTION)
                                                        message:L(NOLOCATIONSERVICES)
                                                        delegate:self
                                                        cancelButtonTitle:L(GOTIT)
                                                        otherButtonTitles:nil];
        
        [alertView show];
    }
    
    UIBarButtonItem *iBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"info"] style:UIBarButtonItemStylePlain target:self action:@selector(showInfo)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:iBtn, nil];
    
    self.title = L(SIGNIN);
    self.chooseLabel.text = L(CHOOSE);
    
    //Blur content under modissense label
    UIToolbar* bgBlur = [[UIToolbar alloc] initWithFrame:self.modissenseLabel.frame];
    bgBlur.barStyle = UIBarStyleBlack;
    [self.modissenseLabel.superview insertSubview:bgBlur belowSubview:self.modissenseLabel];

    if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
        self.bgImageView.image = [UIImage imageNamed:(IS_PHONE5()) ? @"bg-568h@2x.png" : @"bg"];
     else if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        self.bgImageView.image = [UIImage imageNamed:(IS_PHONE5()) ? @"bg_landscape-568h@2x.png" : @"bg_landscape"];
    
    //Blur content under bottom view
    UIToolbar* bgToolbar = [[UIToolbar alloc] initWithFrame:self.bottomView.frame];
    bgToolbar.barStyle = UIBarStyleBlack;
    [self.bottomView.superview insertSubview:bgToolbar belowSubview:self.bottomView];

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

-(void)showInfo {
    
    AboutViewController* aboutVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutViewID"];
    [self.navigationController pushViewController:aboutVC animated:YES];
}
@end
