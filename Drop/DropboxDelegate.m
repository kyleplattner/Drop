//
//  DropboxDelegate.m
//  Drop
//
//  Created by Kyle Plattner on 5/12/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import "DropboxDelegate.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>

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
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* localPath = [documentsPath stringByAppendingPathComponent:[KioskDropboxPDFRootViewController fileName]];
    if([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        NSData *data = [NSData dataWithContentsOfFile:localPath];
        PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:_drop.coordinate.latitude longitude:_drop.coordinate.longitude];
        PFUser *user = [PFUser currentUser];
        PFObject *postObject = [PFObject objectWithClassName:kParsePostsClassKey];
        [postObject setObject:user forKey:kParseUserKey];
        [postObject setObject:currentPoint forKey:kParseLocationKey];
        [postObject setObject:data forKey:kParseFileKey];
        [_drop setDropBoxFile:postObject];
        PFACL *readOnlyACL = [PFACL ACL];
        [readOnlyACL setPublicReadAccess:YES];
        [readOnlyACL setPublicWriteAccess:NO];
        [postObject setACL:readOnlyACL];
        [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"Couldn't save!");
                NSLog(@"%@", error);
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                [alertView show];
                return;
            }
            if (succeeded) {
                NSLog(@"Successfully saved!");
                NSLog(@"%@", postObject);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"PostCreatedNotification" object:nil];
                });
            } else {
                NSLog(@"Failed to save.");
            }
        }];
    }
    [self removeDropboxBrowser];
}

@end
