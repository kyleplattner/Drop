//
//  AppDelegate.h
//  Drop
//
//  Created by Kyle Plattner on 4/28/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

static NSString * const kParsePostsClassKey = @"Drop";
static NSString * const kParseUserKey = @"user";
static NSString * const kParseUsernameKey = @"username";
static NSString * const kParseLocationKey = @"location";
static NSString * const kParseFileKey = @"file";

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) CLLocation *currentLocation;

@end
