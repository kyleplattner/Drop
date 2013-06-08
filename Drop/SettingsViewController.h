//
//  SettingsViewController.h
//  Drop
//
//  Created by Kyle Plattner on 5/4/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KioskDropboxPDFBrowserViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import <AssetsLibrary/ALAsset.h>
#import "ViewController.h"

@interface SettingsViewController : UIViewController <KioskDropboxPDFBrowserViewControllerUIDelegate, DBRestClientDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>
@property (nonatomic, retain) ViewController *viewController;
@end
