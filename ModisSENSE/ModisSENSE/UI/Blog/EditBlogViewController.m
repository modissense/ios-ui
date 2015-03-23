//
//  AddBlogViewController.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/12/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "EditBlogViewController.h"
#import "TrajectoryMapViewController.h"
#import "Engine.h"
#import "UIConstants.h"
#import "Config.h"

@interface EditBlogViewController () {
    
    CLLocation* newVisitLocation;
    NSMutableArray* seqIDs;
    UIView* shareBlogView;
    UIButton *twitterCheckBtn;
    UIButton *facebookCheckBtn;
    UIButton *foursqaureCheckBtn;
    BOOL sharePressed;
    NSMutableArray* sharingSocialMedia;
    UIImageView* noDataImgView;
    NSMutableIndexSet *optionIndices;
    UITextView* storyTextview;
}

@end



@implementation EditBlogViewController {
    
    //Share view variables
    CGFloat viewWidth;
    CGFloat padding;
    CGFloat buttonWidth;
    CGFloat buttonHeigt;
    CGFloat viewHeight;
}


-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //Shpw right navigation buttons if there are POIs to show
    if (self.pointsOfInterest.count>0)
        [self setRightNavigationButtons];
    else
        [self removeRightNavigationButtons];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}


-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];  
}


-(void)setRightNavigationButtons {
    
    self.navigationItem.rightBarButtonItems = nil;
    UIBarButtonItem *shareBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"shareblog"] style:UIBarButtonItemStylePlain target:self action:@selector(showShareView)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.editButtonItem, shareBtn, nil];
    
    //Set edit button image
//    self.editButtonItem.image = [UIImage imageNamed:@"sort"];
}

