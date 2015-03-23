//
//  StarRatingView.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 5/20/14.
//  Copyright (c) 2014 ATC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StarRatingView : UIView

//Set rating from 0 to 1
-(void)setRating:(float)rating withColor:(UIColor*)color;

@end
