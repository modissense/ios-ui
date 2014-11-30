//
//  ProfileViewController.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/15/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = L(PROFILE);
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
        return 2;
    else
        return 3;
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
    
    if (section == 0)
    {
        switch (row)
        {
            case 0:
            {
                cell.textLabel.text = L(ACCOUNT);
                break;
            }
            case 1:
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
                cell.textLabel.text = L(ACTIONS);
                break;
            }
            case 1:
            {
                cell.textLabel.text = L(DELETE_ACCOUNT);
                cell.imageView.image = [UIImage imageNamed:@"remove"];
                break;
            }
            case 2:
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
    if (indexPath.section==1 && indexPath.row==2)       //Sign out
    {
        UserEngine* userEng = [[UserEngine alloc] init];
        [userEng signOutUser];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
