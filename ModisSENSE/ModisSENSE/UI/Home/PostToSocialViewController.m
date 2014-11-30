//
//  PostToSocialViewController.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/12/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "PostToSocialViewController.h"
#import "Engine.h"

@interface PostToSocialViewController ()

@end

@implementation PostToSocialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIBarButtonItem* postButton = [[UIBarButtonItem alloc] initWithTitle:L(POST) style:UIBarButtonItemStylePlain target:self action:@selector(postToSocial)];
    self.navigationItem.rightBarButtonItem = postButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) postToSocial
{
    //Post text to social media
}

@end
