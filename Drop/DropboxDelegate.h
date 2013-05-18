//
//  DropboxDelegate.h
//  Drop
//
//  Created by Kyle Plattner on 5/12/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KioskDropboxPDFBrowserViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import <AssetsLibrary/ALAsset.h>
#import "Drop.h"

@interface DropboxDelegate : NSObject <KioskDropboxPDFBrowserViewControllerUIDelegate, DBRestClientDelegate, UINavigationControllerDelegate>

@property (nonatomic, retain) UIViewController* view;
@property (nonatomic, retain) Drop *drop;

@end
