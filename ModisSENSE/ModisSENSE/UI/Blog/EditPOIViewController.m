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
    NSDateFormatter *dateFormatter;
    UIDatePicker* datepicker;
    NSMutableString* place;
    NSArray* duplicatePOIS;
    
    //Remember cell for resigning firstresponder afterwards
    StringInputTableViewCell *namecell;
    StringInputTableViewCell *descriptioncell;
    StringInputTableViewCell *keywordscell;
    
    Publicity* poiPublicity;
}

@end



@implementation EditPOIViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = L(EDIT);
    
    place = (NSMutableString*) @"";
    
    poiPublicity = [[Publicity alloc] initWithPublicity:YES];
    
    [self loadAddressFromCoordinates:self.poiLocation];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:L(SAVE) style:UIBarButtonItemStylePlain target:self action:@selector(savePOI)];
    self.navigationItem.rightBarButtonItem = doneButton;
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
        return 5;
    else
        return 1;
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
                namecell = cell;
                
                cell.delegate=self;
                cell.tag = indexPath.row;
                
                cell.imageView.image = [UIImage imageNamed:@"title"];
                cell.textField.placeholder = L(ADDTITLE);
                cell.textField.text = self.name;
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
                
                cell.marqueeLabel.textColor = DEFAULTBLUE;
                
                if (![self isEmptyString:place])
                {
                    cell.marqueeLabel.text = place;
                }
                else
                {
                    cell.marqueeLabel.text = L(CHOOSELOCATION);
                }
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
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
                keywordscell = cell;
                
                cell.delegate=self;
                cell.tag = indexPath.row;
                
                cell.imageView.image = [UIImage imageNamed:@"tag"];
                cell.textField.placeholder = L(SEPERATEDKEYWORDS);
                cell.textField.text = [[self.keywords valueForKey:@"description"] componentsJoinedByString:@","];
                return cell;
            }
            case 3:
            {
                static NSString *CellIdentifier = @"StringInputCell";
                StringInputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil)
                {
                    //For the default cells
                    cell = [[StringInputTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                descriptioncell = cell;
                
                cell.delegate=self;
                cell.tag = indexPath.row;
                
                cell.imageView.image = [UIImage imageNamed:@"activity"];
                cell.textField.placeholder = L(ADDADESCRIPTION);
                cell.textField.text = self.description;
                return cell;
            }
            case 4:
            {
                NSString *CellIdentifier = @"PublicityPickerCell";
                PublicityCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil)
                {
                    cell = [[PublicityCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                    cell.delegate = self;
                }
                
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
                }
                
                if (poiPublicity.publicity==NO)
                {
                    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"private"]];
                    cell.accessoryView = imageView;
                }
                
                cell.accessoryType = 0;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return cell;
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
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.font = CELLFONTBOLD;
        cell.textLabel.textColor = [UIColor whiteColor];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0)
    {
        switch (indexPath.row)
        {
            case 1:
            {
                PickLocationViewController *controller = [[PickLocationViewController alloc] init];
                controller.location = self.poiLocation;
                controller.showPin = YES;
                controller.delegate = self;
                [self.navigationController pushViewController:controller animated:YES];
                break;
            }
            default:
                break;
        }
    }
    else
    {
        [self deletePOI];
    }
}



#pragma mark - Pick location delegate

- (void)didEndEditingWithCoordinates:(CLLocation *)coordinates {
    [self loadAddressFromCoordinates:coordinates];
    
    self.poiLocation = coordinates;
    NSLog(@"Lat: %f , Lng: %f", coordinates.coordinate.latitude, coordinates.coordinate.longitude);
    
    [self.tableView reloadData];
}



#pragma mark - String input delegate

- (void)tableViewCell:(StringInputTableViewCell *)cell didEndEditingWithString:(NSString *)value {
    
    switch (cell.tag)
    {
        case 0:
        {
            self.name = value;
            NSLog(@"Title: %@", value);
            [self.tableView reloadData];
            break;
        }
        case 2:
        {
            self.keywords = [value componentsSeparatedByString:@","];
            NSLog(@"Keywords: %@", value);
            [self.tableView reloadData];
            break;
        }
        case 3:
        {
            self.description = value;
            NSLog(@"Description: %@", value);
            [self.tableView reloadData];
            break;
        }
        default:
            break;
    }
}


#pragma mark - API to get address from coordinates

- (void)loadAddressFromCoordinates: (CLLocation *)coordinates {
    //Start request for address details
    AddressCoordinates *addresscrd = [[AddressCoordinates alloc] init];
    addresscrd.delegate = self;
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
    
    [namecell.textField resignFirstResponder];
    [keywordscell.textField resignFirstResponder];
    [descriptioncell.textField resignFirstResponder];
    
    //Checking the input data
    if (self.poiLocation.coordinate.latitude == 0 || self.poiLocation.coordinate.longitude == 0)
    {
        [SVProgressHUD showErrorWithStatus:L(NOLOCATIONSELECTED)];
        return;
    }
    
    if ([self isEmptyString:self.title] || [self.title isEqualToString:L(ADDTITLE)])
    {
        [SVProgressHUD showErrorWithStatus:L(EMPTYTITLE)];
        return;
    }
    
    if ([self isEmptyString:self.description] || [self.description isEqualToString:L(ADDADESCRIPTION)])
    {
        [SVProgressHUD showErrorWithStatus:L(EMPTYDESCRIPTION)];
        return;
    }
    
    [self editPOI];
}


#pragma mark - Edit POI call & delegate


-(void)editPOI {
    
    NSLog(@"Saving edited POI..");
    
    POIEngine* poiEngine = [[POIEngine alloc] init];
    poiEngine.delegate = self;
    [poiEngine editPOIWithName:self.name location:self.poiLocation publicity:poiPublicity.publicity keywords:self.keywords andDescription:self.description];
}


-(void) poiEdited {
    
    NSLog(@"POI edited");
    
    if (self.nearMeMap)
    {
        HomeViewController *nearmeMap = [self.navigationController.viewControllers objectAtIndex:0];
        [nearmeMap searchForPOIS];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        //Call the delegate
        if (self.delegate && [self.delegate respondsToSelector:@selector(updatePinWithTag:name:location:descriptiom:publicity:andKeywords:)])
            [self.delegate updatePinWithTag:self.tag name:self.name location:self.poiLocation descriptiom:self.description publicity:poiPublicity.publicity andKeywords:self.keywords];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - Delete POI call & delegate

-(void) deletePOI {
    
    NSLog(@"Deleting POI..");
    
    POIEngine* poiEngine = [[POIEngine alloc] init];
    poiEngine.delegate = self;
    [poiEngine deletePOIWithLocation:self.poiLocation];
}


-(void) poiDeleted {
    
    NSLog(@"POI deleted");
    
    if (self.nearMeMap)
    {
        HomeViewController *nearmeMap = [self.navigationController.viewControllers objectAtIndex:0];
        [nearmeMap searchForPOIS];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        //Call the delegate
        if (self.delegate && [self.delegate respondsToSelector:@selector(removePinWithTag:)])
            [self.delegate removePinWithTag:self.tag];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
