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

@interface AppDelegate : UIResponder <UIApplicationDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, DBRestClientDelegate> {
    DBRestClient *restClient;
}

@property (strong, nonatomic) UIWindow *window;

@end