-(void)removeRightNavigationButtons {
    self.navigationItem.rightBarButtonItems = nil;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //For iOS7
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
        ADJUST_IOS7_LAYOUT

    UIImageView* bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mapblur"]];
    self.tableView.backgroundView = bgView;
    
    self.title = self.blogDate;
    
    self.tableView.allowsSelectionDuringEditing = YES;
    
    //Initialize share view variables
    viewWidth = 80;
    padding = 10;
    buttonWidth = viewWidth-padding;
    buttonHeigt = 28;
    viewHeight = 5*buttonHeigt+5*padding;
    
    seqIDs = [NSMutableArray array];
    
    //Show swipe left label
    if (self.pointsOfInterest.count>0)
    {
        [self addStory];
        
        UILabel* swipeLeft = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
        swipeLeft.alpha = 0.0;
        swipeLeft.backgroundColor = [UIColor grayColor];
        swipeLeft.textColor = [UIColor whiteColor];
        swipeLeft.font = CELLFONT;
        swipeLeft.textAlignment = NSTextAlignmentCenter;
        swipeLeft.text = L(SWIPELEFTTODELETE);
        
        [self.tableView addSubview:swipeLeft];
        
        [UIView animateWithDuration:0.5 animations:^{
            swipeLeft.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 15);
            swipeLeft.alpha = 1.0;
        }];
        
        [UIView animateWithDuration:4.0 animations:^{
            swipeLeft.alpha = 0.0;
        }];
    }
    
    noDataImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nodata"]];
    
    [self manageNoDataView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Add story view

-(void)addStory {
    
    if (storyTextview)
        [storyTextview removeFromSuperview];
    
    storyTextview = [[UITextView alloc] initWithFrame:CGRectMake(3, 10, self.tableView.frame.size.width-20, 40)];
    storyTextview.backgroundColor = [UIColor clearColor];
    storyTextview.textColor = DEFAULTBLUE;
    [storyTextview setText:self.story];
//    storyTextview.textAlignment = NSTextAlignmentJustified;
    [storyTextview setUserInteractionEnabled:NO];
    
    CGFloat fixedWidth = storyTextview.frame.size.width;
    CGSize newSize = [storyTextview sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = storyTextview.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    storyTextview.frame = newFrame;
    
    self.tableView.tableFooterView = storyTextview;
}

#pragma mark - No data view

-(void)manageNoDataView {
    
    if (self.pointsOfInterest.count==0)
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



#pragma mark - Rotation delegate

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    if (self.pointsOfInterest.count==0)
    {
        noDataImgView.frame = CGRectMake(self.view.frame.size.width/2 - noDataImgView.frame.size.width/2, self.view.frame.size.height/2 - noDataImgView.frame.size.height/2, noDataImgView.frame.size.width, noDataImgView.frame.size.height);
    }
}


#pragma mark - Refresh control

-(void) addRefreshControl {
    [self.tableView reloadData];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:L(SHOWSTORY)];
    
    //Add a function that will be called when refreshing
    [refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}


-(void)refreshTable:(UIRefreshControl*)refreshControl{
    
    //refresh code here (reload table data etc.)
    [refreshControl endRefreshing];
}



#pragma mark - Show share view

-(void) showShareView {
    
    if (Eng.user.socialAccounts == nil)
        [self getConnectedAccounts];
    else
    {
        //If there is only foursquare connected don't show up the share view
        if ([Eng.user.socialAccounts containsObject:FOURSQUARE] && ![Eng.user.socialAccounts containsObject:TWITTER] && ![Eng.user.socialAccounts containsObject:FACEBOOK])
        {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:L(SHARE)
                                                                message:L(ADDMORESOCIALACCOUNTS)
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            
            [alertView show];
            return;
        }
        
        NSMutableArray* images = [NSMutableArray array];
        
        //Add images. (Image names are the same as the social account names for ease of use)
        for (int i=0 ; i<Eng.user.socialAccounts.count ; i++)
            [images addObject:[UIImage imageNamed:[Eng.user.socialAccounts objectAtIndex:i]]];
        
        //Share buttom
        [images addObject:[UIImage imageNamed:@"upload"]];
        
        //Remove foursquare. It doens't have a share API
        [images removeObject:[UIImage imageNamed:FOURSQUARE]];
        
        
        NSMutableArray* colors = [NSMutableArray array];
        
        //Initialize arrays and selections
        sharingSocialMedia = [NSMutableArray array];
        optionIndices = [NSMutableIndexSet indexSet];
        
        for (int i=0 ; i<images.count ; i++)
        {
            [colors addObject:[UIColor colorWithRed:81/255.f green:154/255.f blue:237/255.f alpha:1]];
            
            if (i<images.count-1)
            {
                [optionIndices addIndex:i];
                [sharingSocialMedia addObject:Eng.user.socialAccounts[i]];
            }
        }
        
        RNFrostedSidebar *shareView = [[RNFrostedSidebar alloc] initWithImages:images selectedIndices:optionIndices borderColors:colors];
        //    RNFrostedSidebar *shareView = [[RNFrostedSidebar alloc] initWithImages:images];
        shareView.delegate = self;
//        shareView.showFromRight = YES;
        [shareView show];
    }
}


#pragma mark - Side bar delegates

- (void)sidebar:(RNFrostedSidebar *)sidebar didTapItemAtIndex:(NSUInteger)index {

    if (([Eng.user.socialAccounts containsObject:FOURSQUARE] && index == Eng.user.socialAccounts.count-1) ||
        (![Eng.user.socialAccounts containsObject:FOURSQUARE] && index == Eng.user.socialAccounts.count))
    {
        //Share blog call
        if (sharingSocialMedia.count>0)
        {
            [self shareBlog];
            [sidebar dismissAnimated:YES completion:nil];
        }
        else
        {
            //Please select a social media to share
            [SVProgressHUD showErrorWithStatus:L(SELECTONESOCIAL)];
        }
        return;
    }
    
    NSLog(@"Tapped item at index %i",index);
    
    if ([[Eng.user.socialAccounts objectAtIndex:index] isEqual:TWITTER])
        [self twitterPressed];
    
    if ([[Eng.user.socialAccounts objectAtIndex:index] isEqual:FOURSQUARE])
        [self facebookPressed]; //[self foursquarePressed];
    
    if ([[Eng.user.socialAccounts objectAtIndex:index] isEqual:FACEBOOK])
        [self facebookPressed];
}

- (void)sidebar:(RNFrostedSidebar *)sidebar didEnable:(BOOL)itemEnabled itemAtIndex:(NSUInteger)index {

}



-(void) twitterPressed {
    
    if (![sharingSocialMedia containsObject:TWITTER])
    {
        [sharingSocialMedia addObject:TWITTER];
        [twitterCheckBtn setImage:[UIImage imageNamed:@"checkmark-checked"] forState:UIControlStateNormal];
        NSLog(@"Twitter selected");
    }
    else
    {
        [sharingSocialMedia removeObject:TWITTER];
        [twitterCheckBtn setImage:[UIImage imageNamed:@"twitter"] forState:UIControlStateNormal];
        NSLog(@"Twitter un-selected");
    }
}

-(void) facebookPressed {

    if (![sharingSocialMedia containsObject:FACEBOOK])
    {
        [sharingSocialMedia addObject:FACEBOOK];
        [facebookCheckBtn setImage:[UIImage imageNamed:@"checkmark-checked"] forState:UIControlStateNormal];
        NSLog(@"Facebook selected");
    }
    else
    {
        [sharingSocialMedia removeObject:FACEBOOK];
        [facebookCheckBtn setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
        NSLog(@"Facebook un-selected");
    }
}

-(void) foursquarePressed {

    if (![sharingSocialMedia containsObject:FOURSQUARE])
    {
        [sharingSocialMedia addObject:FOURSQUARE];
        [foursqaureCheckBtn setImage:[UIImage imageNamed:@"checkmark-checked"] forState:UIControlStateNormal];
        NSLog(@"Foursquare selected");
    }
    else
    {
        [sharingSocialMedia removeObject:FOURSQUARE];
        [foursqaureCheckBtn setImage:[UIImage imageNamed:@"foursquare"] forState:UIControlStateNormal];
        NSLog(@"Foursquare un-selected");
    }
}



#pragma mark - Share Blog

-(void) shareBlog {
    NSLog(@"Sharing blog..");
    
    BlogEngine* blogEng = [[BlogEngine alloc] init];
    blogEng.delegate = self;
    [blogEng shareBlogToSocialMedia:sharingSocialMedia forDate:self.blogDate];
}


#pragma mark - Get connected accounts call & delegate

- (void)getConnectedAccounts {
    
    UserEngine* userEng = [[UserEngine alloc] init];
    userEng.delegate=self;
    [userEng getConnectedAccountsFromUser:Eng.user.userId];
}

//Delegate
//Set selected media to show on table
- (void)gotConnectedAccounts {
    
    [self showShareView];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.pointsOfInterest.count>0)
        return 3;
    else
        return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (section==0)
        return self.pointsOfInterest.count;
    else if (section==1)
        return 1;
    else
        return 1;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0)
        return L(TRAJECTORY);
    else
        return nil;
}


//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.section == 0)
//        return 70;
//    else
//        return 44;
//} 


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = 0;
    
    if (self.pointsOfInterest.count>0)
    {
        POI* poi = [self.pointsOfInterest objectAtIndex:indexPath.row];
        
        //Get the seqID for later use
        [seqIDs addObject:[NSNumber numberWithInt:poi.seqid]];
        
        NSDateFormatter* df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyy-MM-dd HH:mm:ss"];
        
        switch (indexPath.section)
        {
            case 0:
            {
                if (self.pointsOfInterest.count==1)
                    cell.imageView.image = [UIImage imageNamed:@"blog_finish"];
                else
                {
                    if (indexPath.row==0)
                        cell.imageView.image = [UIImage imageNamed:@"blog_start"];
                    else if (indexPath.row==self.pointsOfInterest.count-1)
                        cell.imageView.image = [UIImage imageNamed:@"blog_finish"];
                    else
                        cell.imageView.image = [UIImage imageNamed:@"blog_down"];
                }
                
                cell.textLabel.text = poi.name;
                cell.textLabel.textColor = [UIColor blackColor];
                
                //Check if description is null or empty
                NSString* subtitle = poi.comment;
                if (subtitle==nil || [subtitle isKindOfClass:[NSNull class]] || [subtitle isEqualToString:@"null"] || subtitle.length==0)
                    subtitle = L(NODESCRIPTION);

                NSDateFormatter* df = [[NSDateFormatter alloc] init];
                [df setDateFormat:@"yyy-MM-dd HH:mm:ss"];
                
                NSDate* start = [df dateFromString:poi.startDate];
                NSDate* end = [df dateFromString:poi.endDate];
                
                NSTimeInterval distanceBetweenDates = [end timeIntervalSinceDate:start];
                double secondsInAnMinute = 60;
                NSInteger minutesBetweenDates = distanceBetweenDates / secondsInAnMinute;
                
                //We only care about the same day
                int daysBetween = (int) minutesBetweenDates / 1440;   //1440 minutes in a day
                
                minutesBetweenDates -= daysBetween*1440;
                
                NSString* addString;
                if (minutesBetweenDates==1)
                    addString = [NSString stringWithFormat:@" (%d %@)", minutesBetweenDates, L(MINUTE)];
                else
                    addString = [NSString stringWithFormat:@" (%d %@)", minutesBetweenDates, L(MINUTES)];
                    
                    
                subtitle = [subtitle stringByAppendingString:addString];
                
                cell.detailTextLabel.text = subtitle;
                
                cell.detailTextLabel.textColor = CELLGRAYCOLOR;
                
                cell.textLabel.font = CELLFONT;
                cell.detailTextLabel.font = CELLFONT;
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                cell.backgroundColor = [UIColor clearColor];
                cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transpbg"]];
                cell.backgroundView.alpha = CELLALPHA;
                
                break;
            }
            case 1:
            {
                cell.textLabel.font = CELLFONT;
                cell.detailTextLabel.font = CELLFONT;
                
                cell.textLabel.textColor = DEFAULTBLUE;
                cell.textLabel.text = L(ADDANEWVISIT);
                
                cell.detailTextLabel.textColor = CELLGRAYCOLOR;
                cell.detailTextLabel.text = L(SELECTLOCATIONFROMMAP);
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.imageView.image = [UIImage imageNamed:@"addBlogPOI"];
                
                cell.backgroundColor = [UIColor clearColor];
                cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transpbg"]];
                cell.backgroundView.alpha = CELLALPHA;
                
                break;
            }
            case 2:
            {
                cell.textLabel.text = L(VISUALIZE);
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.detailTextLabel.text = @"";
                cell.imageView.image = nil;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                cell.textLabel.font = CELLFONT;
                
                cell.backgroundColor = DEFAULTBLUE;
                
                break;
            }
            default:
                break;;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0)
    {
        EditBlogPOIViewController *editBlogPOIVC =[self.storyboard instantiateViewControllerWithIdentifier:@"EditBlogPOIViewID"];
        
        //Pass the poi_id so we can remember what we're changing
        editBlogPOIVC.selectedPOI = ((POI*)[self.pointsOfInterest objectAtIndex:indexPath.row]);
        editBlogPOIVC.blogDate = self.blogDate;
        editBlogPOIVC.delegate = self;
        [self.navigationController pushViewController:editBlogPOIVC animated:YES];
    }
    
    //Pick a location from the map
    if (indexPath.section==1)
    {
        [self startNewVisitProcess];
    }
        
    if (indexPath.section == 2)
    {
        TrajectoryMapViewController *trajectoryMap =[self.storyboard instantiateViewControllerWithIdentifier:@"TrajectoryMapViewID"];
        trajectoryMap.pointsOfInterest = self.pointsOfInterest;
        trajectoryMap.blogDate = self.blogDate;
        [self.navigationController pushViewController:trajectoryMap animated:YES];
    }
}


#pragma mark - Start new visit process

-(void) startNewVisitProcess {
    
    PickLocationViewController *controller = [[PickLocationViewController alloc] init];
    controller.location = Eng.locationTracker.currentlocation;
    controller.showPin = YES;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - Table editing delegate

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0)
        return YES;
    else
        return NO;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    //Invoke the superclass invocation of the method
    [super setEditing:editing animated:animated];
    
    //Send the same message to the tableview
    [self.tableView setEditing:editing animated:YES];
    
    //Update the enabled state of the other button in the navigation bar (a plus-sign button, for adding items)
    
    self.navigationItem.rightBarButtonItems = nil;
    UIBarButtonItem *shareBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"shareblog"] style:UIBarButtonItemStylePlain target:self action:@selector(showShareView)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.editButtonItem, shareBtn, nil];
}


