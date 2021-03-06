//
//  AboutViewController.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 9/2/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "AboutViewController.h"
#import "Engine.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}


-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}


-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = L(ABOUT);
    
    //For ios7
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7)
        ADJUST_IOS7_LAYOUT
    
    self.aboutLabel.text = L(ABOUTMODISSENSE);
    
    self.aboutTextView.text = L(ABOUTTEXT);
    
    self.aboutTextView.textAlignment = NSTextAlignmentJustified;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
