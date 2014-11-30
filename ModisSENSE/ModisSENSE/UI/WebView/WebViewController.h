//
//  WebViewController.h
//  ModisSENSE
//
//  Created by Lampros Giampouras on 9/2/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

-(void)loadURL:(NSString*)url;

@end
