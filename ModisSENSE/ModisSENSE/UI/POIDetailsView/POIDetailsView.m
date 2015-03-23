//
//  POIDetails.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 7/7/14.
//  Copyright (c) 2014 ATC. All rights reserved.
//

#import "POIDetailsView.h"
#import "UIConstants.h"
#import "Engine.h"
#import "UtilImage.h"

@implementation POIDetailsView {
    NSMutableString* place;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/




-(void)clearAllPOIDetails {
    
    self.poiNameLabel.text = L(WAIT);
    self.generalScore.text = @"0.0";
    [self.generalScoreStars setRating:0 withColor:DEFAULTBLUE];
    self.numberOfGeneralVisits.text = @"";
    self.poiAddress.text = @"";
    self.numberOfComments.text = @"";
    self.poiImage.image = [UIImage imageNamed:@"modissense.png"];
    
    self.userNameComment.text = @"";
    self.userAvatarComment.image = [UIImage imageNamed:@"large-blank-person"];
    [self.commentTextView setText:@""];
    
    self.whatYourFriendsThinkLabel.text = L(WHATYOURFRIENDSTHINK);
    
    self.friendsScore.text = @"0.0";
    [self.friendsScoreStars setRating:0 withColor:DEFAULTBLUE];
    self.numberOfFriendsVisits.text = @"";
}


//Set poi details
-(void)setPOIDetails:(POIDetails*)poiDetails withLocation:(CLLocation*)location {
    
    /********/
    //First check for possible negative numbers
    if (poiDetails.generalInterest<0)
        poiDetails.generalInterest=0;
    
    if (poiDetails.generalHotness<0)
        poiDetails.generalHotness=0;
    
    if (poiDetails.personalizedInterest<0)
        poiDetails.personalizedInterest=0;
    
    if (poiDetails.personalizedHotness<0)
        poiDetails.personalizedHotness=0;
    /********/
    
    /********/
    //Get address based on location
    self.poiAddress.text = L(GETTINGADDRESS);
    [self loadAddressFromCoordinates:location];
    /********/
    
    NSString* name = poiDetails.poiName;
    if (name==nil || [name isKindOfClass:[NSNull class]] || [name isEqualToString:@"null"] || name.length==0)
        name = L(NONAME);
    
    self.poiNameLabel.text = name;
    
    self.generalScore.text = [NSString stringWithFormat:@"%.1f",poiDetails.generalInterest*5];
    
    //Set general interest
    [self.generalScoreStars setRating:poiDetails.generalInterest withColor:DEFAULTBLUE];
    
    NSString* generalVisitorsString = [NSString stringWithFormat:@"%.0f",poiDetails.generalHotness];
    generalVisitorsString = [generalVisitorsString stringByAppendingString:@" "];
    
    if (poiDetails.generalHotness==1)
        generalVisitorsString = [generalVisitorsString stringByAppendingString:L(VISITOR)];
    else
        generalVisitorsString = [generalVisitorsString stringByAppendingString:L(VISITORS)];
    
    self.numberOfGeneralVisits.text = generalVisitorsString;
    
    NSString* numberOfCommentsString = [NSString stringWithFormat:@"%d",poiDetails.numberOfComments];
    numberOfCommentsString = [numberOfCommentsString stringByAppendingString:@" "];
    
    if (poiDetails.numberOfComments==1)
        numberOfCommentsString = [numberOfCommentsString stringByAppendingString:L(COMMENT)];
    else
        numberOfCommentsString = [numberOfCommentsString stringByAppendingString:L(COMMENTS)];
    
    self.numberOfComments.text = numberOfCommentsString;
    
    /****************/
    //POI Image
    [UtilImage loadAsyncImage:self.poiImage fromURL:poiDetails.poiImageURL];
    /****************/
    
    self.userNameComment.text = poiDetails.userNameComment;
    
    /****************/
    //User avatar image (the one with the comment)
    [UtilImage loadAsyncImage:self.userAvatarComment fromURL:poiDetails.userImageCommentURL];
    /****************/
    
    [self.commentTextView setText:poiDetails.userComment];
    
    self.whatYourFriendsThinkLabel.text = L(WHATYOURFRIENDSTHINK);
    
    self.friendsScore.text = [NSString stringWithFormat:@"%.1f",poiDetails.personalizedInterest*5];
    
    //Set personalized interest
    [self.friendsScoreStars setRating:poiDetails.personalizedInterest withColor:DEFAULTBLUE];
    
    NSString* friendlyVisitsString = [NSString stringWithFormat:@"%.0f",poiDetails.personalizedHotness];
    friendlyVisitsString = [friendlyVisitsString stringByAppendingString:@" "];
    
    if (poiDetails.personalizedHotness==1)
        friendlyVisitsString = [friendlyVisitsString stringByAppendingString:L(VISIT)];
    else
        friendlyVisitsString = [friendlyVisitsString stringByAppendingString:L(VISITS)];
    
    self.numberOfFriendsVisits.text = friendlyVisitsString;
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
        self.poiAddress.text = L(NOADDRESSAVAILABLE);
    else
        self.poiAddress.text = place;
}

#pragma mark - Methods for emptiness check

- (BOOL) isNull:(id)obj {
    return obj == nil || [obj isKindOfClass:[NSNull class]];
}
- (BOOL) isEmptyString:(id)obj {
    return obj == nil || ![obj isKindOfClass:[NSString class]] || ![obj length];
}

@end
