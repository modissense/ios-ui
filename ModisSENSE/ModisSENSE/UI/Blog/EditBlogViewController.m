//
//  AddBlogViewController.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/12/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "EditBlogViewController.h"
#import "AddPOIViewController.h"
#import "RightDetailedCell.h"
#import "Engine.h"
#import "UIConstants.h"

@interface EditBlogViewController () {
    Blog *blog;
    NSDateFormatter *dateFormatter;
}

@end



@implementation EditBlogViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = L(BLOG);
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:L(DONE) style:UIBarButtonItemStylePlain target:self action:@selector(doneEditingBlog)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void) doneEditingBlog
{
    //Edit blog code here
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
        return 4;
    else
        return blog.POIS.count+1;        //blog records + Add a record row
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    NSUInteger section = indexPath.section;
    
    if (section==0)
    {
        NSString *CellIdentifier = @"RightAlignedCell";
        RightDetailedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[RightDetailedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        switch (row)
        {
            case 0:
            {
                cell.textLabel.text = L(BLOG_NAME);
        
                cell.detailTextLabel.text = @"Empty";
                //cell.detailTextLabel.text = blog.name;
        
                cell.arrow = NO;
                break;
            }
            case 1:
            {
                cell.textLabel.text = L(PUBLISHED);
                
                cell.detailTextLabel.text = [dateFormatter stringFromDate:[NSDate date]];
                //cell.detailTextLabel.text = [dateFormatter stringFromDate:blog.creationDate];
                
                cell.arrow = NO;
                break;
            }
            case 2:
            {
                cell.textLabel.text = L(STATUS);
                
                switch (blog.status)
                {
                    case 0:
                    {
                        cell.detailTextLabel.text = L(PRIVATE);
                        break;
                    }
                    case 1:
                    {
                        cell.detailTextLabel.text = L(PENDING);
                        break;
                    }
                    case 2:
                    {
                        cell.detailTextLabel.text = L(PUBLISHED);
                        break;
                    }
                }
                
                cell.arrow = YES;
                break;
            }
            case 3:
            {
                cell.textLabel.text = L(UPDATED);
                
                cell.detailTextLabel.text = @"24 hrs";
                
                cell.arrow = NO;
                break;
            }
        }
        cell.animated = NO;
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            //For the default cells
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        if (row==0)
        {
            NSString* add = @"\U0000271B ";
            cell.textLabel.text = [add stringByAppendingString:L(ADDLOCATION)];
            cell.textLabel.font = CELLFONT;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else
        {
            cell.textLabel.text = [[blog.POIS objectAtIndex:row-1] description];
            cell.textLabel.font = CELLFONT;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1 && indexPath.row==0)    //Add a location clicked (Add Blog Record)
    {
        AddPOIViewController *vc =[self.storyboard instantiateViewControllerWithIdentifier:@"AddBlogRecordID"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
