//
//  DropboxBrowserViewController.h
//  Drop
//
//  Created by Kyle Plattner on 6/28/13.
//  Copyright (c) 2013 Precision Planting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropboxRootViewController.h"
#import "DropboxDataController.h"

@protocol DropboxBrowserViewControllerUIDelegate;
@class DropboxRootViewController;
@class DropboxDataController;

@interface DropboxBrowserViewController : UINavigationController {}
@property (nonatomic, strong) DropboxRootViewController *rootViewController;
@property (nonatomic, strong) DropboxDataController *dataController;
@property (nonatomic) id <DropboxBrowserViewControllerUIDelegate> uiDelegate;
- (void)listDropboxDirectory;
+ (void)displayDropboxBrowserInPadStoryboard:(UIStoryboard *)iPadStoryboard onView:(UIViewController *)viewController withPresentationStyle:(UIModalPresentationStyle)presentationStyle withTransitionStyle:(UIModalTransitionStyle)transitionStyle withDelegate:(id<DropboxBrowserViewControllerUIDelegate>)delegate;
@end
@protocol DropboxBrowserViewControllerUIDelegate <NSObject>
@required - (void) removeDropboxBrowser;
 - (void)refreshLibrarySection;
@end

