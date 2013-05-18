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
        // raise alert
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:@"This application is not linked to your Dropbox account."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        
    }
    else {
        
        
        
        [self.rootViewController listHomeDirectory];
    }

    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                    style:UIBarButtonSystemItemDone target:self action:@selector(removeDropboxBrowser)];
//    self.navigationItem.rightBarButtonItem = rightButton;
    self.topViewController.navigationItem.rightBarButtonItem = rightButton;
    
    KioskDropboxPDFRootViewController *tController = (KioskDropboxPDFRootViewController *)[[self viewControllers]objectAtIndex:0];
    self.rootViewController = tController;
    self.rootViewController.rootViewDelegate = self;
    
    KioskDropboxPDFDataController *controller = [[KioskDropboxPDFDataController alloc] init];
    self.dataController = controller;
    
    self.rootViewController.dataController = self.dataController;
    self.dataController.dataDelegate = self.rootViewController;
    
}

+ (void)displayDropboxBrowserInPhoneStoryboard:(UIStoryboard *)iPhoneStoryboard displayDropboxBrowserInPadStoryboard:(UIStoryboard *)iPadStoryboard onView:(UIViewController *)viewController withPresentationStyle:(UIModalPresentationStyle)presentationStyle withTransitionStyle:(UIModalTransitionStyle)transitionStyle withDelegate:(id<KioskDropboxPDFBrowserViewControllerUIDelegate>)delegate
{
    //The session has already been linked
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //The user is on an iPhone - link the correct storyboard below
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
        
        // List the Dropbox Directory
        [targetController listDropboxDirectory];
        
    } else {
        //The user is on an iPhone - link the correct storyboard below
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
        
        // List the Dropbox Directory
        [targetController listDropboxDirectory];
    }

}

#pragma mark - KioskDropboxPDFRootViewControllerDelegate functions

- (void)loadedFileFromDropbox:(NSString *)fileName
{
        [[self uiDelegate] refreshLibrarySection];
}

#pragma mark - synthesize items

@synthesize uiDelegate;
@synthesize rootViewController;
@synthesize dataController;
@end
