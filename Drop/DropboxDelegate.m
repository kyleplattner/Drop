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
#import "MBProgressHUD.h"

@interface DropboxDelegate () {
    DBRestClient *restClient;
}
- (void)postFileWithName:(NSString *)name atPath:(NSString *)path;
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
        [_drop setUrl:localPath];
        [self postFileWithName:[KioskDropboxPDFRootViewController fileName] atPath:localPath];
    }
    [self removeDropboxBrowser];
}

- (void)postFileWithName:(NSString *)name atPath:(NSString *)path {
    PFFile *file = [PFFile fileWithName:name contentsAtPath:path];
    [_drop setDropBoxFile:file];
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:_view.view animated:YES];
    HUD.mode = MBProgressHUDModeDeterminate;
    HUD.labelText = @"Tagging";
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:_drop.coordinate.latitude longitude:_drop.coordinate.longitude];
            PFUser *user = [PFUser currentUser];
            PFObject *postObject = [PFObject objectWithClassName:kParsePostsClassKey];
            NSArray *sharedUsers = [[NSArray alloc] initWithObjects:[user username], nil];
            [postObject setObject:user forKey:kParseUserKey];
            [postObject setObject:currentPoint forKey:kParseLocationKey];
            [postObject setObject:file forKey:kParseFileKey];
            [postObject setObject:name forKey:kParseFilenameKey];
            [postObject setObject:[user username] forKey:kParseUsernameKey];
            [postObject setObject:sharedUsers forKey:kParseSharedUserArrayKey];
            [_drop setUser:user];
            [_drop setObject:postObject];
            [_drop setGeopoint:currentPoint];
            [_drop setFilename:name];
            [_drop setUsername:[user username]];
            [_drop setSharedUsers:sharedUsers];
            [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    [HUD hide:YES];
                    NSLog(@"Couldn't save!");
                    NSLog(@"%@", error);
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                    [alertView show];
                    return;
                }
                if (succeeded) {
                    [HUD hide:YES];
                    NSLog(@"Successfully saved!");
                    NSLog(@"%@", postObject);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadAnnoationsNotification" object:nil];
                    });
                } else {
                    NSLog(@"Failed to save.");
                }
            }];
        }
        else{
            [HUD hide:YES];
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    } progressBlock:^(int percentDone) {
        HUD.progress = (float)percentDone/100;
    }];
}

@end
