//
//  BlogViewController.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/12/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "BlogViewController.h"
#import "Engine.h"
#import "RightDetailedCell.h"
#import "EditBlogViewController.h"
#import "MapResultsViewController.h"

@interface BlogViewController () {
    
    NSDateFormatter *dateFormatter;
    
    NSArray* serviceBlogDates;
    NSDateFormatter *serviceDateFormatter;
}

@end


@implementation BlogViewController


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

    self.title = L(BLOGS);
    
    UIBarButtonItem* refreshBtn = [[UIBarButtonItem alloc] initWithTitle:L(REFRESH) style:UIBarButtonItemStylePlain target:self action:@selector(getBlogs)];
    self.navigationItem.rightBarButtonItem = refreshBtn;
    
    [self getBlogs];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    serviceDateFormatter = [[NSDateFormatter alloc] init];
    [serviceDateFormatter setDateFormat:@"yyy-MM-dd"];
    
    /*
    //Current date
    NSDate* currentDate = [NSDate date];
    
    //Populate the table with the days of the previous month
    for (int i=0 ; i>-30 ; i--)
    {
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setDay:i];
        NSDate *day = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];
        [blogs addObject:[dateFormatter stringFromDate:day]];
    }
    */
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Get Blogs call & delegate

-(void)getBlogs {
    BlogEngine* blogEngine = [[BlogEngine alloc] init];
    blogEngine.delegate = self;
    [blogEngine getBlogs];
}

-(void)gotBlogsWithDates:(NSArray*)dates {
    serviceBlogDates = dates;
    [self.tableView reloadData];
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
    return serviceBlogDates.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (serviceBlogDates.count>0)
        return L(HISTORY);
    else
        return nil;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    
    NSString *CellIdentifier = @"RightAlignedCell";
    RightDetailedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[RightDetailedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDate* blogDay = [serviceDateFormatter dateFromString:[serviceBlogDates objectAtIndex:row]];
    
    
    cell.textLabel.text = [dateFormatter stringFromDate:blogDay];
    cell.detailTextLabel.text = L(GETTRAJECTORY);
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.arrow = YES;
    cell.animated = YES;
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self getBlogForDate:[serviceBlogDates objectAtIndex:indexPath.row]];
    
    
    /*
    //Get day from selected date
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:-indexPath.row];
    NSDate *day = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
    
    NSDateFormatter* dFormatter = [[NSDateFormatter alloc] init];
    [dFormatter setDateFormat:@"yyy-MM-dd"];
    
    NSString* dayString = [dFormatter stringFromDate:day];
    MyLog(@"Showing trajectory for %@",dayString);
    */
}


#pragma mark Get blog POIs call & delegate


-(void)getBlogForDate:(NSString*)date {
    
    BlogEngine* blogEngine = [[BlogEngine alloc] init];
    blogEngine.delegate = self;
    [blogEngine getBlogForDate:date];
}

-(void)gotPOISforBlogDate:(NSArray*)pois {
    
    if (pois.count>0)
    {
        MapResultsViewController *mapResultsVC =[self.storyboard instantiateViewControllerWithIdentifier:@"MapResultsViewID"];
        mapResultsVC.pointsOfInterest = pois;
        mapResultsVC.showTrajectory = YES;
        [self.navigationController pushViewController:mapResultsVC animated:YES];
    }
}

@end
