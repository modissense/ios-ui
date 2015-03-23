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
#import "UtilImage.h"

#define DEFAULTCELLHIGHT 44

@interface UserSelectionViewController () {
    
    UILabel* pullDownLabel;     //Pull down to refresh or search
    
    NSArray* twitterFriends;
    NSArray* facebookFriends;
    NSArray* foursquareFriends;
    
    NSArray* twitterSearchResults;
    NSArray* facebookSearchResults;
    NSArray* foursquareSearchResults;
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
        
    UIImageView* bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mapblur"]];
    self.tableView.backgroundView = bgView;
    
    self.title = L(FRIENDS);
    
    //Add right bar button to close modal window
    UIBarButtonItem *closeModalAndSearchBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search"] style:UIBarButtonItemStylePlain target:self action:@selector(closeModalAndSearch)];
    self.navigationItem.rightBarButtonItem = closeModalAndSearchBtn;
    
    //Add right bar button to close modal window
    UIBarButtonItem *closeModalBtn = [[UIBarButtonItem alloc] initWithTitle:L(CANCEL) style:UIBarButtonItemStylePlain target:self action:@selector(closeModal)];
    self.navigationItem.leftBarButtonItem = closeModalBtn;
    
    //Enabling the refresh control for the tableview
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor lightGrayColor];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:L(PULLTOREFRESHFRIENDS)];
    
    //Add a function that will be called when refreshing ends
    [self.refreshControl addTarget:self action:@selector(refreshFriends:) forControlEvents:UIControlEventValueChanged];
    
    //This will not hide refresh control due to background view
    self.refreshControl.layer.zPosition += 1;

    twitterFriends = Eng.user.twitterFriends;
    facebookFriends = Eng.user.facebookFriends;
    foursquareFriends = Eng.user.foursquareFriends;
    
    [self showPullDownLabel];
    
    [self.tableView reloadData];
}


#pragma mark - Pull dowb label

-(void)showPullDownLabel {

    pullDownLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    pullDownLabel.alpha = 0.0;
    pullDownLabel.backgroundColor = [UIColor grayColor];
    pullDownLabel.textColor = [UIColor whiteColor];
    pullDownLabel.font = CELLFONT;
    pullDownLabel.textAlignment = NSTextAlignmentCenter;
    pullDownLabel.text = L(PULLDOWNTOREFRESHORSEARCH);
    
    [self.tableView addSubview:pullDownLabel];
    
    [UIView animateWithDuration:0.5 animations:^{
        pullDownLabel.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 15);
        pullDownLabel.alpha = 1.0;
    }];
    
    [UIView animateWithDuration:2.0 animations:^{
        pullDownLabel.alpha = 0.0;
    }];
}


-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
//    if (self.delegate && [self.delegate respondsToSelector:@selector(friendsSelected)]) {
//        [self.delegate friendsSelected];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark = Clsoe Modal

