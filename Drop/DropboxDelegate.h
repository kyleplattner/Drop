//
//  DropboxDelegate.h
//  Drop
//
//  Created by Kyle Plattner on 5/12/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DropboxBrowserViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import <AssetsLibrary/ALAsset.h>
#import "Drop.h"
#import "MBProgressHUD.h"

@interface DropboxDelegate : NSObject <DropboxBrowserViewControllerUIDelegate, DBRestClientDelegate, UINavigationControllerDelegate, MBProgressHUDDelegate>

@property (nonatomic, retain) UIViewController* view;
@property (nonatomic, retain) Drop *drop;

@end
