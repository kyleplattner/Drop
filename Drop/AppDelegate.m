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

@interface AppDelegate ()
- (void)sendLoginNotification;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DBSession* dbSession = [[DBSession alloc] initWithAppKey:@"tta35f8sfuibet8" appSecret:@"rix005m7es4hrs8" root:kDBRootDropbox];
    [DBSession setSharedSession:dbSession];
    [Parse setApplicationId:@"6ccB0yMKVEEo8i6kQmlKX6t3ryGX0Grma4VQDpQQ" clientKey:@"VRl41iG50ow5xDvQ2TtKr09bmA26stvoQpTVPi8m"];
    [TestFlight takeOff:@"490688de-870a-47bd-93ae-eab1185b43fa"];
    
//    [MagicalRecord setupAutoMigratingCoreDataStack];
//    [FTASyncHandler sharedInstance];
    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
            [[self restClient] loadAccountInfo];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DropboxNotification" object:nil];
        } else {
            [self performSelector:@selector(sendLoginNotification) withObject:nil afterDelay:1];
        }
        return YES;
    }
    return NO;
}

- (void)sendLoginNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TryLoginNotification" object:nil];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please Login" message:@"Drop requires a linked Dropbox account in order to function." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alertView show];
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

#pragma Old Sign Up Code

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    if (username && password && username.length && password.length) {
        return YES;
    }
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Error Registering User. Contact Kyle Plattner.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    return NO;
}

- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) {
            informationComplete = NO;
            break;
        }
    }
    
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the fields", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QueryForAllPosts" object:nil];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)restClient:(DBRestClient*)client loadedAccountInfo:(DBAccountInfo*)info {
    NSLog(@"UserID: %@ %@", [info displayName], [info userId]);
    if (![PFUser currentUser]) {
        PFUser *user = [[PFUser alloc] init];
        [user setUsername:[info displayName]];
        [user setPassword:[info userId]];
        BOOL success = [user signUp];
        if (!success) {
            [PFUser logInWithUsername:[info displayName] password:[info userId]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"QueryForAllPosts" object:nil];
        }
    }
}

@end
