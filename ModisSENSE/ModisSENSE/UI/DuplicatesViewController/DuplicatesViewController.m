//
//  DuplicatesViewController.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 9/17/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "DuplicatesViewController.h"
#import "UIConstants.h"
#import "POI.h"
#import "Engine.h"
#import "MapResultsViewController.h"

@interface DuplicatesViewController ()

@end

@implementation DuplicatesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = L(DUPLICATEPOIS);

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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section==0)
        return self.duplicatesList.count;
    else if (section == 1)
        return 1;
    else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section==0)
    {
        POI* duplicatePOI = [self.duplicatesList objectAtIndex:indexPath.row];
        
        cell.imageView.image = [UIImage imageNamed:@"target"];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.text = duplicatePOI.name;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.text = duplicatePOI.description;
        cell.accessoryType = 0;
        
        cell.textLabel.font = CELLFONT;
        cell.detailTextLabel.font = CELLFONT;
    }
    else if (indexPath.section==1)
    {
        cell.textLabel.text = L(SEETHEMONAMAP);
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.text = @"";
        cell.imageView.image = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.font = CELLFONTBOLD;
        cell.backgroundColor = DEFAULTBLUE;
    }
    else
    {
        cell.textLabel.text = L(ADDASNEW);
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.text = @"";
        cell.imageView.image = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.font = CELLFONTBOLD;
        cell.backgroundColor = DARKGREEN;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1)
    {
        MapResultsViewController *mapResultsVC =[self.storyboard instantiateViewControllerWithIdentifier:@"MapResultsViewID"];
        mapResultsVC.showTrajectory = NO;
        mapResultsVC.pointsOfInterest = self.duplicatesList;
        [self.navigationController pushViewController:mapResultsVC animated:YES];
    }
    
    if (indexPath.section==2)
        [self addAsNew];
}


#pragma mark - Add as new POI

-(void) addAsNew {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(addPOI)])
        [self.delegate addPOI];
}

@end
