//
//  DropboxDataController.h
//  Drop
//
//  Created by Kyle Plattner on 6/28/13.
//  Copyright (c) 2013 Precision Planting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DropboxSDK/DropboxSDK.h>

@class DBRestClient;
@class DBMetadata;

@protocol DropboxDataControllerDelegate;

@interface DropboxDataController : NSObject {
    DBRestClient *restClient;
}

@property (nonatomic) id <DropboxDataControllerDelegate> dataDelegate;

@property (nonatomic, copy, readwrite) NSMutableArray *list;
- (BOOL)listHomeDirectory;
- (BOOL)listDirectoryAtPath:(NSString*)path;
- (BOOL)isDropboxLinked;
- (BOOL)downloadFile:(DBMetadata *)file;
@end

@protocol DropboxDataControllerDelegate <NSObject>
- (void)updateTableData;
- (void)startDownloadFile;
- (void)downloadedFile;
- (void)downloadedFileFailed;
- (void)updateDownloadProgressTo:(CGFloat) progress;
@end

