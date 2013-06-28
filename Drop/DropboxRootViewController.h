//
//  DropboxRootViewController.h
//  Drop
//
//  Created by Kyle Plattner on 6/28/13.
//  Copyright (c) 2013 Precision Planting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropboxDataController.h"
#import "MBProgressHUD.h"
#import "DropboxDataController.h"
#import <DropboxSDK/DropboxSDK.h>

typedef enum {
    DisclosureFileType
    , DisclosureDirType
} DisclosureType;

@protocol DropboxRootViewControllerDelegate;

@interface DropboxRootViewController : UITableViewController <DropboxDataControllerDelegate>

@property (nonatomic, weak) id <DropboxRootViewControllerDelegate>  rootViewDelegate;
@property (nonatomic, strong) DropboxDataController *dataController;

@property (nonatomic, strong) NSString *currentPath;
+ (NSString*)fileName;

@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) UIProgressView *downloadProgressView;
- (BOOL)listHomeDirectory;
@end

@protocol DropboxRootViewControllerDelegate <NSObject>
- (void)loadedFileFromDropbox:(NSString *)fileName;
@end
