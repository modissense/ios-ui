//
//  SettingsViewController.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/12/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "SettingsViewController.h"
#import "SwitchCell.h"
#import "UIConstants.h"
#import "Engine.h"
#import "Config.h"

@interface SettingsViewController () {
    NSMutableDictionary *selectedMedia;
    NSArray* socialMedia;
}

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //For ios7
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
        ADJUST_IOS7_LAYOUT
        
    UIImageView* bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mapblur"]];
    self.tableView.backgroundView = bgView;
    
    self.title = L(SETTINGS);
    
    self.newSocialMediaLoaded = NO;
    
    socialMedia = [[NSArray alloc] initWithObjects:@"Twitter", @"Facebook", @"Foursquare", nil];
    
    selectedMedia = [[NSMutableDictionary alloc] init];
    
    //Retrieve connected accounts from service
    if (Eng.user.socialAccounts == nil)
        [self getConnectedAccounts];
    else
        [self gotConnectedAccounts];
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
    
    if (section == 0)
        return 1;
    else
        return socialMedia.count+1;    //Social Media + the title cell
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    NSUInteger section = indexPath.section;

    if (section == 0)
    {
        NSString *CellIdentifier = @"SwitchCell";
        SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transpbg"]];
        cell.backgroundView.alpha = CELLALPHA;
        
        cell.delegate = self;
        cell.textString = L(TRACK_POSITION);
        cell.switchState = Eng.preferences.trackUserPosition;
        
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transpbg"]];
        cell.backgroundView.alpha = CELLALPHA;
        
        cell.textLabel.font = CELLFONT;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (row==0)
        {
            cell.textLabel.text = L(SOCIALACCOUNTSCONNECTIONS);
            return cell;
        }
        else
        {
            NSString* mainSocial = [socialMedia objectAtIndex:row-1];
            mainSocial = [mainSocial lowercaseString];
            
            switch (row) {
                case 1:
                    
                    cell.imageView.image = [UIImage imageNamed:@"twitter_login"];
                    
                    //Check if this is the main account
                    if ([Eng.user.mainAccount isEqualToString:mainSocial])
                    {
                        cell.textLabel.text = [socialMedia objectAtIndex:row-1];
                        UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user"]];
                        cell.accessoryView = imageView;
                    }
                    else
                    {
                        if ([(NSNumber*)[selectedMedia objectForKey:TWITTER] boolValue])
                        {
                            cell.textLabel.text = [socialMedia objectAtIndex:row-1];
                            UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"remove"]];
                            cell.accessoryView = imageView;
                        }
                        else
                        {
                            cell.textLabel.text = [socialMedia objectAtIndex:row-1];
                            
                            UIImageView* check = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"red_add"]];
                            cell.accessoryView = check;
                        }
                    }
                    
                    break;
                    
                case 2:
                    
                    cell.imageView.image = [UIImage imageNamed:@"facebook_login"];
                    
                    //Check if this is the main account
                    if ([Eng.user.mainAccount isEqualToString:mainSocial])
                    {
                        cell.textLabel.text = [socialMedia objectAtIndex:row-1];
                        UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user"]];
                        cell.accessoryView = imageView;
                    }
                    else
                    {
                        if ([(NSNumber*)[selectedMedia objectForKey:FACEBOOK] boolValue])
                        {
                            cell.textLabel.text = [socialMedia objectAtIndex:row-1];
                            UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"remove"]];
                            cell.accessoryView = imageView;
                        }
                        else
                        {
                            cell.textLabel.text = [socialMedia objectAtIndex:row-1];
                            
                            UIImageView* check = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"red_add"]];
                            cell.accessoryView = check;
                        }
                    }
                    
                    break;
                    
                case 3:
                    
                    cell.imageView.image = [UIImage imageNamed:@"foursquare_login"];
                    
                    //Check if this is the main account
                    if ([Eng.user.mainAccount isEqualToString:mainSocial])
                    {
                        cell.textLabel.text = [socialMedia objectAtIndex:row-1];
                        UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user"]];
                        cell.accessoryView = imageView;
                    }
                    else
                    {
                        if ([(NSNumber*)[selectedMedia objectForKey:FOURSQUARE] boolValue])
                        {
                            cell.textLabel.text = [socialMedia objectAtIndex:row-1];
                            UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"remove"]];
                            cell.accessoryView = imageView;
                        }
                        else
                        {
                            cell.textLabel.text = [socialMedia objectAtIndex:row-1];
                            
                            UIImageView* check = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"red_add"]];
                            cell.accessoryView = check;
                        }
                    }
                    
                    break;
                    
                default:
                    break;
            }
            
            return cell;
        }
    }
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1)
    {
        NSUInteger row = indexPath.row;
        
        NSString* mainSocial = [socialMedia objectAtIndex:row-1];
        mainSocial = [mainSocial lowercaseString];
        
        switch (row) {
                
            case 1:
                
                if ([(NSNumber*)[selectedMedia objectForKey:TWITTER] boolValue])    //Remove social media
                {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:L(REMOVETWITTER)
                                                                        message:L(AREYOUSURE)
                                                                       delegate:self
                                                              cancelButtonTitle:L(NO)
                                                              otherButtonTitles:L(YES), nil];
                    alertView.tag = row;
                    [alertView show];
                }
                else                                                                //Add social media
                {
                    UserEngine* userEng = [[UserEngine alloc] init];
                    [userEng connectWithSocialMedia:TWITTER userid:Eng.user.userId];
                }
                
                break;
                
            case 2:
                
                if ([(NSNumber*)[selectedMedia objectForKey:FACEBOOK] boolValue])    //Remove social media
                {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:L(REMOVEFACEBOOK)
                                                                        message:L(AREYOUSURE)
                                                                       delegate:self
                                                              cancelButtonTitle:L(NO)
                                                              otherButtonTitles:L(YES), nil];
                    alertView.tag = row;
                    [alertView show];
                }
                else                                                                 //Add social media
                {
                    UserEngine* userEng = [[UserEngine alloc] init];
                    [userEng connectWithSocialMedia:FACEBOOK userid:Eng.user.userId];
                }
                
                break;
                
            case 3:
                
                if ([(NSNumber*)[selectedMedia objectForKey:FOURSQUARE] boolValue])    //Remove social mediat
                {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:L(REMOVEFOURSQUARE)
                                                                        message:L(AREYOUSURE)
                                                                       delegate:self
                                                              cancelButtonTitle:L(NO)
                                                              otherButtonTitles:L(YES), nil];
                    alertView.tag = row;
                    [alertView show];
                }
                else                                                                   //Add social media
                {
                    UserEngine* userEng = [[UserEngine alloc] init];
                    [userEng connectWithSocialMedia:FOURSQUARE userid:Eng.user.userId];
                }
                
                break;
                
            default:
                break;
        }
    }
    
    [self.tableView reloadData];
}