//Customizing the editing style of rows. Showing delete buttons
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}


//Updating the data-model array and deleting the row
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        POI* poi = [self.pointsOfInterest objectAtIndex:indexPath.row];
        
        //Call the service
        BlogEngine* blogEngine = [[BlogEngine alloc] init];
        blogEngine.delegate = self;
        [blogEngine updateBlogPOIForDate:self.blogDate withPOIId:poi.poi_id andDescription:nil withStartDate:nil andEndDate:nil withSeqId:poi.seqid moveToSeqId:poi.seqid shouldBeDeleted:YES];
    }
}


//Custom delete string in row
/*
- (NSString *) tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return L(DELETEBLOGPOI);
}
*/

#pragma mark - Table row move delegate

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section==0)
        return YES;
    else
        return NO;
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    //Destination can only be in section 0
    if (destinationIndexPath.section!=0)
        return;
    
    POI* poi = [self.pointsOfInterest objectAtIndex:sourceIndexPath.row];
    
    POI* destinationPOI = [self.pointsOfInterest objectAtIndex:destinationIndexPath.row];
    
    int newseqID = destinationPOI.seqid;
    
//    if (destinationPOI.seqid > poi.seqid)
//        newseqID = destinationPOI.seqid + 2;
//    else
//        newseqID = destinationPOI.seqid - 2;
    
    //Call the service
    BlogEngine* blogEngine = [[BlogEngine alloc] init];
    blogEngine.delegate = self;
    [blogEngine updateBlogPOIForDate:self.blogDate withPOIId:poi.poi_id andDescription:nil withStartDate:nil andEndDate:nil withSeqId:poi.seqid moveToSeqId:newseqID shouldBeDeleted:NO];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    
    //Go the proposed position if it's in section 0
    if (proposedDestinationIndexPath.section==0)
        return proposedDestinationIndexPath;
    else
        return sourceIndexPath;
}



