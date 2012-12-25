//
//  AppDelegate.m
//  SensorApp
//
//  Created by Scott Gruby on 12/12/12.
//  Copyright (c) 2012 Scott Gruby. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()
@property (nonatomic, strong) ViewController *mainViewController;
@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.mainViewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];
	self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[self.mainViewController applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	[self.mainViewController applicationWillEnterForeground:application];
}

@end
