//
//  EditPOIViewController.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 9/20/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "EditPOIViewController.h"
#import "HomeViewController.h"
#import "SearchViewController.h"

@interface EditPOIViewController (){
    
    //Array of POI locations
    NSArray* gMapLocations;
    
    NSArray* pointsOfInterest;
    
    NSDateFormatter *dateFormatter;
    UIDatePicker* datepicker;
    NSMutableString* place;
    NSArray* duplicatePOIS;
    
    //Our editable poi details
    int poi_id;
    NSString* name;
    CLLocation *poiLocation;
    NSArray* keywords;
    NSString* description;
    BOOL publicity;
    
    //Remember cell for resigning firstresponder afterwards
    StringInputTableViewCell *namecell;
    StringInputTableViewCell *descriptioncell;
    StringInputTableViewCell *keywordscell;
    
    Publicity* poiPublicity;
    
    BOOL isTableExpanded;
    
    CGRect originalMapFrame;
    BOOL isDragging;
}

@end



@implementation EditPOIViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //For iOS7
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
        ADJUST_IOS7_LAYOUT
    
    self.title = L(EDIT);
    
    UIImageView* bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mapblur"]];
    self.tableView.backgroundView = bgView;
    
    isTableExpanded = NO;
    isDragging = NO;
    
    //Add a shadow
//    self.tableView.layer.shadowOpacity = 0.7f;
//    self.tableView.layer.shadowRadius = 5.0f;
//    self.tableView.layer.shadowColor = [UIColor blackColor].CGColor;
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:L(SAVE) style:UIBarButtonItemStylePlain target:self action:@selector(savePOI)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    poi_id = self.poi.poi_id;
    
    name = self.poi.name;
    if (name==nil || [name isKindOfClass:[NSNull class]] || [name isEqualToString:@"null"] || name.length==0)
        name = @"";
    
    poiLocation = self.poi.location;
    
    keywords = self.poi.keywords;
    
    description = self.poi.comment;
    if (description==nil || [description isKindOfClass:[NSNull class]] || [description isEqualToString:@"null"] || description.length==0)
        description = @"";
    
    publicity = self.poi.publicity;
    
    poiPublicity = [[Publicity alloc] initWithPublicity:publicity];
    
    //Put POi in pointsOfInterest
    NSMutableArray* arr = [NSMutableArray array];
    [arr addObject:self.poi];
    pointsOfInterest = arr;
    
    //Set delegate to self
    self.gMapView.gMapDelegate = self;
    
    
    //Create map locations
    gMapLocations = [self createMapLocations];
    
    //Set them
    [self.gMapView setLocations:gMapLocations];
    
    //Show with pins
    [self.gMapView show];
    
    [self.tableView setAllowsSelection:YES];
    
    originalMapFrame = self.gMapView.frame;
    
    //Set map zoom level
    MKCoordinateSpan span;
    span.latitudeDelta = 0.002;                                       // From 0.001 to 120
    span.longitudeDelta = 0.002;
    
    MKCoordinateRegion mapRegion = self.gMapView.region;
    mapRegion.span=span;
    
    //Set map region
    [self.gMapView setRegion:mapRegion animated:YES];
    
    //Get addres and show label
    self.addressLabel.text = L(GETTINGADDRESS);
    [self loadAddressFromCoordinates:self.poi.location];
    
    //Add lock icon if poi is not mine
    if (!self.poi.isMine)
    {
        UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
        
        UIImage* lockImage = [UIImage imageNamed:@"private"];
        UIImageView* lock = [[UIImageView alloc] initWithImage:lockImage];
        
        [footerView addSubview:lock];
        
        CGRect lockFrame = lock.frame;
        lockFrame.origin.x = footerView.frame.size.width/2;
        lockFrame.origin.y = 10;
        
        lock.frame = lockFrame;
        
        self.tableView.tableFooterView = footerView;
    }
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
    
    NSString* poiName = poi.name;
    if (poiName.length > 19)
    {
        poiName = [NSString stringWithFormat:@"%@..", [name substringToIndex:17]];
    }
    
    for(int i = 0; i < pointsOfInterest.count; i++)
    {
        poi = [pointsOfInterest objectAtIndex:i];
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [[NSNumber alloc] initWithDouble:poi.location.coordinate.latitude],       MAP_LATITUDE_KEY,
                              [[NSNumber alloc] initWithDouble:poi.location.coordinate.longitude],      MAP_LONGITUDE_KEY,
                              poiName,                                                                  MAP_CALLOUT_KEY,
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
    
    pinView.image = [UIImage imageNamed:@"pinblue"];
//    pinView.pinColor = MKPinAnnotationColorRed;
    pinView.animatesDrop = NO;
    pinView.canShowCallout = YES;
    
    UIImageView* editImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pencil"]];
    editImage.frame = CGRectMake(6, 8, 10, 10);
    
    [pinView addSubview:editImage];

    return pinView;
}


