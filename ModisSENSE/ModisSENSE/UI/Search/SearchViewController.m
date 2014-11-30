//
//  SearchViewController.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/15/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController () {
    
    NSMutableString *address;
    
    NSDateFormatter *dateFormatter;
    UIDatePicker* datepicker;
    
    //Remember cell for resigning firstresponder afterwards
    StringInputTableViewCell *stringcell;
    
    //Search criteria data
    NSArray* keywords;
    CLLocation* centerLocation;
    NSDate* startDate;
    NSDate* endDate;
    NSArray* friendIDs;
    Classification* orderby;
    int numberOfResults;
    
    MKCoordinateRegion searchRegion;
    CLLocationCoordinate2D northWestCorner;     //Upper left of the selected rect of the map
    CLLocationCoordinate2D southEastCorner;     //Down right of the selected rect of the map
}

@end

@implementation SearchViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    //Set up search button
    [self.searchButton setTitle:L(SEARCH) forState:UIControlStateNormal];
    [self.searchButton addTarget:self action:@selector(search)forControlEvents:UIControlEventTouchUpInside];
    
    //Set Navigation bar title
    self.title = L(SEARCH);
    
    //Start with hotness order
    orderby = [[Classification alloc] initWithOrder:HOTNESS];
    
    //Initial value is 25
    numberOfResults = 25;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"yyy-MM-dd HH:mm:ss"];
    
    //Put a clear button up right
    UIBarButtonItem* clearButton = [[UIBarButtonItem alloc] initWithTitle:L(CLEAR) style:UIBarButtonItemStylePlain target:self action:@selector(clearSearch)];
    self.navigationItem.rightBarButtonItem = clearButton;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 7;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return L(SEARCHCR);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    
    switch (row)
    {
        case 0:
        {
            static NSString *CellIdentifier = @"StringInputCell";
            StringInputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
            if (cell == nil)
            {
                //For the default cells
                cell = [[StringInputTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                stringcell = cell;
            }
            cell.delegate=self;
            
            cell.imageView.image = [UIImage imageNamed:@"search"];
            cell.textField.placeholder = L(SEARCHCRITERIA);
            return cell;
        }
        case 1:
        {
            NSString *CellIdentifier = @"AddressPickerCell";
            LocationMarqueeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil)
            {
                cell = [[LocationMarqueeCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
            }
            
            if (![self isEmptyString:address])
            {
                NSString* a = L(MAPAREASELECTED);
                
                cell.marqueeLabel.text = [a stringByAppendingString:address];
                cell.marqueeLabel.textColor = DEFAULTBLUE;
            }
            else
            {
                cell.marqueeLabel.text = L(CHOOSESEARCHAREA);
                cell.marqueeLabel.textColor = [UIColor redColor];
            }
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
        }
        case 2:
        {
            NSString *CellIdentifier = @"SearchDateInputCell";
            DateInputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil)
            {
                cell = [[DateInputTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.delegate = self;
                cell.textLabel.font = CELLFONT;
                cell.detailTextLabel.font = CELLFONT;
            }
            
            cell.tag = row;
            cell.imageView.image = [UIImage imageNamed:@"from"];
            
            [cell setMaxDate:[NSDate date]];
            
            cell.textLabel.textColor = CELLGRAYCOLOR;
            cell.textLabel.text = L(STARTDATE);
            
            cell.detailTextLabel.textColor = DEFAULTBLUE;
            
            cell.datePickerMode = UIDatePickerModeDateAndTime;
            cell.dateValue = startDate;
            
            if (!startDate)
                cell.detailTextLabel.text = L(NODATESET);
            
            return cell;
        }
        case 3:
        {
            NSString *CellIdentifier = @"SearchDateInputCell";
            DateInputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil)
            {
                cell = [[DateInputTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.delegate = self;
                cell.textLabel.font = CELLFONT;
                cell.detailTextLabel.font = CELLFONT;
            }
            
            cell.tag = row;
            cell.imageView.image = [UIImage imageNamed:@"to"];
            
            [cell setMaxDate:[NSDate date]];
            
            cell.textLabel.textColor = CELLGRAYCOLOR;
            cell.textLabel.text = L(ENDDATE);
            
            cell.detailTextLabel.textColor = DEFAULTBLUE;
            
            cell.datePickerMode = UIDatePickerModeDateAndTime;
            cell.dateValue = endDate;
            
            if (!endDate)
                cell.detailTextLabel.text = L(NODATESET);
            
            return cell;
        }
        case 4:
        {
            NSString *CellIdentifier = @"ClassificationPickerCell";
            ClassificationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil)
            {
                cell = [[ClassificationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.delegate = self;
            }
            
            cell.imageView.image = [UIImage imageNamed:@"feed"];
            
            cell.textLabel.textColor = CELLGRAYCOLOR;
            cell.textLabel.font = CELLFONT;
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", orderby.description, L(RESULTS)];
            
            cell.detailTextLabel.textColor = DEFAULTBLUE;
            cell.detailTextLabel.font = CELLFONT;
            cell.detailTextLabel.text = @"";
            
            if ([orderby.classification isEqualToString:HOTNESS])
            {
                UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hot"]];
                cell.accessoryView = imageView;
            }
            
            if ([orderby.classification isEqualToString:INTEREST])
            {
                UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"interesting"]];
                cell.accessoryView = imageView;
            }
            
            cell.accessoryType = 0;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
            break;
        }
        case 5:
        {
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil)
            {
                //For the default cells
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            }
            cell.imageView.image = [UIImage imageNamed:@"friends"];
            
            cell.textLabel.textColor = CELLGRAYCOLOR;
            cell.textLabel.font = CELLFONT;
            cell.textLabel.text = L(FRIENDSFILTER);
            
            cell.detailTextLabel.textColor = DEFAULTBLUE;
            cell.detailTextLabel.font = CELLFONT;
            
            if (friendIDs.count==0)
                cell.detailTextLabel.text = L(NOFILTER);
            else
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@", friendIDs.count, L(FRIENDS)];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
        }
        case 6:
        {
            SliderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StepperCell"];
            cell.delegate = self;
            
            cell.title.textColor = CELLGRAYCOLOR;
            
            //Initial value is 25
            cell.title.text = [NSString stringWithFormat:@"%@ (%d)",L(NUMBEROFRESULTS), numberOfResults];
            cell.selectionStyle=0;
            
            return cell;
        }
        default:
            return nil;
    }
}



#pragma mark - Tableview selected row delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Pick a location from the map
    switch (indexPath.row)
    {
        case 1:
        {
            PickLocationViewController *controller = [[PickLocationViewController alloc] init];
            controller.showPin = NO;
            controller.delegate = self;
            [self.navigationController pushViewController:controller animated:YES];
            
            break;
        }
        case 5:
        {
            if (Eng.user.twitterFriends.count>0 || Eng.user.facebookFriends.count>0 || Eng.user.foursquareFriends.count>0)
            {
                SearchUserTableViewController *userSelection =[self.storyboard instantiateViewControllerWithIdentifier:@"SearchUserTableID"];
                userSelection.delegate=self;
                
                if (friendIDs.count>0)
                    userSelection.selectedFriendIDs = [[NSMutableArray alloc] initWithArray:friendIDs];
                else
                    userSelection.selectedFriendIDs = [[NSMutableArray alloc] init];
                    
                [self.navigationController pushViewController:userSelection animated:YES];
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:L(NOFRIENDSAVAILABLE)];
            }
            break;
        }
        default:
            break;
    }
}


