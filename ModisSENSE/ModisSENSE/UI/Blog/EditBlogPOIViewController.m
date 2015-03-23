//
//  EditBlogPOIViewController.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 10/3/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "EditBlogPOIViewController.h"
#import "EditBlogViewController.h"
#import "POI.h"
#import "Engine.h"
#import "UIConstants.h"
#import "SVProgressHUD.h"
#import "Util.h"

@interface EditBlogPOIViewController () {
    
    NSArray* pointsOfInterest;
    
    //Array of POI locations
    NSArray* gMapLocations;
    
    NSMutableString* place;
    
    NSDate* startDate;
    NSDate* endDate;
    NSString* description;
    
    CLLocation* correctPoiLocation;
    BOOL startDateEdited;
    BOOL endDateEdited;
    BOOL descriptionEdited;
    
    NSDateFormatter *dateFormatter;
    
    CGRect originalMapFrame;
    BOOL isDragging;
}

@end


@implementation EditBlogPOIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //For iOS7
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
        ADJUST_IOS7_LAYOUT
        
    UIImageView* bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mapblur"]];
    self.tableView.backgroundView = bgView;
        
    startDateEdited = NO;
    endDateEdited = NO;
    descriptionEdited = NO;
    
    isDragging = NO;
        
    //Put selected POI first in the pointsOfInterest. 1st one will be red, the others will be green
    NSMutableArray* arr = [NSMutableArray array];
    [arr addObject:self.selectedPOI];
    pointsOfInterest = arr;
        
    self.title = self.selectedPOI.name;
    
    if (!self.isNewVisit)
    {
        UIBarButtonItem* saveButton = [[UIBarButtonItem alloc] initWithTitle:L(RESET) style:UIBarButtonItemStylePlain target:self action:@selector(reset)];
        self.navigationItem.rightBarButtonItem = saveButton;
    }
    else
    {
        UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:L(CANCEL) style:UIBarButtonItemStylePlain target:self action:@selector(closeModal)];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"yyy-MM-dd HH:mm:ss"];
    
    //Set delegate to self
    self.gMapView.gMapDelegate = self;
    
    
    //Create map locations
    gMapLocations = [self createMapLocations];
    
    //Set them
    [self.gMapView setLocations:gMapLocations];
    
    //Show with pins
    [self.gMapView show];
    
    originalMapFrame = self.gMapView.frame;
    
    //Set map zoom level
    MKCoordinateSpan span;
    span.latitudeDelta = 0.002;                                       // From 0.001 to 120
    span.longitudeDelta = 0.002;
    
    MKCoordinateRegion mapRegion = self.gMapView.region;
    mapRegion.span=span;
    
    //Set map region
    [self.gMapView setRegion:mapRegion animated:YES];
    
    if ([Util isEmptyString:self.selectedPOI.startDate])
        self.selectedPOI.startDate = [self.blogDate stringByAppendingString:@" 12:15:00"];
    
    if ([Util isEmptyString:self.selectedPOI.endDate])
        self.selectedPOI.endDate = [self.blogDate stringByAppendingString:@" 13:00:00"];
    
    startDate = [dateFormatter dateFromString:self.selectedPOI.startDate];
    endDate = [dateFormatter dateFromString:self.selectedPOI.endDate];
    description = self.selectedPOI.comment;
    
    //Get addres and show label
    self.addressLabel.text = L(GETTINGADDRESS);
    [self loadAddressFromCoordinates:self.selectedPOI.location];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Create locations array

-(NSArray *)createMapLocations {
    
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    
    if (!pointsOfInterest || pointsOfInterest.count == 0)
        return nil;
    
    POI *poi;
    
    NSString* name = poi.name;
    if (name.length > 19)
    {
        name = [NSString stringWithFormat:@"%@..", [name substringToIndex:17]];
    }
    
    for(int i = 0; i < pointsOfInterest.count; i++)
    {
        poi = [pointsOfInterest objectAtIndex:i];
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [[NSNumber alloc] initWithDouble:poi.location.coordinate.latitude],       MAP_LATITUDE_KEY,
                              [[NSNumber alloc] initWithDouble:poi.location.coordinate.longitude],      MAP_LONGITUDE_KEY,
                              name,                                                                     MAP_CALLOUT_KEY,
                              poi.comment,                                                              MAP_CALLOUT_SUB_KEY,
                              [[NSNumber alloc] initWithInt:i],                                         MAP_TAG_KEY,
                              [[NSNumber alloc] initWithInt:EPinDefault],                               MAP_PIN_TYPE_KEY,
                              nil];
        
        [locations addObject:dict];
    }
    return locations;
}



