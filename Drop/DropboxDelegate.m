//
//  DropboxDelegate.m
//  Drop
//
//  Created by Kyle Plattner on 5/12/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import "DropboxDelegate.h"

@interface DropboxDelegate () {
    DBRestClient *restClient;
}
@end

@implementation DropboxDelegate

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)removeDropboxBrowser {
    [_view dismissViewControllerAnimated:YES completion:nil];
}

- (void)refreshLibrarySection {
    NSLog(@"Final Filename: %@", [KioskDropboxPDFRootViewController fileName]);
    [self removeDropboxBrowser];
}
@end
