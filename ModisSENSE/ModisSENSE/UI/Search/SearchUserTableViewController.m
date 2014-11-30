//
//  SearchUserTableViewController.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 9/4/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "SearchUserTableViewController.h"
#import "Engine.h"
#import "UIConstants.h"
#import "Friend.h"

@interface SearchUserTableViewController () {
    
    NSArray* twitterFriends;
    NSArray* facebookFriends;
    NSArray* foursquareFriends;
    
    NSMutableDictionary *selectedTwitterUsers;
    NSMutableDictionary *selectedFacebookUsers;
    NSMutableDictionary *selectedFoursquareUsers;
}

@end

@implementation SearchUserTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:L(DONE) style:UIBarButtonItemStylePlain target:self action:@selector(doneSelectingFriends)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.title = L(FRIENDS);
    
    twitterFriends = [NSArray arrayWithArray:Eng.user.twitterFriends];
    facebookFriends = [NSArray arrayWithArray:Eng.user.facebookFriends];
    foursquareFriends = [NSArray arrayWithArray:Eng.user.foursquareFriends];
    
    selectedTwitterUsers = [[NSMutableDictionary alloc] init];
    selectedFacebookUsers = [[NSMutableDictionary alloc] init];
    selectedFoursquareUsers = [[NSMutableDictionary alloc] init];
    
    //Check who's selected if any
    for (int i=0 ; i<twitterFriends.count ; i++)
    {
        Friend* f = [twitterFriends objectAtIndex:i];
        
        for (int j=0 ; j<self.selectedFriendIDs.count ; j++)
        {
            if ([f.friendId isEqualToString:[self.selectedFriendIDs objectAtIndex:j]])
                [selectedTwitterUsers setObject:((Friend*)[twitterFriends objectAtIndex:i]) forKey:((Friend*)[twitterFriends objectAtIndex:i]).name];
        }
    }
    
    for (int i=0 ; i<facebookFriends.count ; i++)
    {
        Friend* f = [facebookFriends objectAtIndex:i];
        
        for (int j=0 ; j<self.selectedFriendIDs.count ; j++)
        {
            if ([f.friendId isEqualToString:[self.selectedFriendIDs objectAtIndex:j]])
                [selectedFacebookUsers setObject:((Friend*)[facebookFriends objectAtIndex:i]) forKey:((Friend*)[facebookFriends objectAtIndex:i]).name];
        }
    }
    
    for (int i=0 ; i<foursquareFriends.count ; i++)
    {
        Friend* f = [foursquareFriends objectAtIndex:i];
        
        for (int j=0 ; j<self.selectedFriendIDs.count ; j++)
        {
            if ([f.friendId isEqualToString:[self.selectedFriendIDs objectAtIndex:j]])
                [selectedFoursquareUsers setObject:((Friend*)[foursquareFriends objectAtIndex:i]) forKey:((Friend*)[foursquareFriends objectAtIndex:i]).name];
        }
    }
    
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
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
            
            if ([selectedTwitterUsers objectForKey:friend.name])
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
            
            if ([selectedFacebookUsers objectForKey:friend.name])
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
            
            if ([selectedFoursquareUsers objectForKey:friend.name])
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
                    [selectedTwitterUsers setObject:friend forKey:friend.name];
                    [self.selectedFriendIDs addObject:friend.friendId];
                }
            }
            else if (indexPath.row==1)
            {
                for (Friend* friend in facebookFriends)
                {
                    [selectedFacebookUsers setObject:friend forKey:friend.name];
                    [self.selectedFriendIDs addObject:friend.friendId];
                }
            }
            else if (indexPath.row==2)
            {
                for (Friend* friend in foursquareFriends)
                {
                    [selectedFoursquareUsers setObject:friend forKey:friend.name];
                    [self.selectedFriendIDs addObject:friend.friendId];
                }
            }
            else
            {
                for (Friend* friend in twitterFriends)
                {
                    [selectedTwitterUsers removeObjectForKey:friend.name];
                    [self.selectedFriendIDs removeObject:friend.friendId];
                }
                
                for (Friend* friend in facebookFriends)
                {
                    [selectedFacebookUsers removeObjectForKey:friend.name];
                    [self.selectedFriendIDs removeObject:friend.friendId];
                }
                
                for (Friend* friend in foursquareFriends)
                {
                    [selectedFoursquareUsers removeObjectForKey:friend.name];
                    [self.selectedFriendIDs removeObject:friend.friendId];
                }
            }
            
            break;
        }
        case 1:                         //twitter users
            if ([selectedTwitterUsers objectForKey:((Friend*)[twitterFriends objectAtIndex:indexPath.row]).name])    //If it's selected, unselect it
            {
                [selectedTwitterUsers removeObjectForKey:((Friend*)[twitterFriends objectAtIndex:indexPath.row]).name];
                [self.selectedFriendIDs removeObject:((Friend*)[twitterFriends objectAtIndex:indexPath.row]).friendId];
            }
            else
            {
                [selectedTwitterUsers setObject:((Friend*)[twitterFriends objectAtIndex:indexPath.row]) forKey:((Friend*)[twitterFriends objectAtIndex:indexPath.row]).name];
                [self.selectedFriendIDs addObject:((Friend*)[twitterFriends objectAtIndex:indexPath.row]).friendId];
            }
            break;
            
        case 2:                         //facebook users
            if ([selectedFacebookUsers objectForKey:((Friend*)[facebookFriends objectAtIndex:indexPath.row]).name])    //If it's selected, unselect it
            {
                [selectedFacebookUsers removeObjectForKey:((Friend*)[facebookFriends objectAtIndex:indexPath.row]).name];
                [self.selectedFriendIDs removeObject:((Friend*)[facebookFriends objectAtIndex:indexPath.row]).friendId];
            }
            else
            {
                [selectedFacebookUsers setObject:((Friend*)[facebookFriends objectAtIndex:indexPath.row]) forKey:((Friend*)[facebookFriends objectAtIndex:indexPath.row]).name];
                [self.selectedFriendIDs addObject:((Friend*)[facebookFriends objectAtIndex:indexPath.row]).friendId];
            }
            break;
            
        case 3:                         //foursquare users
            if ([selectedFoursquareUsers objectForKey:((Friend*)[foursquareFriends objectAtIndex:indexPath.row]).name])    //If it's selected, unselect it
            {
                [selectedFoursquareUsers removeObjectForKey:((Friend*)[foursquareFriends objectAtIndex:indexPath.row]).name];
                [self.selectedFriendIDs removeObject:((Friend*)[foursquareFriends objectAtIndex:indexPath.row]).friendId];
            }
            else
            {
                [selectedFoursquareUsers setObject:((Friend*)[foursquareFriends objectAtIndex:indexPath.row]) forKey:((Friend*)[foursquareFriends objectAtIndex:indexPath.row]).name];
                [self.selectedFriendIDs addObject:((Friend*)[foursquareFriends objectAtIndex:indexPath.row]).friendId];
            }
            break;
            
        default:
            break;
    }
    
    [self.tableView reloadData];
}


#pragma mark - Array of friends

-(void) doneSelectingFriends {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedFriends:)]) {
        [self.delegate selectedFriends:self.selectedFriendIDs];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
