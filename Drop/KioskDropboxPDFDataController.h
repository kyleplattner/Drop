//
//  KioskDropboxPDFDataController.h
//  epaper
//
//  Created by daniel bierwirth on 3/6/12.
//  Copyright (c) 2013 iRare Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DropboxSDK/DropboxSDK.h>

@class DBRestClient;
@class DBMetadata;

@protocol KioskDropboxPDFDataControllerDelegate;

@interface KioskDropboxPDFDataController : NSObject {
    DBRestClient *restClient;
}

@property (nonatomic) id <KioskDropboxPDFDataControllerDelegate> dataDelegate;

@property (nonatomic, copy, readwrite) NSMutableArray *list;
- (BOOL)listHomeDirectory;
- (BOOL)listDirectoryAtPath:(NSString*)path;
- (BOOL)isDropboxLinked;
- (BOOL)downloadFile:(DBMetadata *)file;
@end

@protocol KioskDropboxPDFDataControllerDelegate <NSObject>
- (void) updateTableData;
- (void) startDownloadFile;
- (void) downloadedFile;
- (void) downloadedFileFailed;
- (void) updateDownloadProgressTo:(CGFloat) progress;
@end

