//
//  UserSelectionViewController.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/12/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "UserSelectionViewController.h"
#import "Engine.h"
#import "UIConstants.h"
#import "Friend.h"

@interface UserSelectionViewController () {
    
    NSArray* twitterFriends;
    NSArray* facebookFriends;
    NSArray* foursquareFriends;
}

@end

@implementation UserSelectionViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
        ADJUST_IOS7_LAYOUT

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.title = L(FRIENDS);

    
    //Enabling the refresh control for the tableview
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor lightGrayColor];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:L(PULLTOREFRESHFRIENDS)];
    
    //Add a function that will be called when refreshing ends
    [self.refreshControl addTarget:self action:@selector(refreshFriends:) forControlEvents:UIControlEventValueChanged];
    
    
    twitterFriends = Eng.user.twitterFriends;
    facebookFriends = Eng.user.facebookFriends;
    foursquareFriends = Eng.user.foursquareFriends;
    
    [self.tableView reloadData];
}


-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateSelectedUsers)]) {
        [self.delegate updateSelectedUsers];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;   //3+1 (select all)
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (section==1)                     //twitter users
        return twitterFriends.count;
    else if (section==2)                //facebook users
        return facebookFriends.count;
    else if (section==3)                //foursquare users
        return foursquareFriends.count;
    else                                //Select all
        return 4;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        if (twitterFriends.count>0)
            return @"Twitter";
        else
            return nil;
    }
    else if (section == 2)
    {
        if (facebookFriends.count>0)
            return @"Facebook";
        else
            return nil;
    }
    else if (section == 3)
    {
        if (foursquareFriends.count>0)
            return @"FourSquare";
        else
            return nil;
    }
    else
        return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.font = CELLFONT;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.accessoryType = 0;
    cell.selectionStyle=0;
    
    switch (indexPath.section)
    {
        case 0:                         //Select all
        {
            if (indexPath.row==0)
            {
                cell.imageView.image = [UIImage imageNamed:@"twitter"];
                
                if (twitterFriends.count>0)
                {
                    cell.textLabel.text = L(SELECTALLTWITTERFRIENDS);
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                else
                {
                    cell.textLabel.text = L(NOTWITTERFRIENDSAVAILABLE);
                    cell.textLabel.textColor = [UIColor redColor];
                    cell.accessoryType = 0;
                }
            }
            else if (indexPath.row==1)
            {
                cell.imageView.image = [UIImage imageNamed:@"facebook"];
                
                if (facebookFriends.count>0)
                {
                    cell.textLabel.text = L(SELECTALLFACEBOOKFRIENDS);
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                else
                {
                    cell.textLabel.text = L(NOFACEBOOKFRIENDSAVAILABLE);
                    cell.textLabel.textColor = [UIColor redColor];
                    cell.accessoryType = 0;
                }
            }
            else if (indexPath.row==2)
            {
                cell.imageView.image = [UIImage imageNamed:@"foursquare"];
                
                if (foursquareFriends.count>0)
                {
                    cell.textLabel.text = L(SELECTALLFOURSQUAREFRIENDS);
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                else
                {
                    cell.textLabel.text = L(NOFOURSQUAREFRIENDSAVAILABLE);
                    cell.textLabel.textColor = [UIColor redColor];
                    cell.accessoryType = 0;
                }
            }
            else
            {
                cell.imageView.image = [UIImage imageNamed:@"trash"];
                cell.textLabel.text = L(EMPTYSELECTIONS);
                cell.textLabel.textColor = CELLGRAYCOLOR;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            break;
        }
        case 1:                         //twitter users
        {
            Friend* friend = [twitterFriends objectAtIndex:indexPath.row];
            
            cell.textLabel.text = friend.name;
            cell.imageView.image = nil;
            
            if ([Eng.preferences.selectedTwitterUsers objectForKey:friend.name])
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            else
                cell.accessoryType = 0;
                
            break;
        }
        case 2:                         //facebook users
        {
            Friend* friend = [facebookFriends objectAtIndex:indexPath.row];
            
            cell.textLabel.text = friend.name;
            cell.imageView.image = nil;
            
            if ([Eng.preferences.selectedFacebookUsers objectForKey:friend.name])
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            else
                cell.accessoryType = 0;
            
            break;
        }
        case 3:                         //foursquare users
        {
            Friend* friend = [foursquareFriends objectAtIndex:indexPath.row];
            
            cell.textLabel.text = friend.name;
            cell.imageView.image = nil;
            
            if ([Eng.preferences.selectedFoursquareUsers objectForKey:friend.name])
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            else
                cell.accessoryType = 0;
            
            break;
        }
        default:
            break;
    }
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        {
            if (indexPath.row==0)
            {
                for (Friend* friend in twitterFriends)
                {
                    [Eng.preferences.selectedTwitterUsers setObject:friend forKey:friend.name];
                    [Eng.preferences.selectedFriendIDs addObject:friend.friendId];
                }
            }
            else if (indexPath.row==1)
            {
                for (Friend* friend in facebookFriends)
                {
                    [Eng.preferences.selectedFacebookUsers setObject:friend forKey:friend.name];
                    [Eng.preferences.selectedFriendIDs addObject:friend.friendId];
                }
            }
            else if (indexPath.row==2)
            {
                for (Friend* friend in foursquareFriends)
                {
                    [Eng.preferences.selectedFoursquareUsers setObject:friend forKey:friend.name];
                    [Eng.preferences.selectedFriendIDs addObject:friend.friendId];
                }
            }
            else
            {
                for (Friend* friend in twitterFriends)
                {
                    [Eng.preferences.selectedTwitterUsers removeObjectForKey:friend.name];
                    [Eng.preferences.selectedFriendIDs removeObject:friend.friendId];
                }
                
                for (Friend* friend in facebookFriends)
                {
                    [Eng.preferences.selectedFacebookUsers removeObjectForKey:friend.name];
                    [Eng.preferences.selectedFriendIDs removeObject:friend.friendId];
                }
                
                for (Friend* friend in foursquareFriends)
                {
                    [Eng.preferences.selectedFoursquareUsers removeObjectForKey:friend.name];
                    [Eng.preferences.selectedFriendIDs removeObject:friend.friendId];
                }
            }
            
            break;
        }
        case 1:                         //twitter users
            if ([Eng.preferences.selectedTwitterUsers objectForKey:((Friend*)[twitterFriends objectAtIndex:indexPath.row]).name])    //If it's selected, unselect it
            {
                [Eng.preferences.selectedTwitterUsers removeObjectForKey:((Friend*)[twitterFriends objectAtIndex:indexPath.row]).name];
                [Eng.preferences.selectedFriendIDs removeObject:((Friend*)[twitterFriends objectAtIndex:indexPath.row]).friendId];
            }
            else
            {
                [Eng.preferences.selectedTwitterUsers setObject:((Friend*)[twitterFriends objectAtIndex:indexPath.row]) forKey:((Friend*)[twitterFriends objectAtIndex:indexPath.row]).name];
                [Eng.preferences.selectedFriendIDs addObject:((Friend*)[twitterFriends objectAtIndex:indexPath.row]).friendId];
            }
            break;
            
        case 2:                         //facebook users
            if ([Eng.preferences.selectedFacebookUsers objectForKey:((Friend*)[facebookFriends objectAtIndex:indexPath.row]).name])    //If it's selected, unselect it
            {
                [Eng.preferences.selectedFacebookUsers removeObjectForKey:((Friend*)[facebookFriends objectAtIndex:indexPath.row]).name];
                [Eng.preferences.selectedFriendIDs removeObject:((Friend*)[facebookFriends objectAtIndex:indexPath.row]).friendId];
            }
            else
            {
                [Eng.preferences.selectedFacebookUsers setObject:((Friend*)[facebookFriends objectAtIndex:indexPath.row]) forKey:((Friend*)[facebookFriends objectAtIndex:indexPath.row]).name];
                [Eng.preferences.selectedFriendIDs addObject:((Friend*)[facebookFriends objectAtIndex:indexPath.row]).friendId];
            }
            break;
            
        case 3:                         //foursquare users
            if ([Eng.preferences.selectedFoursquareUsers objectForKey:((Friend*)[foursquareFriends objectAtIndex:indexPath.row]).name])    //If it's selected, unselect it
            {
                [Eng.preferences.selectedFoursquareUsers removeObjectForKey:((Friend*)[foursquareFriends objectAtIndex:indexPath.row]).name];
                [Eng.preferences.selectedFriendIDs removeObject:((Friend*)[foursquareFriends objectAtIndex:indexPath.row]).friendId];
            }
            else
            {
                [Eng.preferences.selectedFoursquareUsers setObject:((Friend*)[foursquareFriends objectAtIndex:indexPath.row]) forKey:((Friend*)[foursquareFriends objectAtIndex:indexPath.row]).name];
                [Eng.preferences.selectedFriendIDs addObject:((Friend*)[foursquareFriends objectAtIndex:indexPath.row]).friendId];
            }
            break;
            
        default:
            break;
    }
    
    [self.tableView reloadData];
}



#pragma mark - Refresh friends

-(void)refreshFriends:(UIRefreshControl*)refresh {
    [self getFriends];
}


- (void)getFriends {
    
    UserEngine* userEng = [[UserEngine alloc] init];
    userEng.delegate=self;
    [userEng getFriendsForUser:Eng.user.userId];
}

//Delegate
- (void)gotFriends {
    
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}
@end
