//
//  DropboxDataController.m
//  Drop
//
//  Created by Kyle Plattner on 6/28/13.
//  Copyright (c) 2013 Precision Planting. All rights reserved.
//

#import "DropboxDataController.h"

@interface DropboxDataController () <DBRestClientDelegate>

@end

@interface DropboxDataController (fileimport)
- (DBRestClient *)restClient;
@end

@implementation DropboxDataController (fileimport)
- (DBRestClient *)restClient {
    if (!restClient) {
        restClient = 
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}
@end

@implementation DropboxDataController

#pragma mark - public functions
- (BOOL)listDirectoryAtPath:(NSString*)path {
    if ([self isDropboxLinked]) {
        [[self restClient] loadMetadata:path];
        return TRUE;
    }
    else {
        return FALSE;
    }
}
- (BOOL)listHomeDirectory {
    return [self listDirectoryAtPath:@"/"];
}

- (BOOL)isDropboxLinked {
    return [[DBSession sharedSession] isLinked];
}

- (BOOL)downloadFile:(DBMetadata *)file {
    BOOL res = FALSE;
    if (!file.isDirectory) {
        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* localPath = [documentsPath stringByAppendingPathComponent:file.filename];
        if(![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
            if ([[self dataDelegate] respondsToSelector:@selector(startDownloadFile)])
                [[self dataDelegate] startDownloadFile];
            res = TRUE;
            [[self restClient] loadFile:file.path intoPath:localPath];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Select Another File" message:@"That file has already been tagged with a location."  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }
    return res;
}

- (void)setList:(NSMutableArray *)newList {
    if (list != newList) {
        list = [newList mutableCopy];
    }
}

#pragma mark DBRestClientDelegate methods
- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    NSMutableArray *dirList = [[NSMutableArray alloc] init];
    if (metadata.isDirectory) {
        for (DBMetadata *file in metadata.contents) {
            NSLog(@"file name %@ is %lld", [file filename], [file totalBytes]);
            if ([file isDirectory] || ![file.filename hasSuffix:@".exe"] || ![file totalBytes] > 10000000) {
                [dirList addObject:file];
            }
        }
    }
    self.list = dirList;
    
    if ([[self dataDelegate] respondsToSelector:@selector(updateTableData)])
        [[self dataDelegate] updateTableData];
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    if ([[self dataDelegate] respondsToSelector:@selector(updateTableData)])
        [[self dataDelegate] updateTableData];
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath {
    if ([[self dataDelegate] respondsToSelector:@selector(downloadedFile)])
        [[self dataDelegate] downloadedFile];
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
    if ([[self dataDelegate] respondsToSelector:@selector(downloadedFileFailed)])
        [[self dataDelegate] downloadedFileFailed];
}

- (void)restClient:(DBRestClient*)client loadProgress:(CGFloat)progress forFile:(NSString*)destPath {
    if ([[self dataDelegate] respondsToSelector:@selector(updateDownloadProgressTo:)])
        [[self dataDelegate] updateDownloadProgressTo:progress];
}

#pragma mark - synthesize stuff
@synthesize dataDelegate;
@synthesize list;

@end
