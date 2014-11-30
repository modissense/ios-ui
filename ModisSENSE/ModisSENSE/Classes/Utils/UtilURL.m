//
//  UtilURL.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 8/29/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "UtilURL.h"

@implementation UtilURL

+(NSMutableDictionary*) parseURL:(NSURL*)url
{
    NSString *query = [url query]; // query string from the callback URL
    NSArray *components = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];

    for (NSString *component in components) {
        NSArray *subcomponents = [component componentsSeparatedByString:@"="];
        [parameters setObject:[[subcomponents objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                       forKey:[[subcomponents objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }

    NSLog(@"Scheme: %@", [url scheme]);
    NSLog(@"Host: %@", [url host]);
    NSLog(@"Port: %@", [url port]);
    NSLog(@"Path: %@", [url path]);
    NSLog(@"Relative path: %@", [url relativePath]);
    NSLog(@"Path components as array: %@", [url pathComponents]);
    NSLog(@"Parameter string: %@", [url parameterString]);
    NSLog(@"Query: %@", [url query]);
    NSLog(@"Fragment: %@", [url fragment]);
    
    return parameters;
}


+(void)internetConnectionOnSuccess:(Clean)successBlock {
    
    NSURL *URL = [NSURL URLWithString:@"www.google.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    //Open different thread to check for internet connection so the UI won't break
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    
    dispatch_async(queue, ^{
        NSURLResponse *response = nil;
        NSError *error = nil;
        
        NSData *receivedData = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&response
                                                                 error:&error];
        if (receivedData)
        {
            successBlock();
        }
    });
}

@end
