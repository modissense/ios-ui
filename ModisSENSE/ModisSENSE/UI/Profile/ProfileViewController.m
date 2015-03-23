//
//  ProfileViewController.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/15/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "ProfileViewController.h"
#import "UtilImage.h"
#import "ImageZoom.h"
#import "Config.h"
#import "SVProgressHUD.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //For > ios7
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
        ADJUST_IOS7_LAYOUT

    self.title = L(PROFILE);
    
    UIImageView* bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mapblur"]];
    self.tableView.backgroundView = bgView;
    
    /****************/
    //User avatar
    self.userAvatarImg.layer.masksToBounds = YES;
    self.userAvatarImg.layer.cornerRadius = 50.0;
    [UtilImage loadAsyncImage:self.userAvatarImg fromURL:Eng.user.avatarURL withDefaultImage:@"large-blank-person"];
    
    UITapGestureRecognizer *profileImageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileImageTapped:)];
    profileImageTap.numberOfTapsRequired = 1;
    [self.userAvatarImg addGestureRecognizer:profileImageTap];
    /****************/
        
    UIBarButtonItem* contactBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"contact"] style:UIBarButtonItemStylePlain target:self action:@selector(showContactform)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:contactBarBtn, nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (section==0)
        return 1;
    else
        return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0)
        return L(ACCOUNT);
    else
        return L(ACTIONS);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    NSUInteger section = indexPath.section;
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.font = CELLFONT;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transpbg"]];
    cell.backgroundView.alpha = CELLALPHA;
    
    if (section == 0)
    {
        switch (row)
        {
            case 0:
            {
                cell.textLabel.text = Eng.user.userName;
                cell.imageView.image = [UIImage imageNamed:@"user"];
                break;
            }
        }
        return cell;
    }
    else
    {
        switch (row)
        {
            case 0:
            {
                cell.textLabel.text = L(DELETE_ACCOUNT);
                cell.imageView.image = [UIImage imageNamed:@"remove"];
                break;
            }
            case 1:
            {
                cell.textLabel.text = L(SIGN_OUT);
                cell.imageView.image = [UIImage imageNamed:@"key"];
                break;
            }
                
        }
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1 && indexPath.row==0)       //Delete account
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:L(DELETE_ACCOUNT) message:L(ACCOUNTSWILLBEREMOVED) delegate:self cancelButtonTitle:L(NO) otherButtonTitles:L(YES),nil];
        [alert show];
    }
    
    if (indexPath.section==1 && indexPath.row==1)       //Sign out
    {
        UserEngine* userEng = [[UserEngine alloc] init];
        [userEng signOutUser];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}



#pragma mark - AlertView delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex==1)
    {
        UserEngine* userEng = [[UserEngine alloc] init];
        [userEng deleteUser];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}



#pragma mark - User deleted delegate

-(void)userDeleted {
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - Profile image tapped

-(void) profileImageTapped:(UITapGestureRecognizer *)recognizer {
    
    [ImageZoom showImage:self.userAvatarImg];
}


#pragma mark - Show contact form

-(void)showContactform {
    
    MyLog(@"Email button clicked");
    
    if ([MFMailComposeViewController canSendMail])
    {   //Device is configured to send mail
        
        //Open embeded email client
        MFMailComposeViewController *mailComposerVC = [[MFMailComposeViewController alloc] init];
        
        [mailComposerVC setSubject:@""];
        [mailComposerVC setMessageBody:@"" isHTML:YES];
        
        // Set up recipients
        [mailComposerVC setToRecipients:[NSArray arrayWithObject:CONTACTEMAIL]];
        
        [self.navigationController presentViewController:mailComposerVC animated:YES completion:nil];
        mailComposerVC.mailComposeDelegate = self;
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:L(NOACTIVEMAILACCOUNT)];
    }
}

#pragma mark - Mail view delegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            //            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            //			[SVProgressHUD showErrorWithStatus:L(mailSendingCanceled)];
            break;
        case MFMailComposeResultSaved:
            //            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            //			[SVProgressHUD showSuccessWithStatus:L(mailSendingSaved)];
            break;
        case MFMailComposeResultSent:
            [SVProgressHUD showSuccessWithStatus:L(THANKYOU)];
            break;
        default:
            //            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            //			[SVProgressHUD showErrorWithStatus:L(mailSendingNotSent)];
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
