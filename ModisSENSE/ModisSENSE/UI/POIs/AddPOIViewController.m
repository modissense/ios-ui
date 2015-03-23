//
//  AddBlogRecordViewController.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 6/17/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "AddPOIViewController.h"
#import "HomeViewController.h"
#import "Engine.h"
#import "Util.h"

@interface AddPOIViewController (){
    NSDateFormatter *dateFormatter;
    UIDatePicker* datepicker;
    NSMutableString* place;
    NSArray* duplicatePOIS;
    
    //Remember cell for resigning firstresponder afterwards
    StringInputTableViewCell *namecell;
    StringInputTableViewCell *descriptioncell;
    StringInputTableViewCell *keywordscell;
    
    //POI data
    NSString* title;
    CLLocation *poiLocation;
    NSArray* keywords;
    NSString* description;
    Publicity* poiPublicity;
}

@end



@implementation AddPOIViewController

@synthesize poiLocation;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //For ios7
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
        ADJUST_IOS7_LAYOUT

    UIImageView* bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mapblur"]];
    self.tableView.backgroundView = bgView;
        
    self.title = L(ADD_RECORD);
    
    self.tellUsAboutIt.text = L(TELLUSABOUTIT);
    
    if (self.poiLocation)
        [self loadAddressFromCoordinates:self.poiLocation];
    
//    dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]]; 
//    [dateFormatter setDateFormat:@"yyy-MM-dd HH:mm:ss"];
    
    place = (NSMutableString*) @"";
    
    //Start with public new POI
    poiPublicity = [[Publicity alloc] initWithPublicity:YES];
    
    if (self.isModal)
    {
        UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:L(CANCEL) style:UIBarButtonItemStylePlain target:self action:@selector(closeModal)];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:L(ADD) style:UIBarButtonItemStylePlain target:self action:@selector(beginAddingProcess)];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return L(LOCATIONDETAILS);
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
            }
            
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transpbg"]];
            cell.backgroundView.alpha = CELLALPHA;
            
            namecell = cell;
            
            cell.delegate=self;
            cell.tag = indexPath.row;
            
            cell.imageView.image = [UIImage imageNamed:@"title"];
            cell.textField.placeholder = L(ADDTITLE);
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
            
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transpbg"]];
            cell.backgroundView.alpha = CELLALPHA;
            
            if (![self isEmptyString:place])
            {
                cell.marqueeLabel.textColor = DEFAULTBLUE;
                cell.marqueeLabel.text = place;
            }
            else
            {
                cell.marqueeLabel.textColor = [UIColor redColor];
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
            
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transpbg"]];
            cell.backgroundView.alpha = CELLALPHA;
            
            keywordscell = cell;
            
            cell.delegate=self;
            cell.tag = indexPath.row;
            
            cell.imageView.image = [UIImage imageNamed:@"tag"];
            cell.textField.placeholder = L(SEPERATEDKEYWORDS);
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
            
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transpbg"]];
            cell.backgroundView.alpha = CELLALPHA;
            
            descriptioncell = cell;
            
            cell.delegate=self;
            cell.tag = indexPath.row;
            
            cell.imageView.image = [UIImage imageNamed:@"activity"];
            cell.textField.placeholder = L(ADDADESCRIPTION);
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 1:
        {
            PickLocationViewController *controller = [[PickLocationViewController alloc] init];
            
            controller.location = self.poiLocation ? self.poiLocation : Eng.locationTracker.currentlocation;
                        
            controller.showPin = YES;
            controller.delegate = self;
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        default:
            break;
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

- (void)tableViewCell:(StringInputTableViewCell *)cell didEndEditingWithString:(NSString *)value {
    
    switch (cell.tag)
    {
        case 0:
        {
            title = value;
            NSLog(@"Title: %@", value);
            [self.tableView reloadData];
            break;
        }
        case 2:
        {
            keywords = [value componentsSeparatedByString:@","];
            NSLog(@"Keywords: %@", value);
            [self.tableView reloadData];
            break;
        }
        case 3:
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
    
    if ([Util isEmptyString:place] || place==nil )
        place = [NSMutableString stringWithFormat:@"%@", L(NOADDRESSAVAILABLE)];
    
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


#pragma mark - Adding Process


-(void) beginAddingProcess
{
    [namecell.textField resignFirstResponder];
    [keywordscell.textField resignFirstResponder];
    [descriptioncell.textField resignFirstResponder];
    
    //Checking the input data
    if (poiLocation.coordinate.latitude == 0 || poiLocation.coordinate.longitude == 0)
    {
        [SVProgressHUD showErrorWithStatus:L(NOLOCATIONSELECTED)];
        return;
    }
    
    if ([self isEmptyString:title] || [title isEqualToString:L(ADDTITLE)])
    {
        [SVProgressHUD showErrorWithStatus:L(EMPTYTITLE)];
        return;
    }
    
    if ([self isEmptyString:description] || [description isEqualToString:L(ADDADESCRIPTION)])
    {
        [SVProgressHUD showErrorWithStatus:L(EMPTYDESCRIPTION)];
        return;
    }
    
    if (self.dontSearchForDuplicates)
    {
        [self addPOI];
    }
    else
    {
        NSLog(@"Finding duplicates");
        
        POIEngine* poiEngine = [[POIEngine alloc] init];
        poiEngine.delegate = self;
        [poiEngine findDuplicatesInLocation:poiLocation];
    }
}


#pragma mark - Duplicates delegate

-(void) gotDuplicates:(NSArray*)poiList {
    
    duplicatePOIS = poiList;
    
    if (poiList.count>0)                //Duplicates found
    {
        NSLog(@"Duplicates found!");
        
        DuplicatesViewController *duplicatesVC =[self.storyboard instantiateViewControllerWithIdentifier:@"DuplicatesViewID"];
        duplicatesVC.delegate = self;
        duplicatesVC.duplicatesList = poiList;
        [self.navigationController pushViewController:duplicatesVC animated:YES];
    }
    else                                //No duplicates found
    {
        [self addPOI];
    }
}

#pragma mark - Add POI call & delegate

-(void) addPOI {
    
    NSLog(@"Adding POI..");
    
    POIEngine* poiEngine = [[POIEngine alloc] init];
    poiEngine.delegate = self;
    [poiEngine addNewPOIWithName:title location:poiLocation publicity:poiPublicity.publicity keywords:keywords andDescription:description];
}

-(void) poiAdded:(POI*)poi {
    
    NSLog(@"POI added!");
    
    if (self.isModal)
    {
        [self dismissViewControllerAnimated:YES completion:
         ^{if (self.delegate && [self.delegate respondsToSelector:@selector(newPOIAdded:)]) {
            [self.delegate newPOIAdded:poi];
        }}];
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    
        if (self.delegate && [self.delegate respondsToSelector:@selector(newPOIAdded:)]) {
            [self.delegate newPOIAdded:poi];
        }
    }
}


#pragma mark - Close Modal

-(void)closeModal {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
