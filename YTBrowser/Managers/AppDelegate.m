//
//  AppDelegate.m
//  YTBrowser
//
//  Created by Marin Todorov on 03/01/2013.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "LibraryViewController.h"
#import "RESideMenu.h"
#import "LeftMenuViewController.h"
#import "AppConstant.h"
#import "JukeboxListViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "LoginViewController.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [Parse setApplicationId:@"1FhBCD3ASayJxj5YL9xkIBJPFm6WXIPcFtmh77ab"
                  clientKey:@"nbeYYYVWWCKjpvZKZbIunQpF606bllZWahJTY5UX"];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [PFFacebookUtils initializeFacebook];

    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[JukeboxListViewController alloc] init]];
    self.leftMenuViewController = [[LeftMenuViewController alloc] init];
    
    
    self.sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:navigationController
                                                                    leftMenuViewController:self.leftMenuViewController
                                                                   rightMenuViewController:nil];
    self.sideMenuViewController.backgroundImage = [UIImage imageNamed:@"background_blue"];
    self.sideMenuViewController.menuPreferredStatusBarStyle = 1; // UIStatusBarStyleLightContent
    self.sideMenuViewController.delegate = self;
    self.sideMenuViewController.contentViewShadowColor = [UIColor blackColor];
    self.sideMenuViewController.contentViewShadowOffset = CGSizeMake(0, 0);
    self.sideMenuViewController.contentViewShadowOpacity = 0.6;
    self.sideMenuViewController.contentViewShadowRadius = 12;
    self.sideMenuViewController.contentViewShadowEnabled = YES;
    self.window.rootViewController =  self.sideMenuViewController;
    
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    CGFloat barHeight = 45.0f;
    CGFloat barWidth = self.window.frame.size.width;
    self.playerBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.window.frame.size.height-barHeight, self.window.frame.size.width, barHeight)];
    [[MediaManager sharedInstance] initializeVideoPlayer:self.playerBar];
    
    [self.window makeKeyAndVisible];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        
        // Load resources for iOS 6.1 or earlier
        [[UINavigationBar appearance]setTintColor:[UIColor whiteColor]];
    } else {
        [[UINavigationBar appearance]setTintColor:RGB(19, 143, 213)]; // it set color of bar button item text
        [[UINavigationBar appearance]setTitleTextAttributes:@{UITextAttributeTextColor : [UIColor whiteColor]}]; //It set title color of Navigation Bar
        // Load resources for iOS 7 or later
        
    }
    
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
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

// ****************************************************************************
// App switching methods to support Facebook Single Sign-On.
// ****************************************************************************
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [[PFFacebookUtils session] close];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

-(void)remoteControlReceivedWithEvent:(UIEvent *)event{
    if (event.type == UIEventTypeRemoteControl){
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                // Toggle play pause
                break;
            default:
                break;
        }
    }
}


@end