#pragma mark - MapView delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    // in case it's the user location just return nil
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    
    // Dequeue an existing pin view first
    static NSString *annotationIdentifier = @"annotationIdentifier";
    
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    
    if (pinView == nil)
    {
        // if an existing pin view was not available, create one
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
    }
    
    if ([(MapAnnotation *)annotation tag]==0)
        pinView.animatesDrop = NO;
    else
        pinView.animatesDrop = YES;
    
    pinView.canShowCallout = YES;
    
    if (pointsOfInterest.count>0)
    {
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        rightButton.frame = CGRectMake(0.0, 0.0, 16.0, 16.0);
        [rightButton setImage:[UIImage imageNamed:@"target"] forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(selectedPOI:) forControlEvents:UIControlEventTouchUpInside];
        
        //Set a tag to the info button so we know what button was pressed
        rightButton.tag = [(MapAnnotation *)annotation tag];
        
//        pinView.rightCalloutAccessoryView = rightButton;
        
        //First will be the actual poi, the others will be the suggested ones
        if ([(MapAnnotation *)annotation tag]==0)
        {
            pinView.image = [UIImage imageNamed:@"pinblue"];
            
            UIImageView* editImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_blogs"]];
            editImage.frame = CGRectMake(6, 8, 10, 10);
            
            [pinView addSubview:editImage];
        }
        else
            pinView.pinColor = MKPinAnnotationColorGreen;
    }
    return pinView;
}


#pragma mark - Change poi coordinates after selecting the correct POI

-(void)selectedPOI:(UIButton*)infoButton {
    
    NSLog(@"Selected POI: %d,",infoButton.tag);
    
    correctPoiLocation = ((POI*)[pointsOfInterest objectAtIndex:infoButton.tag]).location;
    [self.tableView reloadData];
}




/**************************************************/
//TableView code


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
        return 1;
    else if (section == 1)
        return 2;
    else
        return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return L(CHANGEACTIVITY);
    else if (section == 1)
        return L(CHANGEDURATION);
    else
        return nil;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        {
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            }
            
            cell.textLabel.textColor = [UIColor blackColor];
            cell.backgroundColor = [UIColor whiteColor];
            cell.textLabel.font = CELLFONT;
            cell.detailTextLabel.font = CELLFONT;
            cell.textLabel.text = self.selectedPOI.name;
            
            //Check if description is null or empty
            if (description==nil || [description isEqualToString:@"null"] || description.length==0)
                description = L(NODESCRIPTIONAVAILABLE);
            
            cell.detailTextLabel.text = description;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transpbg"]];
            cell.backgroundView.alpha = CELLALPHA;
            
            if (descriptionEdited)
                cell.detailTextLabel.textColor = DARKGREEN;
            else
                cell.detailTextLabel.textColor = CELLGRAYCOLOR;
            
            cell.accessoryType = 0;
            
            return cell;
        }
        case 1:
        {
            if (indexPath.row == 0)
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
                
                cell.backgroundColor = [UIColor clearColor];
                cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transpbg"]];
                cell.backgroundView.alpha = CELLALPHA;
                
                cell.tag = indexPath.row;
                cell.imageView.image = [UIImage imageNamed:@"from"];
                
                
                cell.textLabel.textColor = CELLGRAYCOLOR;
                cell.textLabel.text = L(STARTDATE);
                
                if (startDateEdited)
                    cell.detailTextLabel.textColor = DARKGREEN;
                else
                    cell.detailTextLabel.textColor = DEFAULTBLUE;
                
                cell.datePickerMode = UIDatePickerModeTime;
                cell.dateValue = startDate;
                
                return cell;
            }
            
            if (indexPath.row == 1)
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
                
                cell.backgroundColor = [UIColor clearColor];
                cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transpbg"]];
                cell.backgroundView.alpha = CELLALPHA;
                
                cell.tag = indexPath.row;
                cell.imageView.image = [UIImage imageNamed:@"to"];

                
                cell.textLabel.textColor = CELLGRAYCOLOR;
                cell.textLabel.text = L(ENDDATE);
                
                if (endDateEdited)
                    cell.detailTextLabel.textColor = DARKGREEN;
                else
                    cell.detailTextLabel.textColor = DEFAULTBLUE;
                
                cell.datePickerMode = UIDatePickerModeTime;
                cell.dateValue = endDate;
                
                return cell;
            }
        }
        case 2:
        {
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            }
            
            cell.textLabel.text = L(SAVECHANGES);
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.text = @"";
            cell.imageView.image = nil;
            cell.accessoryType = 0;
            
            cell.textLabel.font = CELLFONTBOLD;
            cell.backgroundColor = DARKGREEN;
            
            return cell;
        }
        default:
            return nil;
    }
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.section == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:L(CHANGEACTIVITY) message:L(DESCRIBEACTIVITY) delegate:self cancelButtonTitle:L(CANCEL) otherButtonTitles:L(DONE),nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
    }
    
    if (indexPath.section == 2)
    {
        [self updateBlogPOI];
    }
}


