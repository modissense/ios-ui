//
//  UtilURL.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 8/29/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UtilURL : NSObject

//Will parse the query of the url.

/**************************************************************************************
* Example:
*
* www.something.com?id=5&value=10
*
* Parse URL to get id
* NSMutableDictionary* parameters = [UtilURL parseURL:url];
*
* NSString* id = [parameters objectForKey:@"id"];            //Get id (which is 5)
* NSString* value = [parameters objectForKey:@"value"];      //Get value (which is 10)
*************************************************************************************/
+(NSMutableDictionary*) parseURL:(NSURL*)url;

+(void)internetConnectionOnSuccess:(Clean)successBlock;


@end
