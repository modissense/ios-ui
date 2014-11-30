//
//  WebViewController.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 9/2/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController () {
    NSString* urlString;
}

@end



@implementation WebViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSURL *nsurl=[NSURL URLWithString:urlString];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    
    self.webView.delegate=self;
    [self.webView loadRequest:nsrequest];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)loadURL:(NSString*)url {
    urlString=url;
}


-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    
//    if ( inType == UIWebViewNavigationTypeLinkClicked )
//        [self.webView loadRequest:inRequest];
    
    return YES;
}

@end