-(void)closeModalAndSearch {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(friendsSelected)]) {
        [self.delegate friendsSelected];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)closeModal {
    [self dismissViewControllerAnimated:YES completion:nil];
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
        return 4;   //3+1 (select all)
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
                
                if ([Eng.preferences.selectedTwitterUsers objectForKey:[twitterSearchResults objectAtIndex:indexPath.row]])
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
                
                if ([Eng.preferences.selectedFacebookUsers objectForKey:[facebookSearchResults objectAtIndex:indexPath.row]])
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
                
                if ([Eng.preferences.selectedFoursquareUsers objectForKey:[foursquareSearchResults objectAtIndex:indexPath.row]])
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
                        
                        if (Eng.preferences.selectedTwitterUsers.count == twitterFriends.count)
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
                        
                        if (Eng.preferences.selectedFacebookUsers.count == facebookFriends.count)
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
                        
                        if (Eng.preferences.selectedFoursquareUsers.count == foursquareFriends.count)
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
                    
                    if (Eng.preferences.selectedTwitterUsers.count + Eng.preferences.selectedFacebookUsers.count + Eng.preferences.selectedFoursquareUsers.count > 0)
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
                
                //Round cell imageview
//                cell.imageView.layer.masksToBounds = YES;
//                cell.imageView.layer.cornerRadius = 20.0;
                
                [UtilImage loadAsyncImage:cell.imageView fromURL:friend.avatarImgURL withDefaultImage:@"blank-person"];
                
                cell.accessoryView = nil;
                
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
                
                //Round cell imageview
//                cell.imageView.layer.masksToBounds = YES;
//                cell.imageView.layer.cornerRadius = 20.0;
                
                [UtilImage loadAsyncImage:cell.imageView fromURL:friend.avatarImgURL withDefaultImage:@"blank-person"];
                
                cell.accessoryView = nil;
                
                if ([Eng.preferences.selectedFoursquareUsers objectForKey:friend.name])
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
                if ([Eng.preferences.selectedTwitterUsers objectForKey:[twitterSearchResults objectAtIndex:indexPath.row]])    //If it's selected, unselect it
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
                    
                    [Eng.preferences.selectedTwitterUsers removeObjectForKey:friend.name];
                    [Eng.preferences.selectedFriendIDs removeObject:friend.friendId];
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
                    
                    [Eng.preferences.selectedTwitterUsers setObject:friend forKey:friend.name];
                    [Eng.preferences.selectedFriendIDs addObject:friend.friendId];
                }
                
                [self.searchDisplayController.searchResultsTableView reloadData];
                break;
                
            case 1:                         //facebook users
                if ([Eng.preferences.selectedFacebookUsers objectForKey:[facebookSearchResults objectAtIndex:indexPath.row]])    //If it's selected, unselect it
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
                    
                    [Eng.preferences.selectedFacebookUsers removeObjectForKey:friend.name];
                    [Eng.preferences.selectedFriendIDs removeObject:friend.friendId];
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
                    
                    [Eng.preferences.selectedFacebookUsers setObject:friend forKey:friend.name];
                    [Eng.preferences.selectedFriendIDs addObject:friend.friendId];
                }
                
                [self.searchDisplayController.searchResultsTableView reloadData];
                break;
                
            case 2:                         //foursquare users
                if ([Eng.preferences.selectedFoursquareUsers objectForKey:[foursquareSearchResults objectAtIndex:indexPath.row]])    //If it's selected, unselect it
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
                    
                    [Eng.preferences.selectedFoursquareUsers removeObjectForKey:friend.name];
                    [Eng.preferences.selectedFriendIDs removeObject:friend.friendId];
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
                    
                    [Eng.preferences.selectedFoursquareUsers setObject:friend forKey:friend.name];
                    [Eng.preferences.selectedFriendIDs addObject:friend.friendId];
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
                    if (Eng.preferences.selectedTwitterUsers.count == Eng.user.twitterFriends.count)      //Remove them all
                    {
                        [Eng.preferences.selectedTwitterUsers removeAllObjects];
                        
                        for (Friend* friend in twitterFriends)
                            [Eng.preferences.selectedFriendIDs removeObject:friend.friendId];
                    }
                    else
                    {
                        for (Friend* friend in twitterFriends)
                        {
                            if (![Eng.preferences.selectedFriendIDs containsObject:friend.friendId])
                            {
                                [Eng.preferences.selectedTwitterUsers setObject:friend forKey:friend.name];
                                [Eng.preferences.selectedFriendIDs addObject:friend.friendId];
                            }
                        }
                    }
                }
                else if (indexPath.row==1)
                {
                    if (Eng.preferences.selectedFacebookUsers.count == Eng.user.facebookFriends.count)      //Remove them all
                    {
                        [Eng.preferences.selectedFacebookUsers removeAllObjects];
                        
                        for (Friend* friend in facebookFriends)
                            [Eng.preferences.selectedFriendIDs removeObject:friend.friendId];
                    }
                    else
                    {
                        for (Friend* friend in facebookFriends)
                        {
                            if (![Eng.preferences.selectedFriendIDs containsObject:friend.friendId])
                            {
                                [Eng.preferences.selectedFacebookUsers setObject:friend forKey:friend.name];
                                [Eng.preferences.selectedFriendIDs addObject:friend.friendId];
                            }
                        }
                    }
                }
                else if (indexPath.row==2)
                {
                    if (Eng.preferences.selectedFoursquareUsers.count == Eng.user.foursquareFriends.count)      //Remove them all
                    {
                        [Eng.preferences.selectedFoursquareUsers removeAllObjects];
                        
                        for (Friend* friend in foursquareFriends)
                            [Eng.preferences.selectedFriendIDs removeObject:friend.friendId];
                    }
                    else
                    {
                        for (Friend* friend in foursquareFriends)
                        {
                            if (![Eng.preferences.selectedFriendIDs containsObject:friend.friendId])
                            {
                                [Eng.preferences.selectedFoursquareUsers setObject:friend forKey:friend.name];
                                [Eng.preferences.selectedFriendIDs addObject:friend.friendId];
                            }
                        }
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
    }
    
    if (tableView != self.searchDisplayController.searchResultsTableView)
    {
        //Refresh main tableview
        [self.tableView reloadData];
    }
}



#pragma mark - Refresh friends

-(void)refreshFriends:(UIRefreshControl*)refresh {
    [self getFriends];
}


- (void)getFriends {
    
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:L(GETTINGFRIENDS)];
    
    UserEngine* userEng = [[UserEngine alloc] init];
    userEng.delegate=self;
    [userEng getFriendsForUser:Eng.user.userId showLoader:NO];
}

//Delegate
- (void)gotFriends {
    
    [self.refreshControl endRefreshing];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:L(PULLTOREFRESHFRIENDS)];
    [self.tableView reloadData];
}
@end
