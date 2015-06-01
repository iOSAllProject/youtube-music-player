//
//  AppDelegate.m
//  YTBrowser
//
//  Created by Marin Todorov on 03/01/2013.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "SearchViewController.h"
#import "RESideMenu.h"
#import "DEMOLeftMenuViewController.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{


    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[SearchViewController alloc] init]];
    DEMOLeftMenuViewController *leftMenuViewController = [[DEMOLeftMenuViewController alloc] init];

    
    RESideMenu *sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:navigationController
                                                                    leftMenuViewController:leftMenuViewController
                                                                   rightMenuViewController:nil];
    sideMenuViewController.backgroundImage = [UIImage imageNamed:@"sky"];
    sideMenuViewController.menuPreferredStatusBarStyle = 1; // UIStatusBarStyleLightContent
    sideMenuViewController.delegate = self;
    sideMenuViewController.contentViewShadowColor = [UIColor blackColor];
    sideMenuViewController.contentViewShadowOffset = CGSizeMake(0, 0);
    sideMenuViewController.contentViewShadowOpacity = 0.6;
    sideMenuViewController.contentViewShadowRadius = 12;
    sideMenuViewController.contentViewShadowEnabled = YES;
    self.window.rootViewController = sideMenuViewController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    CGFloat barHeight = 40.0f;
    CGFloat barWidth = self.window.frame.size.width;
    self.playerBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.window.frame.size.height-barHeight, self.window.frame.size.width, barHeight)];
    self.playerBar.backgroundColor =  [UIColor blackColor];
    [[MediaManager sharedInstance] initializeVideoPlayer:self.playerBar];
    
    /*
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    SearchViewController *home = [[SearchViewController alloc] init];
    UINavigationController *navController=[[UINavigationController alloc]initWithRootViewController:home];
    [self.window setRootViewController:navController];*/
    [self.window makeKeyAndVisible];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        
        // Load resources for iOS 6.1 or earlier
        [[UINavigationBar appearance]setTintColor:[UIColor clearColor]];
    } else {
        [[UINavigationBar appearance]setTintColor:[UIColor blackColor]]; // it set color of bar button item text
        [[UINavigationBar appearance]setBarTintColor:[UIColor whiteColor]]; // it set color of navigation
        [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault]; // it set Style of UINavigationBar
        [[UINavigationBar appearance]setTitleTextAttributes:@{UITextAttributeTextColor : [UIColor whiteColor]}]; //It set title color of Navigation Bar
        // Load resources for iOS 7 or later
        
    }
    
 //   [[UINavigationBar appearance] setBarTintColor:[UIColor clearColor]];
  //  self.window.tintColor = [UIColor redColor];
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
