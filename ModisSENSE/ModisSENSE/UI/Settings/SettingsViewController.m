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
    
    self.title = L(SETTINGS);
    
    socialMedia = [[NSArray alloc] initWithObjects:@"Twitter", @"Facebook", @"Foursquare", nil];
    
    selectedMedia = [[NSMutableDictionary alloc] init];
    
    //Retrieve connected accounts from service
    [self getConnectedAccounts];
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
        
        cell.textLabel.font = CELLFONT;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (row==0)
        {
            cell.textLabel.text = L(SOCIALACCOUNTSCONNECTIONS);
            return cell;
        }
        else
        {
            switch (row) {
                case 1:
                    
                    if ([(NSNumber*)[selectedMedia objectForKey:TWITTER] boolValue])
                    {
                        cell.textLabel.text = [socialMedia objectAtIndex:row-1];
                        cell.imageView.image = [UIImage imageNamed:@"checkmark-checked"];
                        UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"remove"]];
                        cell.accessoryView = imageView;
                    }
                    else
                    {
                        cell.textLabel.text = [socialMedia objectAtIndex:row-1];
                        cell.imageView.image = [UIImage imageNamed:@"add"];
                    }
                    
                    break;
                    
                case 2:
                    
                    if ([(NSNumber*)[selectedMedia objectForKey:FACEBOOK] boolValue])
                    {
                        cell.textLabel.text = [socialMedia objectAtIndex:row-1];
                        cell.imageView.image = [UIImage imageNamed:@"checkmark-checked"];
                        UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"remove"]];
                        cell.accessoryView = imageView;
                    }
                    else
                    {
                        cell.textLabel.text = [socialMedia objectAtIndex:row-1];
                        cell.imageView.image = [UIImage imageNamed:@"add"];
                    }
                    
                    break;
                    
                case 3:
                    
                    if ([(NSNumber*)[selectedMedia objectForKey:FOURSQUARE] boolValue])
                    {
                        cell.textLabel.text = [socialMedia objectAtIndex:row-1];
                        cell.imageView.image = [UIImage imageNamed:@"checkmark-checked"];
                        UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"remove"]];
                        cell.accessoryView = imageView;
                    }
                    else
                    {
                        cell.textLabel.text = [socialMedia objectAtIndex:row-1];
                        cell.imageView.image = [UIImage imageNamed:@"add"];
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
    
        if (row==0)     //Connected accounts
        {
//            //Select all
//            for (int i=0;i<socialMedia.count;i++)
//            {
//                [selectedMedia setObject:[NSNumber numberWithBool:YES] forKey:[socialMedia objectAtIndex:i]];
//            }
        }
        else
        {
            switch (row) {
                    
                case 1:
                    
                    if ([(NSNumber*)[selectedMedia objectForKey:TWITTER] boolValue])    //Remove social media
                    {
                        //Remove social account code here
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
                        //Remove social account code here
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
                        //Remove social account code here
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
    }
    
    [self.tableView reloadData];
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
    
    for (int i=0; i<Eng.user.socialAccounts.count ; i++)
    {
        if ([[Eng.user.socialAccounts objectAtIndex:i] isEqualToString:TWITTER])
        {
            [selectedMedia setObject:[NSNumber numberWithBool:YES] forKey:TWITTER];
            NSLog(TWITTER);
        }
        
        if ([[Eng.user.socialAccounts objectAtIndex:i] isEqualToString:FACEBOOK])
        {
            [selectedMedia setObject:[NSNumber numberWithBool:YES] forKey:FACEBOOK];
            NSLog(FACEBOOK);
        }
        
        if ([[Eng.user.socialAccounts objectAtIndex:i] isEqualToString:FOURSQUARE])
        {
            [selectedMedia setObject:[NSNumber numberWithBool:YES] forKey:FOURSQUARE];
            NSLog(FOURSQUARE);
        }
    }
    
    [self.tableView reloadData];
}

@end