#pragma mark - AlertView delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex==1)
    {
        description = [alertView textFieldAtIndex:0].text;
        
        if ([Util isEmptyString:description])
        {
            [SVProgressHUD showErrorWithStatus:L(EMPTYDESCRIPTION)];
            description = self.selectedPOI.comment;
        }
        else
        {
            descriptionEdited = YES;
        }
        
        [self.tableView reloadData];
    }
}


#pragma mark - Date Picker delegate

- (void)tableViewCell:(DateInputTableViewCell *)cell didEndEditingWithDate:(NSDate *)value {
    if (cell.tag == 0)
    {
        startDateEdited = YES;
        startDate = value;
        NSLog(@"Start Date: %@",[dateFormatter stringFromDate:startDate]);
    }
    else if (cell.tag == 1)
    {
        endDateEdited = YES;
        endDate = value;
        NSLog(@"End Date: %@",[dateFormatter stringFromDate:endDate]);
    }
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:cell.tag inSection:1];
    DateInputTableViewCell *dateCell = (DateInputTableViewCell*) [self.tableView cellForRowAtIndexPath:indexPath];
    dateCell.detailTextLabel.textColor = DARKGREEN;
}


#pragma mark - Save Blog POI call & delegate

-(void)updateBlogPOI {
    
    if ( ([startDate compare:endDate] == NSOrderedDescending) || (startDate && !endDate) || (!startDate && endDate) )
    {
        [SVProgressHUD showErrorWithStatus:L(CHECKDURATION)];
        return;
    }
    
    if (self.isNewVisit)
    {
        //Add New Visit service
        NSLog(@"Adding new visit");
        
        BlogEngine* blogEng = [[BlogEngine alloc] init];
        blogEng.delegate = self;
        
        [blogEng addNewVisitForBlogDate:self.blogDate withPOIId:self.selectedPOI.poi_id toSeqPlace:self.newSeqID withstartDate:[dateFormatter stringFromDate:startDate] andEndDate:[dateFormatter stringFromDate:endDate] withComment:description andPublicity:self.selectedPOI.publicity];
    }
    else
    {
        //Update Blog POI service
        NSLog(@"Updating blog poi");
        
        BlogEngine* blogEng = [[BlogEngine alloc] init];
        blogEng.delegate = self;
        
        [blogEng updateBlogPOIForDate:self.blogDate withPOIId:self.selectedPOI.poi_id andDescription:description withStartDate:[dateFormatter stringFromDate:startDate] andEndDate:[dateFormatter stringFromDate:endDate] withSeqId:self.selectedPOI.seqid moveToSeqId:self.selectedPOI.seqid shouldBeDeleted:NO];
    }
}


#pragma mark - Blog updated delegate