#pragma mark Get blog POIs call & delegate


-(void)refreshBlog {
    
    BlogEngine* blogEngine = [[BlogEngine alloc] init];
    blogEngine.delegate = self;
    [blogEngine getBlogForDate:self.blogDate];
}

-(void)gotPOISforBlogDate:(NSArray*)pois withStory:(NSString*)story {

    self.pointsOfInterest = pois;
    self.story = story;
    [self.tableView reloadData];
    
    [self addStory];
    
    [self manageNoDataView];
    
    if (self.pointsOfInterest.count>0)
        [self setRightNavigationButtons];
    else
        [self removeRightNavigationButtons];
    
    if (self.story.length==0 || self.pointsOfInterest.count==0)
        [self.refreshControl removeFromSuperview];
}


#pragma mark - Blog updated delegate

-(void)blogUpdated {
    [self refreshBlog];
}



#pragma mark - Pick location delegate

- (void)didEndEditingWithCoordinates:(CLLocation *)coordinates {
    
    NSLog(@"Lat: %f , Lng: %f", coordinates.coordinate.latitude, coordinates.coordinate.longitude);
    
    if (coordinates.coordinate.latitude==0 && coordinates.coordinate.longitude==0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:L(COULDNOTGETCOORDINATES) delegate:self cancelButtonTitle:L(GOTIT) otherButtonTitles:nil];
        [alert show];
        return;
    }

    newVisitLocation = coordinates;
    
    POIEngine* poiEngine = [[POIEngine alloc] init];
    poiEngine.delegate = self;
    [poiEngine findDuplicatesInLocation:newVisitLocation];
}