#pragma mark - AlertView delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex==1)
    {
        NSString* mainSocial = [socialMedia objectAtIndex:alertView.tag-1];
        mainSocial = [mainSocial lowercaseString];
        
        switch (alertView.tag-1) {
            case 0:
                
                //Check if this is the main account. Cannot delete main account
                if (![Eng.user.mainAccount isEqualToString:mainSocial])
                {
                    UserEngine* userEng = [[UserEngine alloc] init];
                    userEng.delegate = self;
                    [userEng removeSocialAccount:TWITTER];
                }
                else
                {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                        message:L(CANNOTDELETEMAINACCOUNT)
                                                                       delegate:self
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                    [alertView show];
                }
                
                break;
                
            case 1:
                
                //Check if this is the main account. Cannot delete main account
                if (![Eng.user.mainAccount isEqualToString:mainSocial])
                {
                    UserEngine* userEng = [[UserEngine alloc] init];
                    userEng.delegate = self;
                    [userEng removeSocialAccount:FACEBOOK];
                }
                else
                {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                        message:L(CANNOTDELETEMAINACCOUNT)
                                                                       delegate:self
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                    [alertView show];
                }
                
                break;
                
            case 2:
                
                //Check if this is the main account. Cannot delete main account
                if (![Eng.user.mainAccount isEqualToString:mainSocial])
                {
                    UserEngine* userEng = [[UserEngine alloc] init];
                    userEng.delegate = self;
                    [userEng removeSocialAccount:FOURSQUARE];
                }
                else
                {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                        message:L(CANNOTDELETEMAINACCOUNT)
                                                                       delegate:self
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                    [alertView show];
                }
                
                break;
            default:
                break;
        }
    }
}


