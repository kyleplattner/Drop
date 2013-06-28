//
//  AppDelegate.h
//  Drop
//
//  Created by Kyle Plattner on 4/28/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>
#import <DropboxSDK/DropboxSDK.h>

static NSString * const kParsePostsClassKey = @"Drop";
static NSString * const kParseUserClassKey = @"_User";
static NSString * const kParseUserKey = @"user";
static NSString * const kParseLocationKey = @"location";
static NSString * const kParseFileKey = @"file";
static NSString * const kParseFilenameKey = @"filename";
static NSString * const kParseUsernameKey = @"username";
static NSString * const kParseSharedUserArrayKey = @"users";

static NSString * const kDropboxAppKey = @"yii6grqm3mp900l";
static NSString * const kDropboxAppSecret = @"pntxyr3j0ynf4j0";
static NSString * const kParseAppID = @"6ccB0yMKVEEo8i6kQmlKX6t3ryGX0Grma4VQDpQQ";
static NSString * const kParseClientKey = @"VRl41iG50ow5xDvQ2TtKr09bmA26stvoQpTVPi8m";
static NSString * const kTestFlightKey = @"490688de-870a-47bd-93ae-eab1185b43fa";

@interface AppDelegate : UIResponder <UIApplicationDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, DBRestClientDelegate> {
    DBRestClient *restClient;
}

@property (strong, nonatomic) UIWindow *window;

@end
