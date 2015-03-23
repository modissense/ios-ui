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
    
    NSMutableArray* serviceBlogDates;
    NSDateFormatter *serviceDateFormatter;
    
    NSString* blogDate;    
    //Date for new visits
    NSString* newVisitDate;
    
    UIImageView* noDataImgView;
}

@end


@implementation BlogViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //For ios7
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
        ADJUST_IOS7_LAYOUT

    self.title = L(BLOGS);
    
    UIImageView* bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mapblur"]];
    self.tableView.backgroundView = bgView;
    
    //Set tableview background like so, because it's hiding refresh control texts
//    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"mapblur"]]];
    
    //For ios7
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
        ADJUST_IOS7_LAYOUT
    
    //Right button
    UIBarButtonItem* addBlogVisitBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showAddNewVisitPicker)];
//    UIBarButtonItem *addBlogBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add"] style:UIBarButtonItemStylePlain target:self action:@selector(showAddNewVisitPicker:)];
    //    UIBarButtonItem* refreshBtn = [[UIBarButtonItem alloc] initWithTitle:L(REFRESH) style:UIBarButtonItemStylePlain target:self action:@selector(getBlogs)];
    self.navigationItem.rightBarButtonItem = addBlogVisitBtn;
  
    //Add refresh functionality and make first call
    [self addRefreshing];
    [self getBlogs];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    serviceDateFormatter = [[NSDateFormatter alloc] init];
    [serviceDateFormatter setDateFormat:@"yyy-MM-dd"];
    
    //Datepicker target value changes
    newVisitDate = [serviceDateFormatter stringFromDate:[NSDate date]];
    
    noDataImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nodata"]];
    noDataImgView.alpha = 0.0;
    [self manageNoDataView];
    
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


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self getBlogs];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)addRefreshing {
    //Enabling the refresh control for the tableview
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor lightGrayColor];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:L(PULLTOREFRESH)];
    
    //Add a function that will be called when refreshing ends
    [self.refreshControl addTarget:self action:@selector(getBlogs) forControlEvents:UIControlEventValueChanged];
    
    //This will not hide refresh control due to background view
    self.refreshControl.layer.zPosition += 1;
}


-(void)manageNoDataView {
    
    if (serviceBlogDates.count==0)
    {
        noDataImgView.frame = CGRectMake(self.view.frame.size.width/2 - noDataImgView.frame.size.width/2, self.view.frame.size.height/2 - noDataImgView.frame.size.height/2, noDataImgView.frame.size.width, noDataImgView.frame.size.height);
        
        [self.tableView addSubview:noDataImgView];
    }
    else
    {
        if (noDataImgView)
            [noDataImgView removeFromSuperview];
    }
}


#pragma mark - Get Blogs call & delegate

-(void)getBlogs {
    
    [self.refreshControl beginRefreshing];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:L(GETTINGBLOGS)];
    
    BlogEngine* blogEngine = [[BlogEngine alloc] init];
    blogEngine.delegate = self;
    [blogEngine getBlogs];
}

-(void)gotBlogsWithDates:(NSArray*)dates {
    
    if (noDataImgView.alpha == 0.0)
        noDataImgView.alpha = 1.0;
    
    [self sortDates:dates];
    [self manageNoDataView];
    [self.refreshControl endRefreshing];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:L(PULLTOREFRESH)];
}


