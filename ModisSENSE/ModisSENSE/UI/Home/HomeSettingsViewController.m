//
//  HomeSettingsViewController.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/15/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "HomeSettingsViewController.h"
#import "SwitchCell.h"
#import "UserSelectionViewController.h"
#import "UIConstants.h"
#import "Engine.h"
#import "SVProgressHUD.h"

@interface HomeSettingsViewController ()

@end

@implementation HomeSettingsViewController

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateMap)]) {
        [self.delegate updateMap];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
        ADJUST_IOS7_LAYOUT
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return L(MAPSETTINGS);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    
    switch (row)
    {
        case 0:
        {
            NSString *CellIdentifier = @"SwitchCell";
            SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
            if (cell == nil)
            {
                cell = [[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
        
            cell.delegate = self;
            cell.textString =  L(SHOW_CURRENT_LOCATION);
            cell.switchState = Eng.preferences.showCurrentLocation;
            cell.tag=row;
        
            return cell;
        }
        case 1:
        {
            NSString *CellIdentifier = @"SwitchCell";
            SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
            if (cell == nil)
            {
                cell = [[SwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
        
            cell.delegate = self;
            cell.textString = L(SHOW_POIS);
            cell.switchState = Eng.preferences.showPointsOfInterest;
            cell.tag=row;
        
            return cell;
        }
        case 2:
        {
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
            if (cell == nil)
            {
                //For the default cells
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
        
            cell.textLabel.text = L(FRIENDSFILTER);
            cell.textLabel.font = CELLFONT;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
            return cell;
        }
        default:
            return nil;
    }
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2)     //Users
    {
        if (Eng.user.twitterFriends.count>0 || Eng.user.facebookFriends.count>0 || Eng.user.foursquareFriends.count>0)
        {
            UserSelectionViewController *userSelection =[self.storyboard instantiateViewControllerWithIdentifier:@"UserSelectionID"];
            userSelection.delegate=self;
            [self.navigationController pushViewController:userSelection animated:YES];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:L(NOFRIENDSAVAILABLE)];
        }
    }
}



#pragma mark - User selection delegate

-(void)updateSelectedUsers {
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchForPOIS)]) {
        [self.delegate searchForPOIS];
    }
}


#pragma mark - Switch Delegate

- (void)tableViewCell:(SwitchCell *)cell switchChangedTo:(BOOL) state {
    if (cell.tag==0)    //Show current location
    {
        Eng.preferences.showCurrentLocation = state;
        [self.tableView reloadData];
    }

    if (cell.tag==1)    //Show interest points locations
    {
        Eng.preferences.showPointsOfInterest = state;
        [self.tableView reloadData];
    }
}

@end