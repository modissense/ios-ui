//
//  Util.h
//  SocialSensor_iPhone
//
//  Created by Panagiotis Kokkinakis on 7/26/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

+ (BOOL) isNull:(id)obj;
+ (BOOL) isEmptyString:(id)obj;
+ (NSString*) nonNullString:(id)obj;
+ (NSString *)MD5Hash: (NSString *)input;
+ (NSString *)urlEncode:(NSString *) unencodedurl;
+ (NSString *)fixVideoUrl:(NSString *)url;

@end
