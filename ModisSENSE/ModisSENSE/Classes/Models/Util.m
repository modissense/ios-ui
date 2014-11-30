//
//  Util.m
//  SocialSensor_iPhone
//
//  Created by Panagiotis Kokkinakis on 7/26/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "Util.h"
#import "CommonCrypto/CommonDigest.h"

@implementation Util

/*******************************/
/* Methods for emptiness check */
/*******************************/
+ (BOOL) isNull:(id)obj {
    return obj == nil || [obj isKindOfClass:[NSNull class]];
}

+ (BOOL) isEmptyString:(id)obj {
    return obj == nil || ![obj isKindOfClass:[NSString class]] || ![obj length];
}

+ (NSString*) nonNullString:(id)obj {
    return ![self isEmptyString:obj] ? obj : @"";
}

+ (NSString *)MD5Hash: (NSString *)input {
    const char *cStr = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    if (cStr == nil)
        return @"";
    
    CC_MD5( cStr, strlen(cStr), result );
    
    return [NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15] ];
}

+ (NSString *)urlEncode:(NSString *) unencodedurl {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)unencodedurl,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(kCFStringEncodingUTF8)));
}

+ (NSString *)fixVideoUrl:(NSString *)url {
    //Fix youtube video link
    url = [url stringByReplacingOccurrencesOfString:@"http://www.youtube.com/v/" withString:@""];
    NSArray *parts = [url componentsSeparatedByString:@"?"];
    url = [NSString stringWithFormat:@"http://m.youtube.com/watch?v=%@", [parts objectAtIndex:0]];
    
    NSLog(@"Video URL: %@", url);
    
    return url;
}

@end
