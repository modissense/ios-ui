//
//  UtilImage.m
//  SocialSensor_iPhone
//
//  Created by Panagiotis Kokkinakis on 7/26/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "UtilImage.h"
#import "Util.h"

@implementation UtilImage

+(void) loadAsyncImage: (UIImageView *)imageView fromURL:(NSString *)url {
    [self loadAsyncImage:imageView fromURL:url withDefaultImage:@""];
}

+(void) loadAsyncImage: (UIImageView *)imageView fromURL:(NSString *)url withDefaultImage:(NSString *)defaultImage {
    
    //Get hashed representation for image url
    NSString *hashed = [Util MD5Hash:url];
    //Construct image path
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@", NSTemporaryDirectory(), hashed];
    //Checks if image exists
    BOOL imageExists = [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
    
    if (imageExists) {
        NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
        UIImage *image = [UIImage imageWithData:imageData];
        imageView.image = image;
    } else {
        //Load image from url
        /************/
        //Lazy loading images (Asychronous call)
        int width = imageView.bounds.size.width;
        int height = imageView.bounds.size.height;
        
        if (height == 0 && width == 0) {
            width = 40;
            height = 40;
        }
        
        imageView.image = [UIImage imageNamed:defaultImage];
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        spinner.frame = CGRectMake(width / 2 - spinner.frame.size.width / 2,
                                   height / 2 - spinner.frame.size.height / 2,
                                   spinner.frame.size.width, spinner.frame.size.height);
        
        [imageView addSubview:spinner];
        [spinner startAnimating];
        
        NSURL *urlObject = [NSURL URLWithString:url];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:urlObject];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        
        dispatch_async(queue, ^{
            NSURLResponse *response = nil;
            NSError *error = nil;
            
            NSData *receivedData = [NSURLConnection sendSynchronousRequest:urlRequest
                                                         returningResponse:&response
                                                                     error:&error];
            
            UIImage *image = [[UIImage alloc] initWithData:receivedData];
            
            [spinner stopAnimating];
            [spinner removeFromSuperview];
            imageView.image = image;
            
            //Store image to tmp for later use
            [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
            
        });
        /************/
    }
}

@end
