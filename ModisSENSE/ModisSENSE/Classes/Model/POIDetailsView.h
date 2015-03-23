//
//  POIDetails.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 7/7/14.
//  Copyright (c) 2014 ATC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StarRatingView.h"

@interface POIDetailsView : UIView

@property (weak, nonatomic) IBOutlet UILabel *poiNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *generalScore;
@property (weak, nonatomic) IBOutlet StarRatingView *generalScoreStars;
@property (weak, nonatomic) IBOutlet UILabel *numberOfGeneralVisits;
@property (weak, nonatomic) IBOutlet UILabel *poiAddress;

@property (weak, nonatomic) IBOutlet UILabel *userNameComment;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatarComment;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;

@property (weak, nonatomic) IBOutlet UILabel *whatYourFriendsThinkLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendsScore;
@property (weak, nonatomic) IBOutlet StarRatingView *friendsScoreStars;
@property (weak, nonatomic) IBOutlet UIImageView *friend1;
@property (weak, nonatomic) IBOutlet UIImageView *friend2;
@property (weak, nonatomic) IBOutlet UIImageView *friend3;
@property (weak, nonatomic) IBOutlet UILabel *numberOfFriendsVisits;



@end
