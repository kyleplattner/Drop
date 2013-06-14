//
//  AppDelegate.m
//  Drop
//
//  Created by Kyle Plattner on 4/28/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import "AppDelegate.h"
#import <DropboxSDK/DropboxSDK.h>
#import "TestFlight.h"
#import <Parse/Parse.h>
#import "FTASync.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DBSession* dbSession = [[DBSession alloc] initWithAppKey:@"tta35f8sfuibet8" appSecret:@"rix005m7es4hrs8" root:kDBRootDropbox];
    [DBSession setSharedSession:dbSession];
    [Parse setApplicationId:@"6ccB0yMKVEEo8i6kQmlKX6t3ryGX0Grma4VQDpQQ" clientKey:@"VRl41iG50ow5xDvQ2TtKr09bmA26stvoQpTVPi8m"];
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    [TestFlight takeOff:@"490688de-870a-47bd-93ae-eab1185b43fa"];
    
    [MagicalRecord setupAutoMigratingCoreDataStack];
    [FTASyncHandler sharedInstance];
    
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    return YES;
}

- (void)setCurrentLocation:(CLLocation *)currentLocation
{
	_currentLocation = currentLocation;
    
	// Notify the app of the location change:
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:currentLocation forKey:kParseLocationKey];
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"LocationNotification" object:nil userInfo:userInfo];
	});
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DropboxNotification" object:nil];
        }
        return YES;
    }
    // Add whatever other url handling code your app requires here
    return NO;
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
