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
- (void)populateTable;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DBSession* dbSession = [[DBSession alloc] initWithAppKey:@"yii6grqm3mp900l" appSecret:@"pntxyr3j0ynf4j0" root:kDBRootDropbox];
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
    if (![PFUser currentUser]) {
        PFUser *user = [[PFUser alloc] init];
        [user setUsername:[info displayName]];
        [user setPassword:[info userId]];
        BOOL success = [user signUp];
        if (!success) {
            [PFUser logInWithUsername:[info displayName] password:[info userId]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"QueryForAllPosts" object:nil];
            [self performSelector:@selector(populateTable) withObject:nil afterDelay:2];
        }
    }
}

- (void)populateTable {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadAnnoationsNotification" object:nil];
}

@end
