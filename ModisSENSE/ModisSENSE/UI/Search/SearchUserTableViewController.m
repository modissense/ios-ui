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
#import "UtilImage.h"

#define DEFAULTCELLHIGHT 44

@interface SearchUserTableViewController () {
    
    NSArray* twitterFriends;
    NSArray* facebookFriends;
    NSArray* foursquareFriends;
    
    NSMutableDictionary *selectedTwitterUsers;
    NSMutableDictionary *selectedFacebookUsers;
    NSMutableDictionary *selectedFoursquareUsers;
    
    NSArray* twitterSearchResults;
    NSArray* facebookSearchResults;
    NSArray* foursquareSearchResults;
}

@end

@implementation SearchUserTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //For ios7
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
        ADJUST_IOS7_LAYOUT
    
    UIImageView* bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mapblur"]];
    self.tableView.backgroundView = bgView;
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:L(DONE) style:UIBarButtonItemStylePlain target:self action:@selector(doneSelectingFriends)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.title = L(FRIENDS);
    
    //Initialize arrays
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


#pragma mark - Search results delegate

//Change Cancel button to CLOSE
-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    self.searchDisplayController.searchBar.showsCancelButton = YES;
    UIButton *cancelButton;
    UIView *topView = self.searchDisplayController.searchBar.subviews[0];
    for (UIView *subView in topView.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
            cancelButton = (UIButton*)subView;
        }
    }
    if (cancelButton) {
        //Set the new title of the cancel button
        [cancelButton setTitle:L(CLOSE) forState:UIControlStateNormal];
    }
}


//When user presses Cancel (or Close in this case) on the searchDisplayController
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    //Refresh main tableview
    [self.tableView reloadData];
}


- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF contains[cd] %@",
                                    searchText];
    
    //We will extract the names in the friends objects to make the seasrch
    NSMutableArray* twitterNames = [NSMutableArray array];
    NSMutableArray* facebookNames = [NSMutableArray array];
    NSMutableArray* foursquareNames = [NSMutableArray array];
    
    for (int i=0 ; i<twitterFriends.count ; i++)
    {
        Friend* f = [twitterFriends objectAtIndex:i];
        [twitterNames addObject:f.name];
    }
    
    for (int j=0 ; j<facebookFriends.count ; j++)
    {
        Friend* f = [facebookFriends objectAtIndex:j];
        [facebookNames addObject:f.name];
    }
    
    for (int k=0 ; k<foursquareFriends.count ; k++)
    {
        Friend* f = [foursquareFriends objectAtIndex:k];
        [foursquareNames addObject:f.name];
    }
    
    
    //Search results which hold the names of the friends found (not the Friend object)
    twitterSearchResults = [twitterNames filteredArrayUsingPredicate:resultPredicate];
    facebookSearchResults = [facebookNames filteredArrayUsingPredicate:resultPredicate];
    foursquareSearchResults = [foursquareNames filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //Check which tableview is showing
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return 3;
    else
        return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        if (section==0)                     //twitter users
            return twitterSearchResults.count;
        else if (section==1)                //facebook users
            return facebookSearchResults.count;
        else                                //foursquare users
            return foursquareSearchResults.count;
    }
    else
    {
        if (section==1)                     //twitter users
            return twitterFriends.count;
        else if (section==2)                //facebook users
            return facebookFriends.count;
        else if (section==3)                //foursquare users
            return foursquareFriends.count;
        else                                //Select all
            return 4;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        if (section == 0)
        {
            if (twitterSearchResults.count>0)
                return L(SELECTTWITTERFRIENDS);
            else
                return nil;
        }
        else if (section == 1)
        {
            if (facebookSearchResults.count>0)
                return L(SELECTFACEBOOKFRIENDS);
            else
                return nil;
        }
        else
        {
            if (foursquareSearchResults.count>0)
                return L(SELECTFOURSQUAREFRIENDS);
            else
                return nil;
        }
    }
    else
    {
        if (section == 1)
        {
            if (twitterFriends.count>0)
                return L(SELECTTWITTERFRIENDS);
            else
                return nil;
        }
        else if (section == 2)
        {
            if (facebookFriends.count>0)
                return L(SELECTFACEBOOKFRIENDS);
            else
                return nil;
        }
        else if (section == 3)
        {
            if (foursquareFriends.count>0)
                return L(SELECTFOURSQUAREFRIENDS);
            else
                return nil;
        }
        else
            return nil;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
    cell.textLabel.textColor = [UIColor blackColor];
    cell.accessoryType = 0;
    cell.selectionStyle=0;
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        switch (indexPath.section)
        {
            case 0:                         //twitter users
            {
                cell.textLabel.text = [twitterSearchResults objectAtIndex:indexPath.row];
                cell.imageView.image = nil;
                cell.accessoryView = nil;
                
                if ([selectedTwitterUsers objectForKey:[twitterSearchResults objectAtIndex:indexPath.row]])
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                else
                    cell.accessoryType = 0;
                
                break;
            }
            case 1:                         //facebook users
            {
                cell.textLabel.text = [facebookSearchResults objectAtIndex:indexPath.row];
                cell.imageView.image = nil;
                cell.accessoryView = nil;
                
                if ([selectedFacebookUsers objectForKey:[facebookSearchResults objectAtIndex:indexPath.row]])
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                else
                    cell.accessoryType = 0;
                
                break;
            }
            case 2:                         //foursquare users
            {
                cell.textLabel.text = [foursquareSearchResults objectAtIndex:indexPath.row];
                cell.imageView.image = nil;
                cell.accessoryView = nil;
                
                if ([selectedFoursquareUsers objectForKey:[foursquareSearchResults objectAtIndex:indexPath.row]])
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                else
                    cell.accessoryType = 0;
                
                break;
            }
            default:
                break;
        }
    }
    else
    {
        switch (indexPath.section)
        {
            case 0:                         //Select all
            {
                if (indexPath.row==0)
                {
                    cell.imageView.image = [UIImage imageNamed:@"twitter"];
                    cell.textLabel.textColor = DEFAULTBLUE;
                    
                    if (twitterFriends.count>0)
                    {
                        cell.textLabel.text = L(SELECTALLTWITTERFRIENDS);
                        
                        if (selectedTwitterUsers.count == twitterFriends.count)
                        {
                            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark-checked"]];
                        }
                        else
                        {
                            cell.accessoryView = nil;
                        }
                    }
                    else
                    {
                        cell.textLabel.text = L(NOTWITTERFRIENDSAVAILABLE);
                        cell.textLabel.textColor = CELLGRAYCOLOR;
                    }
                }
                else if (indexPath.row==1)
                {
                    cell.imageView.image = [UIImage imageNamed:@"facebook"];
                    cell.textLabel.textColor = DEFAULTBLUE;
                    
                    if (facebookFriends.count>0)
                    {
                        cell.textLabel.text = L(SELECTALLFACEBOOKFRIENDS);
                        
                        if (selectedFacebookUsers.count == facebookFriends.count)
                        {
                            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark-checked"]];
                        }
                        else
                        {
                            cell.accessoryView = nil;
                        }
                    }
                    else
                    {
                        cell.textLabel.text = L(NOFACEBOOKFRIENDSAVAILABLE);
                        cell.textLabel.textColor = CELLGRAYCOLOR;
                    }
                }
                else if (indexPath.row==2)
                {
                    cell.imageView.image = [UIImage imageNamed:@"foursquare"];
                    cell.textLabel.textColor = DEFAULTBLUE;
                    
                    if (foursquareFriends.count>0)
                    {
                        cell.textLabel.text = L(SELECTALLFOURSQUAREFRIENDS);
                        
                        if (selectedFoursquareUsers.count == foursquareFriends.count)
                        {
                            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark-checked"]];
                        }
                        else
                        {
                            cell.accessoryView = nil;
                        }
                    }
                    else
                    {
                        cell.textLabel.text = L(NOFOURSQUAREFRIENDSAVAILABLE);
                        cell.textLabel.textColor = CELLGRAYCOLOR;
                    }
                }
                else
                {
                    cell.imageView.image = [UIImage imageNamed:@"trash"];
                    cell.textLabel.text = L(EMPTYSELECTIONS);
                    
                    if (selectedTwitterUsers.count + selectedFacebookUsers.count + selectedFoursquareUsers.count > 0)
                    {
                        cell.textLabel.textColor = [UIColor redColor];
    //                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"off"]];
                    }
                    else
                    {
                        cell.textLabel.textColor = CELLGRAYCOLOR;
                        cell.accessoryView = nil;
                    }
                }
                
                break;
            }
            case 1:                         //twitter users
            {
                Friend* friend = [twitterFriends objectAtIndex:indexPath.row];
                
                cell.textLabel.text = friend.name;
                
                //Round cell imageview
//                cell.imageView.layer.masksToBounds = YES;
//                cell.imageView.layer.cornerRadius = 20.0;
                
                [UtilImage loadAsyncImage:cell.imageView fromURL:friend.avatarImgURL withDefaultImage:@"blank-person"];
                
                cell.accessoryView = nil;
                
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
                
                //Round cell imageview
//                cell.imageView.layer.masksToBounds = YES;
//                cell.imageView.layer.cornerRadius = 20.0;
                
                [UtilImage loadAsyncImage:cell.imageView fromURL:friend.avatarImgURL withDefaultImage:@"blank-person"];
                
                cell.accessoryView = nil;
                
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
                
                //Round cell imageview
//                cell.imageView.layer.masksToBounds = YES;
//                cell.imageView.layer.cornerRadius = 20.0;
                
                [UtilImage loadAsyncImage:cell.imageView fromURL:friend.avatarImgURL withDefaultImage:@"blank-person"];
                
                cell.accessoryView = nil;
                
                if ([selectedFoursquareUsers objectForKey:friend.name])
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                else
                    cell.accessoryType = 0;
                
                break;
            }
            default:
                break;
        }
    }
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        switch (indexPath.section)
        {
            case 0:                         //twitter users
                if ([selectedTwitterUsers objectForKey:[twitterSearchResults objectAtIndex:indexPath.row]])    //If it's selected, unselect it
                {
                    //Find the object associated with the name
                    Friend* friend;
                    for (int i=0; i<twitterFriends.count; i++)
                    {
                        Friend* fr = [twitterFriends objectAtIndex:i];
                        
                        if ([fr.name isEqualToString:[twitterSearchResults objectAtIndex:indexPath.row]])
                        {
                            friend = fr;
                            break;
                        }
                    }
                    
                    [selectedTwitterUsers removeObjectForKey:friend.name];
                    [self.selectedFriendIDs removeObject:friend.friendId];
                }
                else
                {
                    //Find the object associated with the name
                    Friend* friend;
                    for (int i=0; i<twitterFriends.count; i++)
                    {
                        Friend* fr = [twitterFriends objectAtIndex:i];
                        
                        if ([fr.name isEqualToString:[twitterSearchResults objectAtIndex:indexPath.row]])
                        {
                            friend = fr;
                            break;
                        }
                    }
                    
                    [selectedTwitterUsers setObject:friend forKey:friend.name];
                    [self.selectedFriendIDs addObject:friend.friendId];
                }

                [self.searchDisplayController.searchResultsTableView reloadData];
                break;
                
            case 1:                         //facebook users
                if ([selectedFacebookUsers objectForKey:[facebookSearchResults objectAtIndex:indexPath.row]])    //If it's selected, unselect it
                {
                    //Find the object associated with the name
                    Friend* friend;
                    for (int i=0; i<facebookFriends.count; i++)
                    {
                        Friend* fr = [facebookFriends objectAtIndex:i];
                        
                        if ([fr.name isEqualToString:[facebookSearchResults objectAtIndex:indexPath.row]])
                        {
                            friend = fr;
                            break;
                        }
                    }
                    
                    [selectedFacebookUsers removeObjectForKey:friend.name];
                    [self.selectedFriendIDs removeObject:friend.friendId];
                }
                else
                {
                    //Find the object associated with the name
                    Friend* friend;
                    for (int i=0; i<facebookFriends.count; i++)
                    {
                        Friend* fr = [facebookFriends objectAtIndex:i];
                        
                        if ([fr.name isEqualToString:[facebookSearchResults objectAtIndex:indexPath.row]])
                        {
                            friend = fr;
                            break;
                        }
                    }
                    
                    [selectedFacebookUsers setObject:friend forKey:friend.name];
                    [self.selectedFriendIDs addObject:friend.friendId];
                }
                
                [self.searchDisplayController.searchResultsTableView reloadData];
                break;
                
            case 2:                         //foursquare users
                if ([selectedFoursquareUsers objectForKey:[foursquareSearchResults objectAtIndex:indexPath.row]])    //If it's selected, unselect it
                {
                    //Find the object associated with the name
                    Friend* friend;
                    for (int i=0; i<foursquareFriends.count; i++)
                    {
                        Friend* fr = [foursquareFriends objectAtIndex:i];
                        
                        if ([fr.name isEqualToString:[foursquareSearchResults objectAtIndex:indexPath.row]])
                        {
                            friend = fr;
                            break;
                        }
                    }
                    
                    [selectedFoursquareUsers removeObjectForKey:friend.name];
                    [self.selectedFriendIDs removeObject:friend.friendId];
                }
                else
                {
                    //Find the object associated with the name
                    Friend* friend;
                    for (int i=0; i<foursquareFriends.count; i++)
                    {
                        Friend* fr = [foursquareFriends objectAtIndex:i];
                        
                        if ([fr.name isEqualToString:[foursquareSearchResults objectAtIndex:indexPath.row]])
                        {
                            friend = fr;
                            break;
                        }
                    }
                    
                    [selectedFoursquareUsers setObject:friend forKey:friend.name];
                    [self.selectedFriendIDs addObject:friend.friendId];
                }
                
                [self.searchDisplayController.searchResultsTableView reloadData];
                break;
                
            default:
                
                [self.searchDisplayController.searchResultsTableView reloadData];
                break;
        }
    }
    else
    {
        switch (indexPath.section)
        {
            case 0:
            {
                if (indexPath.row==0)
                {
                    if (selectedTwitterUsers.count == twitterFriends.count)      //Remove them all
                    {
                        [selectedTwitterUsers removeAllObjects];
                        
                        for (Friend* friend in twitterFriends)
                            [self.selectedFriendIDs removeObject:friend.friendId];
                    }
                    else
                    {
                        for (Friend* friend in twitterFriends)
                        {
                            if (![self.selectedFriendIDs containsObject:friend.friendId])
                            {
                                [selectedTwitterUsers setObject:friend forKey:friend.name];
                                [self.selectedFriendIDs addObject:friend.friendId];
                            }
                        }
                    }
                }
                else if (indexPath.row==1)
                {
                    if (selectedFacebookUsers.count == facebookFriends.count)      //Remove them all
                    {
                        [selectedFacebookUsers removeAllObjects];
                        
                        for (Friend* friend in facebookFriends)
                            [self.selectedFriendIDs removeObject:friend.friendId];
                    }
                    else
                    {
                        for (Friend* friend in facebookFriends)
                        {
                            if (![self.selectedFriendIDs containsObject:friend.friendId])
                            {
                                [selectedFacebookUsers setObject:friend forKey:friend.name];
                                [self.selectedFriendIDs addObject:friend.friendId];
                            }
                        }
                    }
                }
                else if (indexPath.row==2)
                {
                    if (selectedFoursquareUsers.count == foursquareFriends.count)      //Remove them all
                    {
                        [selectedFoursquareUsers removeAllObjects];
                        
                        for (Friend* friend in foursquareFriends)
                            [self.selectedFriendIDs removeObject:friend.friendId];
                    }
                    else
                    {
                        for (Friend* friend in foursquareFriends)
                        {
                            if (![self.selectedFriendIDs containsObject:friend.friendId])
                            {
                                [selectedFoursquareUsers setObject:friend forKey:friend.name];
                                [self.selectedFriendIDs addObject:friend.friendId];
                            }
                        }
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
    }
    
    if (tableView != self.searchDisplayController.searchResultsTableView)
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
