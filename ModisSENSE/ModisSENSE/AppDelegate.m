//
//  AppDelegate.m
//  ModisSENSE
//
//  Created by Lampros Giampouras on 4/10/13.
//  Copyright (c) 2013 ATC. All rights reserved.
//

#import "AppDelegate.h"
#import "Util.h"
#import "UtilURL.h"
#import "Engine.h"
#import "Config.h"
#import "SignInViewController.h"
#import "SettingsViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /*******/
    //Fabric Crashlytics, don't touch
    [Fabric with:@[CrashlyticsKit]];
    /*******/
    
    //Here you should get user's preferences
    Eng.preferences.trackUserPosition = YES;
    
    Eng.user.isInBackground = NO;
    
    if (Eng.preferences.trackUserPosition)
    {
        [Eng.locationTracker startLocationTracker:TRACINGBLOG];
        NSLog(@"ModisSENSE location tracker launched !\n\n");
    }
    
    return YES;
}


//Handle callback with URL scheme
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (!url)
        return NO;
    
    //If the user is not connected get his userid and open main application (Tab bar)
    if (!Eng.user.connected)
    {
        //Get the Sign In view controller
        UINavigationController* navController = (UINavigationController*) self.window.rootViewController;
        SignInViewController* signInController = [[navController viewControllers] objectAtIndex:0];

        //Parse URL to get user id
        NSMutableDictionary* parameters = [UtilURL parseURL:url];

        //Get user id
        Eng.user.userId = [parameters objectForKey:@"uid"];
        MyLog(@"Got user id (token): %@",Eng.user.userId);

        if (Eng.user.userId && ![Util isEmptyString:Eng.user.userId] && ![Eng.user.userId isEqualToString:@"null"])
            [signInController openModissense];
        else
        {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"ModisSENSE"
                                                                message:L(AUTHFAILED)
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            
            [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
        }
    }
    else
    {
        //Parse URL to get user id
        NSMutableDictionary* parameters = [UtilURL parseURL:url];
        
        //Get user id
        Eng.user.userId = [parameters objectForKey:@"uid"];
        MyLog(@"Got user id (token): %@",Eng.user.userId);
        
        //Refresh connected accounts
        //Find the Settings view controller and refresh the Eng.user.socialAccounts array
        UINavigationController *navController = (UINavigationController *)[[self.modissenseTabController viewControllers] objectAtIndex:3];
        SettingsViewController* settingsController = [[navController viewControllers] objectAtIndex:0];
        [settingsController getFriends];
        settingsController.newSocialMediaLoaded = YES;
    }
    
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    Eng.user.isInBackground = YES;
    NSLog(@"ModisSENSE entered background mode");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    Eng.user.isInBackground = NO;
    NSLog(@"ModisSENSE entered foreground mode");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    //Save location data
    NSLog(@"ModisSENSE will terminate, saving location data");
    [Eng.locationTracker stop];
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    
    //Memory is full save location data
    NSLog(@"Memory warning! Saving location data");
    [Eng.locationTracker stop];
}

@end