-(void) sortDates:(NSArray*)dates {
    
    //NSDate array
    NSMutableArray* blogDates = [NSMutableArray array];
    
    for (int i=0 ; i<dates.count ; i++)
    {
        NSDate* date = [serviceDateFormatter dateFromString:[dates objectAtIndex:i]];
        
        //Add it to our NSDate array
        [blogDates addObject:date];
    }
    
    //Sort dates
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:NO];
    [blogDates sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSMutableArray* blogDateStrings = [NSMutableArray array];
    
    for (int i=0 ; i<dates.count ; i++)
    {
        [blogDateStrings addObject:[serviceDateFormatter stringFromDate:[blogDates objectAtIndex:i]]];
    }
    
    serviceBlogDates = blogDateStrings;
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
    
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transpbg"]];
    cell.backgroundView.alpha = CELLALPHA;
    
    NSDate* blogDay = [serviceDateFormatter dateFromString:[serviceBlogDates objectAtIndex:row]];
    
    
    cell.textLabel.text = [dateFormatter stringFromDate:blogDay];
    cell.detailTextLabel.text = L(VIEWTRAJECTORY);
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.arrow = YES;
    cell.animated = NO;
    
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


#pragma mark - Get blog POIs call & delegate


-(void)getBlogForDate:(NSString*)date {
    
    blogDate = date;
    
    BlogEngine* blogEngine = [[BlogEngine alloc] init];
    blogEngine.delegate = self;
    [blogEngine getBlogForDate:date];
}

-(void)gotPOISforBlogDate:(NSArray*)pois withStory:(NSString*)story {
    
    if (pois.count>0)
    {
        EditBlogViewController *editBlogVC =[self.storyboard instantiateViewControllerWithIdentifier:@"EditBlogViewID"];
        editBlogVC.pointsOfInterest = pois;
        editBlogVC.blogDate = blogDate;
        editBlogVC.story = story;
        [self.navigationController pushViewController:editBlogVC animated:YES];
    }
}


#pragma mark - Date picker event delegate

//Get new date for new visit
- (void) dateChanged:(UIDatePicker *)picker {
    newVisitDate = [serviceDateFormatter stringFromDate:picker.date];
    NSLog(@"Date for new visit set for: %@", newVisitDate);
}


#pragma mark - Add new blog day with visit

-(void)showAddNewVisitPicker {
    
    if (self.flatDatePicker.isOpen)
        [self.flatDatePicker dismiss];
    
    self.flatDatePicker = [[FlatDatePicker alloc] initWithParentView:self.view];
    self.flatDatePicker.delegate = self;
    self.flatDatePicker.title = L(ADDANEWBLOGDAY);
//    self.flatDatePicker.datePickerMode = FlatDatePickerModeTime;
    self.flatDatePicker.datePickerMode = FlatDatePickerModeDate;
    [self.flatDatePicker setMaximumDate:[NSDate date]];
    [self.flatDatePicker show];
}


#pragma mark - FlatDatePicker Delegate

- (void)flatDatePicker:(FlatDatePicker*)datePicker dateDidChange:(NSDate*)date {
    
//    newVisitDate = [serviceDateFormatter stringFromDate:date];
//    NSLog(@"Date for new visit set for: %@", newVisitDate);
}

- (void)flatDatePicker:(FlatDatePicker*)datePicker didCancel:(UIButton*)sender {

}

- (void)flatDatePicker:(FlatDatePicker*)datePicker didValid:(UIButton*)sender date:(NSDate*)date {
    
    newVisitDate = [serviceDateFormatter stringFromDate:date];
    NSLog(@"Date for new visit set for: %@", newVisitDate);

    EditBlogViewController *editBlogVC =[self.storyboard instantiateViewControllerWithIdentifier:@"EditBlogViewID"];
    editBlogVC.blogDate = newVisitDate;
    
    //Push view controller with completion!
    [UIView transitionWithView:self.navigationController.view
                      duration:0.75
                       options:UIViewAnimationOptionTransitionNone
                    animations:^{
                        [self.navigationController pushViewController:editBlogVC animated:NO];
                    }
                    completion:^(BOOL finished){
                        [editBlogVC startNewVisitProcess];
                        
                        //If selected date already has a blog, call the service to populate results !
                        if ([serviceBlogDates containsObject:newVisitDate])
                        {
                            BlogEngine* blogEngine = [[BlogEngine alloc] init];
                            blogEngine.delegate = editBlogVC;
                            [blogEngine getBlogForDate:newVisitDate];
                        }
                    }];
}

@end
