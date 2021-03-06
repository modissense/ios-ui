//
//  ProfileViewController.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/15/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserEngine.h"
#import "UIConstants.h"
#import "Engine.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface ProfileViewController : UITableViewController <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userAvatarImg;

@end