/********************/
//Tableview

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    //Check POI if it's mine
    
    if (self.poi.isMine)
        return 2;
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section==0)
    {
        if (self.poi.isMine)
            return 4;
        else
            return 3;
    }
    else
        return 1;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return L(LOCATIONDETAILS);
    else
        return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    
    if (indexPath.section==0)
    {
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
                }
                
                cell.backgroundColor = [UIColor clearColor];
                cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transpbg"]];
                cell.backgroundView.alpha = CELLALPHA;
                
                namecell = cell;
                
                cell.delegate=self;
                cell.tag = indexPath.row;
                
                cell.imageView.image = [UIImage imageNamed:@"title"];
                cell.textField.placeholder = L(ADDTITLE);
                cell.textField.text = name;
                return cell;
            }
            case 1:
            {
                static NSString *CellIdentifier = @"StringInputCell";
                StringInputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil)
                {
                    //For the default cells
                    cell = [[StringInputTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                
                cell.backgroundColor = [UIColor clearColor];
                cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transpbg"]];
                cell.backgroundView.alpha = CELLALPHA;
                
                keywordscell = cell;
                
                cell.delegate=self;
                cell.tag = indexPath.row;
                
                cell.imageView.image = [UIImage imageNamed:@"tag"];
                cell.textField.placeholder = L(NOKEYWORDSAVAILABLE);
                
                if (keywords!=nil && keywords != (id)[NSNull null] && keywords.count!=0 && ![keywords[0] isEqualToString:@"null"])
                    cell.textField.text = [[keywords valueForKey:@"description"] componentsJoinedByString:@","];
                
                return cell;
            }
            case 2:
            {
                static NSString *CellIdentifier = @"StringInputCell";
                StringInputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil)
                {
                    //For the default cells
                    cell = [[StringInputTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                
                cell.backgroundColor = [UIColor clearColor];
                cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transpbg"]];
                cell.backgroundView.alpha = CELLALPHA;
                
                descriptioncell = cell;
                
                cell.delegate=self;
                cell.tag = indexPath.row;
                
                cell.imageView.image = [UIImage imageNamed:@"activity"];
                cell.textField.placeholder = L(ADDADESCRIPTION);
                cell.textField.text = description;
                return cell;
            }
            case 3:
            {
                if (self.poi.isMine)
                {
                    NSString *CellIdentifier = @"PublicityPickerCell";
                    PublicityCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil)
                    {
                        cell = [[PublicityCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                        cell.delegate = self;
                    }
                    
                    cell.backgroundColor = [UIColor clearColor];
                    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transpbg"]];
                    cell.backgroundView.alpha = CELLALPHA;
                    
                    cell.imageView.image = [UIImage imageNamed:@"publicity"];
                    
                    cell.textLabel.textColor = CELLGRAYCOLOR;
                    cell.textLabel.font = CELLFONT;
                    cell.textLabel.text = poiPublicity.description;
                    
                    cell.detailTextLabel.textColor = DEFAULTBLUE;
                    cell.detailTextLabel.font = CELLFONT;
                    cell.detailTextLabel.text = @"";
                    
                    if (poiPublicity.publicity==YES)
                    {
                        UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"public"]];
                        cell.accessoryView = imageView;
                        [cell setPickerRow:0];
                    }
                    
                    if (poiPublicity.publicity==NO)
                    {
                        UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"private"]];
                        cell.accessoryView = imageView;
                        [cell setPickerRow:1];
                    }
                    
                    cell.accessoryType = 0;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    return cell;
                }
                else
                {
                    static NSString *CellIdentifier = @"Cell";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil)
                    {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                    }
                    
                    cell.backgroundColor = [UIColor clearColor];
                    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transpbg"]];
                    cell.backgroundView.alpha = CELLALPHA;
                    
                    cell.imageView.image = [UIImage imageNamed:@"publicity"];
                    
                    cell.textLabel.textColor = CELLGRAYCOLOR;
                    cell.backgroundColor = [UIColor whiteColor];
                    cell.textLabel.font = CELLFONT;
                    cell.textLabel.text = poiPublicity.description;
                    
                    cell.detailTextLabel.textColor = DEFAULTBLUE;
                    cell.detailTextLabel.font = CELLFONT;
                    cell.detailTextLabel.text = @"";
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    if (poiPublicity.publicity==YES)
                    {
                        UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"public"]];
                        cell.accessoryView = imageView;
                    }
                    
                    if (poiPublicity.publicity==NO)
                    {
                        UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"private"]];
                        cell.accessoryView = imageView;
                    }
                    cell.accessoryType = 0;
                    
                    return cell;
                }
                break;
            }
            default:
                return nil;
        }
    }
    else
    {
        NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        cell.backgroundColor = [UIColor redColor];
        
        cell.textLabel.text = L(DELETE);
        cell.detailTextLabel.text = @"";
        //        cell.imageView.image = nil;
        cell.accessoryType = 0;
        
        cell.textLabel.font = CELLFONTBOLD;
        cell.textLabel.textColor = [UIColor whiteColor];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:L(DELETE) message:L(AREYOUSURE) delegate:self cancelButtonTitle:L(NO) otherButtonTitles:L(YES),nil];
        [alert show];
    }
}