#pragma mark - Switch Delegate

//Track user's position
- (void)tableViewCell:(SwitchCell *)cell switchChangedTo:(BOOL)state {

    Eng.preferences.trackUserPosition = state;
    [self.tableView reloadData];
    
    if (!state)     //User terminated the location tracker
    {
        [Eng.locationTracker stop];
        MyLog(@"ModisSENSE location tracker deactivated !\n\n");
    }
    else            //User re-opened the location tracker
    {
        [Eng.locationTracker startLocationTracker:TRACINGBLOG];
        MyLog(@"ModisSENSE location tracker re-activated !\n\n");
    }
    
    [self showTrackingLabelWithState:state];
}


-(void) showTrackingLabelWithState:(BOOL)state {
    
    UILabel *infoLabel;
    infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 30, self.view.frame.size.width,15)];
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.numberOfLines = 0;
    infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.textColor = [UIColor blackColor];
    infoLabel.font = [UIFont systemFontOfSize:13];
    infoLabel.alpha = 0.0;
    
    if (state)
        infoLabel.text = L(POSITIONTRACKINGACTIVATED);
    else
        infoLabel.text = L(POSITIONTRACKINGDEACTIVATED);
    
    [self.view addSubview:infoLabel];
    
    [self.view bringSubviewToFront:infoLabel];
    
    [UIView animateWithDuration:0.5 animations:^{
        infoLabel.layer.opacity = 1.0;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:2.0 animations:^{
            infoLabel.layer.opacity = 0.0;
        } completion:^(BOOL finished){
            [infoLabel removeFromSuperview];
        }];
    }];
}


#pragma mark - Social account removal delegate

- (void)accountRemoved {
    [self getFriends];
}


#pragma mark - Get friends call & delegate

- (void)getFriends {
    
    UserEngine* userEng = [[UserEngine alloc] init];
    userEng.delegate=self;
    [userEng getFriendsForUser:Eng.user.userId showLoader:YES];
}

//Delegate
- (void)gotFriends {
    [self getConnectedAccounts];
}


#pragma mark - Get connected accounts call & delegate

- (void)getConnectedAccounts {
    
    UserEngine* userEng = [[UserEngine alloc] init];
    userEng.delegate=self;
    [userEng getConnectedAccountsFromUser:Eng.user.userId];
}


//Delegate
//Set selected media to show on table
- (void)gotConnectedAccounts {
    
    NSLog(@"Connected accounts:");
    
    if (Eng.user.socialAccounts.count==0)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    if (selectedMedia)
        [selectedMedia removeAllObjects];

    if ([Eng.user.socialAccounts indexOfObject:TWITTER] != NSNotFound) {
        [selectedMedia setObject:[NSNumber numberWithBool:YES] forKey:TWITTER];
        NSLog(TWITTER);
    }
    
    if ([Eng.user.socialAccounts indexOfObject:FACEBOOK] != NSNotFound) {
        [selectedMedia setObject:[NSNumber numberWithBool:YES] forKey:FACEBOOK];
        NSLog(FACEBOOK);
    }
    
    if ([Eng.user.socialAccounts indexOfObject:FOURSQUARE] != NSNotFound) {
        [selectedMedia setObject:[NSNumber numberWithBool:YES] forKey:FOURSQUARE];
        NSLog(FOURSQUARE);
    }
    
    [self.tableView reloadData];
    
    if (self.newSocialMediaLoaded)
    {
        //Refresh friends
        UserEngine* userEng = [[UserEngine alloc] init];
        [userEng getFriendsForUser:Eng.user.userId showLoader:YES];
        self.newSocialMediaLoaded = NO;
    }
}

@end
