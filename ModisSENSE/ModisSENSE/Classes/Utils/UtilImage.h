//
//  UtilImage.h
//  SocialSensor_iPhone
//
//  Created by Panagiotis Kokkinakis on 7/26/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UtilImage : NSObject

+(void) getImageDimensionsFromURL:(NSString*)url;
+(void) loadAsyncImage: (UIImageView *)imageView fromURL:(NSString *)url withDefaultImage:(NSString *)defaultImage;
+(void) loadAsyncImage: (UIImageView *)imageView fromURL:(NSString *)url;

@end
