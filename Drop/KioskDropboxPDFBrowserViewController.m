//
//  KioskDropboxPDFBrowserViewController.m
//  epaper
//
//  Created by Daniel Bierwirth on 3/5/12. Edited and Updated by iRare Media on 2/24/13
//  Copyright (c) 2013 iRare Media. All rights reserved.
//

#import "KioskDropboxPDFBrowserViewController.h"

@interface KioskDropboxPDFBrowserViewController () <KioskDropboxPDFRootViewControllerDelegate>

@end


@interface KioskDropboxPDFBrowserViewController (navigationcontrollermanagement)
/**
 * user hit browser close button
 * tell delegate to remove modal view
 */
- (void)removeDropboxBrowser;
@end

@implementation KioskDropboxPDFBrowserViewController (navigationcontrollermanagement)
- (void)removeDropboxBrowser {
    if ([[self uiDelegate] respondsToSelector:@selector(removeDropboxBrowser)])
        [[self uiDelegate] removeDropboxBrowser];
}
@end



@implementation KioskDropboxPDFBrowserViewController

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
    KioskDropboxPDFRootViewController *tController = (KioskDropboxPDFRootViewController *)[[self viewControllers]objectAtIndex:0];
    self.rootViewController = tController;
    self.rootViewController.rootViewDelegate = self;
    KioskDropboxPDFDataController *controller = [[KioskDropboxPDFDataController alloc] init];
    self.dataController = controller;
    self.rootViewController.dataController = self.dataController;
    self.dataController.dataDelegate = self.rootViewController;
}

+ (void)displayDropboxBrowserInPhoneStoryboard:(UIStoryboard *)iPhoneStoryboard displayDropboxBrowserInPadStoryboard:(UIStoryboard *)iPadStoryboard onView:(UIViewController *)viewController withPresentationStyle:(UIModalPresentationStyle)presentationStyle withTransitionStyle:(UIModalTransitionStyle)transitionStyle withDelegate:(id<KioskDropboxPDFBrowserViewControllerUIDelegate>)delegate {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        KioskDropboxPDFBrowserViewController *targetController = [iPhoneStoryboard instantiateViewControllerWithIdentifier:@"KioskDropboxPDFBrowserViewControllerID"];
        targetController.modalPresentationStyle = presentationStyle;
        targetController.modalTransitionStyle = transitionStyle;
        [viewController presentViewController:targetController animated:YES completion:nil];
        targetController.view.autoresizingMask =  UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        UIInterfaceOrientation interfaceOrientation = viewController.interfaceOrientation;
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation))  {
            targetController.view.superview.center = viewController.view.center;
        } else {
            targetController.view.superview.center = CGPointMake(viewController.view.center.y, viewController.view.center.x);
        }
        targetController.uiDelegate = delegate;
        [targetController listDropboxDirectory];
    } else {
        KioskDropboxPDFBrowserViewController *targetController = [iPadStoryboard instantiateViewControllerWithIdentifier:@"KioskDropboxPDFBrowserViewControllerID"];
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

}

#pragma mark - KioskDropboxPDFRootViewControllerDelegate functions

- (void)loadedFileFromDropbox:(NSString *)fileName {
    [[self uiDelegate] refreshLibrarySection];
}

#pragma mark - synthesize items

@synthesize uiDelegate;
@synthesize rootViewController;
@synthesize dataController;
@end
