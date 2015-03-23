//
//  ImageZoom.h
//  SocialSensor_iPhone
//
//  Created by Lampros Giampouras on 9/2/14.
//  Copyright (c) 2014 ATC. All rights reserved.
//

#import "ImageZoom.h"

static CGRect oldframe;
static UIView *backgroundView;;

@implementation ImageZoom

+(void)showImage:(UIImageView *)avatarImageView {
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds]; // portrait bounds
    
    if ([[[UIDevice currentDevice] systemVersion] intValue] < 8)    //If iOS<8 bounds always gives you the portrait width/height and we have to convert them
    {
        if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
            screenBounds = CGRectMake(0, 0, screenBounds.size.height, screenBounds.size.width);
    }
    
    UIImage *image=avatarImageView.image;
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    
    if (!window)
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    
    backgroundView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height)];
    
    oldframe=[avatarImageView convertRect:avatarImageView.bounds toView:window];
    
    backgroundView.backgroundColor=[UIColor blackColor];
    backgroundView.alpha=0;
    
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:oldframe];
    imageView.image=image;
    imageView.tag=1;
    
    [backgroundView addSubview:imageView];
    
    [[[window subviews] objectAtIndex:0] addSubview:backgroundView];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer:tap];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=CGRectMake(0,(screenBounds.size.height-image.size.height*screenBounds.size.width/image.size.width)/2, screenBounds.size.width, image.size.height*screenBounds.size.width/image.size.width);
        backgroundView.alpha=1;
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }];
}

+(void)hideImage:(UITapGestureRecognizer*)tap {
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    UIView *backgroundView=tap.view;
    UIImageView *imageView=(UIImageView*)[tap.view viewWithTag:1];
    
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=oldframe;
        backgroundView.alpha=0;
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
    }];
}


+(void)close {
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    if (backgroundView)
    {
        [UIView animateWithDuration:0.3 animations:^{
            backgroundView.alpha=0;
        } completion:^(BOOL finished) {
            [backgroundView removeFromSuperview];
        }];
    }
}
@end