#pragma mark - String input delegate

- (void)tableViewCell:(StringInputTableViewCell *)cell didEndEditingWithString:(NSString *)value {

    keywords = [value componentsSeparatedByString:@","];
    NSLog(@"Search criteria: %@", value);
    
    [self.tableView reloadData];
}



#pragma mark - Pick location delegate

- (void)didEndEditingWithCoordinates:(CLLocation *)coordinates {
    [self loadAddressFromCoordinates:coordinates];
    
    centerLocation = coordinates;
    NSLog(@"Lat: %f , Lng: %f", coordinates.coordinate.latitude, coordinates.coordinate.longitude);
    
    [self.tableView reloadData];
}



#pragma mark - Get selected region from map delegate

- (void) didEndEditingWithRegion:(MKCoordinateRegion)region {
    
    searchRegion = region;
    northWestCorner.latitude  = region.center.latitude  - (region.span.latitudeDelta  / 2.0);
    northWestCorner.longitude = region.center.longitude - (region.span.longitudeDelta / 2.0);
    southEastCorner.latitude  = region.center.latitude  + (region.span.latitudeDelta  / 2.0);
    southEastCorner.longitude = region.center.longitude + (region.span.longitudeDelta / 2.0);
    
    NSLog(@"Selected Map rect:");
    NSLog(@"North West coordinates Lat:%f Lng:%f",northWestCorner.latitude,northWestCorner.longitude);
    NSLog(@"South East coordinates Lat:%f Lng:%f",southEastCorner.latitude,southEastCorner.longitude);
}



#pragma mark - API to get address from coordinates

- (void)loadAddressFromCoordinates: (CLLocation *)coordinates {
    //Start request for address details
    AddressCoordinates *addresscrd = [[AddressCoordinates alloc] init];
    addresscrd.delegate = self;
    [addresscrd getAddress:coordinates];
}