#pragma mark - Duplicates delegate

-(void) gotDuplicates:(NSArray*)poiList {
    
    if (poiList.count==0)
    {
        //Proceed to add new location
        [self showNewLocationModalVC];
    }
    else
    {
        //Show map with duplicates to choose from
        UINavigationController* selectableMapNav = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectableMapNavID"];
        SelectableMapViewController *selectableMapVC = [selectableMapNav.viewControllers objectAtIndex:0];
        selectableMapVC.delegate = self;
        selectableMapVC.pointsOfInterest = poiList;
        
        [self presentViewController:selectableMapNav animated:YES completion:nil];
    }
}


#pragma mark - Add new location call & delegate

-(void)showNewLocationModalVC {
    
    if (newVisitLocation.coordinate.latitude != 0 && newVisitLocation.coordinate.longitude != 0)
    {
        UINavigationController *navVC =[self.storyboard instantiateViewControllerWithIdentifier:@"AddBlogRecordNavID"];
        AddPOIViewController *vc = [navVC.viewControllers objectAtIndex:0];
        vc.delegate = self;
        vc.poiLocation = newVisitLocation;
        vc.dontSearchForDuplicates = YES;
        vc.isModal = YES;
        [self presentViewController:navVC animated:YES completion:nil];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:L(TRYZOOMINGCLOSER)];
    }
}