-(void)blogUpdated {
    NSLog(@"Blog updated");
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(refreshBlog)]) {
        [self.delegate refreshBlog];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Visit added delegate

-(void)visitAdded {
    
    [self dismissViewControllerAnimated:YES completion:
     ^{if (self.delegate && [self.delegate respondsToSelector:@selector(newVisitAdded)]) {
        [self.delegate newVisitAdded];
    }}];
}


#pragma mark - Reset changes

-(void)reset {
    startDateEdited = NO;
    endDateEdited = NO;
    descriptionEdited = NO;
    
    startDate = [dateFormatter dateFromString:self.selectedPOI.startDate];
    endDate = [dateFormatter dateFromString:self.selectedPOI.endDate];
    description = self.selectedPOI.comment;
    [self.tableView reloadData];
}


#pragma mark - Close Modal

-(void)closeModal {
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - API to get address from coordinates

- (void)loadAddressFromCoordinates: (CLLocation *)coordinates {
    //Start request for address details
    AddressCoordinates *addresscrd = [[AddressCoordinates alloc] init];
    addresscrd.delegate = self;
    addresscrd.dontShowProgress = YES;
    [addresscrd getAddress:coordinates];
}


-(void)addressFound:(MKPlacemark *)placemark {
    place = [NSMutableString string];
    
    if (![self isNull:placemark.thoroughfare] && ![self isEmptyString:placemark.thoroughfare]) {
        [place appendString:placemark.thoroughfare];
    }
    if (![self isNull:placemark.subThoroughfare] && ![self isEmptyString:placemark.subThoroughfare]) {
        if ([place length] > 0) [place appendString:@" "];
        [place appendString:placemark.subThoroughfare];
    }
    if (![self isNull:placemark.locality] && ![self isEmptyString:placemark.locality]) {
        if ([place length] > 0) [place appendString:@", "];
        [place appendString:placemark.locality];
    }
    if (![self isNull:placemark.postalCode] && ![self isEmptyString:placemark.postalCode]) {
        if ([place length] > 0) [place appendString:@", "];
        [place appendString:placemark.postalCode];
    }
    if (![self isNull:placemark.administrativeArea] && ![self isEmptyString:placemark.administrativeArea]) {
        if ([place length] > 0) [place appendString:@" "];
        [place appendString:placemark.administrativeArea];
    }
    if (![self isNull:placemark.country] && ![self isEmptyString:placemark.country]) {
        if ([place length] > 0) [place appendString:@" "];
        [place appendString:placemark.country];
    }
    
    NSLog(@"Place: %@", place);
    
    if (place==nil || [place isEqual:@""])
        self.addressLabel.text = L(NOADDRESSAVAILABLE);
    else
        self.addressLabel.text = place;
    
    [self.tableView reloadData];
}


#pragma mark - Methods for emptiness check

- (BOOL) isNull:(id)obj {
    return obj == nil || [obj isKindOfClass:[NSNull class]];
}
- (BOOL) isEmptyString:(id)obj {
    return obj == nil || ![obj isKindOfClass:[NSString class]] || ![obj length];
}


#pragma mark - Orientation delegate

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    originalMapFrame = self.gMapView.frame;
}


#pragma mark - ScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self strechMap:scrollView];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    isDragging = YES;
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    isDragging = NO;
    
    if (self.tableView.frame.origin.y < self.addressLabel.frame.size.height)
    {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect tableViewFrame = self.tableView.frame;
            tableViewFrame.origin.y = self.addressLabel.frame.size.height;
            self.tableView.frame = tableViewFrame;
        }];
    }
    
    if (self.gMapView.frame.size.height > originalMapFrame.size.height)
        [self unStrechMap];
}



-(void)strechMap:(UIScrollView *)scrollView {
    
    if (isDragging)
    {
        CGRect mapFrame = self.gMapView.frame;
        mapFrame.origin.y = 0;
        mapFrame.size.height = mapFrame.size.height - scrollView.contentOffset.y;
        self.gMapView.frame = mapFrame;
        
        CGRect tableViewFrame = self.tableView.frame;
        tableViewFrame.origin.y = self.gMapView.frame.size.height;
        tableViewFrame.size.height = self.view.frame.size.height - self.gMapView.frame.size.height;
        self.tableView.frame = tableViewFrame;
    }
}

-(void)unStrechMap {
    
    [UIView animateWithDuration:0.2 animations:^{
        
        self.gMapView.frame = originalMapFrame;
        
        CGRect tableViewFrame = self.tableView.frame;
        tableViewFrame.origin.y = self.gMapView.frame.size.height;
        tableViewFrame.size.height = self.view.frame.size.height - self.gMapView.frame.size.height;
        self.tableView.frame = tableViewFrame;
        
        [self.tableView setContentOffset:CGPointZero animated:NO];
    }];
}

@end