#pragma mark - AlertView delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex==1)
    {
        [self deletePOI];
    }
}



#pragma mark - Pick location delegate

- (void)didEndEditingWithCoordinates:(CLLocation *)coordinates {
    [self loadAddressFromCoordinates:coordinates];
    
    poiLocation = coordinates;
    NSLog(@"Lat: %f , Lng: %f", coordinates.coordinate.latitude, coordinates.coordinate.longitude);
    
    [self.tableView reloadData];
}



#pragma mark - String input delegate


-(void) stratedEditingStringCell {
    [self animateUp];
}

- (void)endedEditingStringCell {
    [self animateDown];
}

- (void)tableViewCell:(StringInputTableViewCell *)cell didEndEditingWithString:(NSString *)value {

    switch (cell.tag)
    {
        case 0:
        {
            name = value;
            NSLog(@"Title: %@", value);
            [self.tableView reloadData];
            break;
        }
        case 1:
        {
            keywords = [value componentsSeparatedByString:@","];
            NSLog(@"Keywords: %@", value);
            [self.tableView reloadData];
            break;
        }
        case 2:
        {
            description = value;
            NSLog(@"Description: %@", value);
            [self.tableView reloadData];
            break;
        }
        default:
            break;
    }
}


#pragma mark - Resign cells

