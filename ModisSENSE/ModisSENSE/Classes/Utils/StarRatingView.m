//
//  StarRatingView.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 5/20/14.
//  Copyright (c) 2014 ATC. All rights reserved.
//

#import "StarRatingView.h"

@implementation StarRatingView {
    
    UIImageView *ratingImgView;
    UIView* fillColorView;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        ratingImgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        ratingImgView.contentMode=UIViewContentModeScaleToFill;
        ratingImgView.image=[UIImage imageNamed:@"starRatingImg"];
        ratingImgView.clipsToBounds = YES;
        [self addSubview:ratingImgView];
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


- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if(self = [super initWithCoder:aDecoder]) {
        // Initialization code
        
        ratingImgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        ratingImgView.contentMode=UIViewContentModeScaleToFill;
        ratingImgView.image=[UIImage imageNamed:@"starRatingImg"];
        ratingImgView.clipsToBounds = YES;
        [self addSubview:ratingImgView];
    }
    return self;
}



-(void)setRating:(float)rating withColor:(UIColor*)color {
    
    if (fillColorView)
        [fillColorView removeFromSuperview];
    
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         fillColorView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, rating*self.frame.size.width, self.frame.size.height)];
                         fillColorView.backgroundColor = color;
                         [self addSubview:fillColorView];
                         [self sendSubviewToBack:fillColorView];
                     }
                     completion:^(BOOL finished){
                         // NSLog(@"Done!");
                         
                     }];
}

@end
