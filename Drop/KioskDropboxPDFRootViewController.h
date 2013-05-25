//
//  KioskDropboxPDFRootViewController.h
//  epaper
//
//  Created by Daniel Bierwirth on 3/5/12. Edited and Updated by iRare Media on 2/24/13
//  Copyright (c) 2013 iRare Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KioskDropboxPDFDataController.h"
#import "MBProgressHUD.h"
#import "KioskDropboxPDFDataController.h"
#import <DropboxSDK/DropboxSDK.h>

typedef enum {
    DisclosureFileType
    , DisclosureDirType
} DisclosureType;

@protocol KioskDropboxPDFRootViewControllerDelegate;

@interface KioskDropboxPDFRootViewController : UITableViewController <KioskDropboxPDFDataControllerDelegate>

@property (nonatomic, weak) id <KioskDropboxPDFRootViewControllerDelegate>  rootViewDelegate;
@property (nonatomic, strong) KioskDropboxPDFDataController *dataController;

@property (nonatomic, strong) NSString *currentPath;
+ (NSString*)fileName;

@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) UIProgressView *downloadProgressView;
- (BOOL)listHomeDirectory;
@end

@protocol KioskDropboxPDFRootViewControllerDelegate <NSObject>
- (void)loadedFileFromDropbox:(NSString *)fileName;
@end