-(void)resignCells {
    [namecell.textField resignFirstResponder];
    [keywordscell.textField resignFirstResponder];
    [descriptioncell.textField resignFirstResponder];
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


#pragma mark - Publicity picker delegate

- (void)tableViewCell:(PublicityCell *)cell didEndEditingWithPublicity:(Publicity *)value {
    
    poiPublicity = value;
    NSLog(@"POI will be: %@", poiPublicity.description);
    [self.tableView reloadData];
}



#pragma mark - Save POI clicked

-(void) savePOI {
    
    [self resignCells];
    
    //Checking the input data
    if (poiLocation.coordinate.latitude == 0 || poiLocation.coordinate.longitude == 0)
    {
        [SVProgressHUD showErrorWithStatus:L(NOLOCATIONSELECTED)];
        [self resignCells];
        [self animateDown];
        return;
    }
    
    if ([self isEmptyString:namecell.textField.text] || [self.title isEqualToString:L(ADDTITLE)])
    {
        [SVProgressHUD showErrorWithStatus:L(EMPTYTITLE)];
        [self resignCells];
        [self animateDown];
        return;
    }
    
    if ([self isEmptyString:descriptioncell.textField.text] || [self.description isEqualToString:L(ADDADESCRIPTION)])
    {
        [SVProgressHUD showErrorWithStatus:L(EMPTYDESCRIPTION)];
        [self resignCells];
        [self animateDown];
        return;
    }
    
    [self editPOI];
}


#pragma mark - Edit POI call & delegate


-(void)editPOI {
    
    [self animateDown];
    
    NSLog(@"Saving edited POI..");
    
    POIEngine* poiEngine = [[POIEngine alloc] init];
    poiEngine.delegate = self;
    [poiEngine editPOIWithID:poi_id name:name publicity:poiPublicity.publicity keywords:keywords description:description];
}


-(void) poiEdited {
    
    NSLog(@"POI edited");

    //Call the delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(updatePinWithTag:name:location:descriptiom:publicity:andKeywords:)])
        [self.delegate updatePinWithTag:self.tag name:name location:poiLocation descriptiom:description publicity:poiPublicity.publicity andKeywords:keywords];
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Delete POI call & delegate

-(void) deletePOI {
    
    [self animateDown];
    
    NSLog(@"Deleting POI..");
    
    POIEngine* poiEngine = [[POIEngine alloc] init];
    poiEngine.delegate = self;
    [poiEngine deletePOIWithID:poi_id];
}


-(void) poiDeleted {
    
    NSLog(@"POI deleted");

    //Call the delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(removePinWithTag:)])
        [self.delegate removePinWithTag:self.tag];
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Map animations

-(void) animateUp {
    
    if (!isTableExpanded)
    {
        [UIView animateWithDuration:0.5 animations:^{
            
            CGRect tableViewFrame = self.tableView.frame;
            tableViewFrame.origin.y = 0 + self.addressLabel.frame.size.height;
            tableViewFrame.size.height = self.view.frame.size.height - self.addressLabel.frame.size.height;
            self.tableView.frame = tableViewFrame;
            
            isTableExpanded = YES;
        }];
    }
}

-(void) animateDown {
    
    if (isTableExpanded)
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.gMapView.frame = originalMapFrame;
            
            CGRect tableViewFrame = self.tableView.frame;
            tableViewFrame.origin.y = originalMapFrame.size.height;
            tableViewFrame.size.height = self.view.frame.size.height - originalMapFrame.size.height;
            self.tableView.frame = tableViewFrame;
            
            isTableExpanded = NO;
        }];
    }
}


#pragma mark - Orientation delegates

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    
    if ([namecell.textField isFirstResponder] || [keywordscell.textField isFirstResponder] || [descriptioncell.textField isFirstResponder])
    {
        [self resignCells];
        [self animateDown];
    }
}


- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    originalMapFrame = self.gMapView.frame;
    
    [UIView animateWithDuration:0.5 animations:^{
        
        CGRect tableViewFrame = self.tableView.frame;
        tableViewFrame.origin.y = self.gMapView.frame.size.height;
        tableViewFrame.size.height = self.view.frame.size.height - self.gMapView.frame.size.height;
        self.tableView.frame = tableViewFrame;
    }];
    
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
