//
//  POIDetails.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 7/7/14.
//  Copyright (c) 2014 ATC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface POIDetails : NSObject

@property (assign, nonatomic) int poiID;

//General info
@property (assign, nonatomic) float generalHotness;
@property (assign, nonatomic) float generalInterest;
@property (strong, nonatomic) NSString* poiImageURL;
@property (strong, nonatomic) NSString* poiName;
@property (assign, nonatomic) int numberOfComments;

//Personalized
@property (strong, nonatomic) NSString* userNameComment;
@property (strong, nonatomic) NSString* userImageCommentURL;
@property (strong, nonatomic) NSString* userComment;

@property (assign, nonatomic) float personalizedHotness;
@property (assign, nonatomic) float personalizedInterest;


@end