-(void)newPOIAdded:(POI*)poi {
    //Open EditBlogPOIVC to put additional info
    [self openEditVCWithPOI:poi forNewSeqID:[self getMaxValueFromArray:seqIDs]+1];
}



#pragma mark - New POI blog visit added

-(void)newVisitAdded {
    [self refreshBlog];
}



#pragma mark - Selected POI from map delegate

- (void)selectedPOIFromMap:(POI*)poi {
    [self openEditVCWithPOI:poi forNewSeqID:[self getMaxValueFromArray:seqIDs]+1000];
}



#pragma mark - Open Edit Blog VC for details

-(void) openEditVCWithPOI:(POI*)poi forNewSeqID:(int)seqid {
    
    //Open EditBlogPOIVC to put additional info
    UINavigationController *navVC =[self.storyboard instantiateViewControllerWithIdentifier:@"EditBlogPOINavID"];
    EditBlogPOIViewController *editBlogPOIVC = [navVC.viewControllers objectAtIndex:0];
    editBlogPOIVC.isNewVisit = YES;
    editBlogPOIVC.selectedPOI = poi;
    editBlogPOIVC.blogDate = self.blogDate;
    editBlogPOIVC.delegate = self;
    editBlogPOIVC.newSeqID = seqid;
    
    [self presentViewController:navVC animated:YES completion:nil];
}


#pragma mark - Duplicates rejected. Wants new POI

-(void)wantsNewPOI {
    //Proceed to add new location
    [self showNewLocationModalVC];
}




#pragma mark - Get Max Value

-(int) getMaxValueFromArray:(NSArray*)values {
    
    int max = 0;
    
    for (NSNumber *i in values)
    {
        int v = [i intValue];
        
        if (v > max) {
            max = v;
        }
    }
    
    return max;
}


@end
