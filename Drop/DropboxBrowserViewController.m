//
//  DropboxBrowserViewController.m
//  Drop
//
//  Created by Kyle Plattner on 6/28/13.
//  Copyright (c) 2013 Precision Planting. All rights reserved.
//

#import "DropboxBrowserViewController.h"

@interface DropboxBrowserViewController () <DropboxRootViewControllerDelegate>

@end


@interface DropboxBrowserViewController (navigationcontrollermanagement)
- (void)removeDropboxBrowser;
@end

@implementation DropboxBrowserViewController (navigationcontrollermanagement)
- (void)removeDropboxBrowser {
    if ([[self uiDelegate] respondsToSelector:@selector(removeDropboxBrowser)])
        [[self uiDelegate] removeDropboxBrowser];
}
@end



@implementation DropboxBrowserViewController

#pragma mark - public functions
- (void) listDropboxDirectory {
    if (![self.dataController isDropboxLinked]) {
        [self removeDropboxBrowser];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Drop is not linked to your Dropbox account." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TryLoginNotification" object:nil];
    }
    else {
        [self.rootViewController listHomeDirectory];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    DropboxRootViewController *tController = (DropboxRootViewController *)[[self viewControllers]objectAtIndex:0];
    self.rootViewController = tController;
    self.rootViewController.rootViewDelegate = self;
    DropboxDataController *controller = [[DropboxDataController alloc] init];
    self.dataController = controller;
    self.rootViewController.dataController = self.dataController;
    self.dataController.dataDelegate = self.rootViewController;
}

+ (void)displayDropboxBrowserInPadStoryboard:(UIStoryboard *)iPadStoryboard onView:(UIViewController *)viewController withPresentationStyle:(UIModalPresentationStyle)presentationStyle withTransitionStyle:(UIModalTransitionStyle)transitionStyle withDelegate:(id<DropboxBrowserViewControllerUIDelegate>)delegate {
            DropboxBrowserViewController *targetController = [iPadStoryboard instantiateViewControllerWithIdentifier:@"DropboxBrowserViewControllerID"];
        targetController.modalPresentationStyle = presentationStyle;
        targetController.modalTransitionStyle = transitionStyle;
        [viewController presentViewController:targetController animated:YES completion:nil];
        UIInterfaceOrientation interfaceOrientation = viewController.interfaceOrientation;
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation))  {
            targetController.view.superview.center = viewController.view.center;
        } else {
            targetController.view.superview.center = CGPointMake(viewController.view.center.y, viewController.view.center.x);
        }
        targetController.uiDelegate = delegate;
        [targetController listDropboxDirectory];
}

#pragma mark - DropboxRootViewControllerDelegate functions

- (void)loadedFileFromDropbox:(NSString *)fileName {
    [[self uiDelegate] refreshLibrarySection];
}

#pragma mark - synthesize items

@synthesize uiDelegate;
@synthesize rootViewController;
@synthesize dataController;
@end