-(void)addressFound:(MKPlacemark *)placemark {
    address = [NSMutableString string];
    
    if (![self isNull:placemark.thoroughfare] && ![self isEmptyString:placemark.thoroughfare]) {
        [address appendString:placemark.thoroughfare];
    }
    if (![self isNull:placemark.subThoroughfare] && ![self isEmptyString:placemark.subThoroughfare]) {
        if ([address length] > 0) [address appendString:@" "];
        [address appendString:placemark.subThoroughfare];
    }
    if (![self isNull:placemark.locality] && ![self isEmptyString:placemark.locality]) {
        if ([address length] > 0) [address appendString:@", "];
        [address appendString:placemark.locality];
    }
    if (![self isNull:placemark.postalCode] && ![self isEmptyString:placemark.postalCode]) {
        if ([address length] > 0) [address appendString:@", "];
        [address appendString:placemark.postalCode];
    }
    if (![self isNull:placemark.administrativeArea] && ![self isEmptyString:placemark.administrativeArea]) {
        if ([address length] > 0) [address appendString:@" "];
        [address appendString:placemark.administrativeArea];
    }
    if (![self isNull:placemark.country] && ![self isEmptyString:placemark.country]) {
        if ([address length] > 0) [address appendString:@" "];
        [address appendString:placemark.country];
    }
    
    NSLog(@"Got address from location: %@", address);
    
    [self.tableView reloadData];
}


#pragma mark - Methods for emptiness check

- (BOOL) isNull:(id)obj {
    return obj == nil || [obj isKindOfClass:[NSNull class]];
}
- (BOOL) isEmptyString:(id)obj {
    return obj == nil || ![obj isKindOfClass:[NSString class]] || ![obj length];
}


#pragma mark - Date Picker delegate

- (void)tableViewCell:(DateInputTableViewCell *)cell didEndEditingWithDate:(NSDate *)value {
    if (cell.tag == 2)
    {
        startDate = value;
//        NSTimeInterval startTimestamp = [startDate timeIntervalSince1970];
        NSLog(@"Start Date: %@",[dateFormatter stringFromDate:startDate]);
    }
    else if (cell.tag == 3)
    {
        endDate = value;
//        NSTimeInterval endTimestamp = [endDate timeIntervalSince1970];
        NSLog(@"End Date: %@",[dateFormatter stringFromDate:endDate]);
    }
}


#pragma mark - Order by delegate

- (void)tableViewCell:(ClassificationCell *)cell didEndEditingWithClassification:(Classification *)value {
    orderby = value;
    NSLog(@"Order by: %@", orderby.classification);
    [self.tableView reloadData];
}


#pragma mark - User selection delegate

-(void)selectedFriends:(NSArray*)friendids {
    
    friendIDs = friendids;
    [self.tableView reloadData];
}


#pragma mark - Slider delegate

- (void)valueFromSlider:(int)value {
    
    numberOfResults = value;
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:6 inSection:0];
    SliderCell *cell = (SliderCell *) [self.tableView cellForRowAtIndexPath:indexPath];
    
    cell.title.text = [NSString stringWithFormat:@"%@ (%d)",L(NUMBEROFRESULTS), value];
}


#pragma mark - Search button clicked

- (void)search {
    
    //Resign textfield first reposnder if it isn't already
    [stringcell.textField resignFirstResponder];
    
    
    if (northWestCorner.latitude == 0 || northWestCorner.longitude == 0 || southEastCorner.latitude == 0 || southEastCorner.longitude == 0)
    {
        [SVProgressHUD showErrorWithStatus:L(SELECTSEARCHAREA)];
        return;
    }
    
    if ( ([startDate compare:endDate] == NSOrderedDescending) || (startDate && !endDate) || (!startDate && endDate) )
    {
        [SVProgressHUD showErrorWithStatus:L(CHECKDATEORDER)];
        return;
    }

    NSMutableArray* mapRect = [NSMutableArray array];
    [mapRect addObject:[NSNumber numberWithDouble:northWestCorner.latitude]];
    [mapRect addObject:[NSNumber numberWithDouble:northWestCorner.longitude]];
    [mapRect addObject:[NSNumber numberWithDouble:southEastCorner.latitude]];
    [mapRect addObject:[NSNumber numberWithDouble:southEastCorner.longitude]];
    
    POIEngine* poiEngine = [[POIEngine alloc] init];
    poiEngine.delegate=self;
    [poiEngine getPOIsIn:mapRect withKeywords:keywords forFriends:friendIDs fromDate:[dateFormatter stringFromDate:startDate] toDate:[dateFormatter stringFromDate:endDate] withOrder:orderby.classification andNoOfResults:numberOfResults];

}


#pragma mark - Get POIs delegate

-(void)gotPOIs:(NSArray*) poiList {
    
    if (poiList.count>0)
    {
        MapResultsViewController *mapResultsVC =[self.storyboard instantiateViewControllerWithIdentifier:@"MapResultsViewID"];
        mapResultsVC.region = searchRegion;
        mapResultsVC.showTrajectory = NO;
        mapResultsVC.pointsOfInterest = poiList;
        [self.navigationController pushViewController:mapResultsVC animated:YES];
    }
}


#pragma mark - Clear search fields

-(void) clearSearch {
    address = nil;
    friendIDs = nil;
    startDate = nil;
    endDate = nil;
    northWestCorner.latitude = 0;
    northWestCorner.longitude = 0;
    southEastCorner.latitude = 0;
    southEastCorner.longitude = 0;
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    StringInputTableViewCell *cell = (StringInputTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
    cell.textField.text = @"";
    
    [self.tableView reloadData];
}

@end
