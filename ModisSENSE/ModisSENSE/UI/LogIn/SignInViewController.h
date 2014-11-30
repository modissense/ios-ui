//
//  SignInViewController.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/15/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserEngine.h"

@interface SignInViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scroller;

- (IBAction)connectWithTwitter:(id)sender;
- (IBAction)connectWithFacebook:(id)sender;
- (IBAction)connectWithFoursquare:(id)sender;

- (void)openModissense;

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

- (IBAction)infoButtonClicked:(id)sender;

@end
