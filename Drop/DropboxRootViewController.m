//
//  DropboxRootViewController.m
//  Drop
//
//  Created by Kyle Plattner on 6/28/13.
//  Copyright (c) 2013 Precision Planting. All rights reserved.
//

#import "DropboxRootViewController.h"

@interface DropboxRootViewController (hudhelper)
- (void)timeout:(id)arg;
@end

@implementation DropboxRootViewController (hudhelper)
- (void)timeout:(id)arg {
    self.hud.labelText = @"Timeout!";
    self.hud.detailsLabelText = @"Please try again later.";
    self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	self.hud.mode = MBProgressHUDModeCustomView;
    [self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:3.0];
}
@end


@interface DropboxRootViewController (customdetaildisclosurebuttonhandling)
- (void) moveToParentDirectory;
- (UIButton *) makeDetailDisclosureButton:(DisclosureType)disclosureType;
@end

@interface DropboxRootViewController (tabledatahandling)
- (void) refreshTableView;
@end

@implementation DropboxRootViewController (tabledatahandling)
- (void) refreshTableView {
    [self.tableView reloadData];
}
@end

#pragma mark - Main Implementation

@implementation DropboxRootViewController
static NSString* currentFileName = nil;

#pragma mark - Public Functions

+ (NSString*)fileName {
    return currentFileName;
}

- (BOOL)listHomeDirectory {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = @"Retrieving Data...";
    [self performSelector:@selector(timeout:) withObject:nil afterDelay:30.0];
    [self.dataController listHomeDirectory];
    return TRUE;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Select File to Drop";
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(moveToParentDirectory)];
    self.navigationItem.leftBarButtonItem = leftButton;
    self.currentPath = @"/";
    UIProgressView *newProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    newProgressView.frame = CGRectMake(190, 17, 150, 30);
    newProgressView.hidden = TRUE;
    [self.parentViewController.view addSubview:newProgressView];
    [self setDownloadProgressView:newProgressView];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataController.list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"KioskDropboxBrowserCell";
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    DBMetadata *file = (DBMetadata*)[self.dataController.list objectAtIndex:indexPath.row];    
    cell.textLabel.text = file.filename; 
    [cell.textLabel setNeedsDisplay];
    for (int i = 0; i < [cell.subviews count]; i++) {
        UIView* tView = [cell.subviews objectAtIndex:i];
        if (tView.tag == 123456) {
            [tView removeFromSuperview];
            tView = nil;
            break;
        }
    }
    UIButton *customDownloadbutton = nil;
    if ([file isDirectory]) {
        cell.imageView.image = [UIImage imageNamed:@"dropboxDirIcon.png"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Folder"];
        customDownloadbutton = [self makeDetailDisclosureButton:DisclosureDirType];
    }
    else if (![file.filename hasSuffix:@".exe"]){
        cell.imageView.image = [UIImage imageNamed:@"pdfFileIcon.png"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"File Size: %@", file.humanReadableSize];   
        customDownloadbutton = [self makeDetailDisclosureButton:DisclosureFileType];
    }
    [cell.detailTextLabel setNeedsDisplay];
    CGRect tFrame = customDownloadbutton.frame;
    tFrame.origin.x = cell.frame.size.width - (customDownloadbutton.frame.size.width + customDownloadbutton.frame.size.width/2)+5;
    tFrame.origin.y = cell.frame.size.height/2 - customDownloadbutton.frame.size.height/2;
    customDownloadbutton.frame = tFrame;
    customDownloadbutton.tag = 123456;
    [cell addSubview:customDownloadbutton];
    return cell;
}

#pragma mark - Table View Accessory Button

- (void)moveToParentDirectory {
    if([self.currentPath isEqualToString:[NSString stringWithFormat:@"/"]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveBrowserNotification" object:nil];
    } else {
        self.currentPath = [NSString stringWithFormat:@"/"];
        [[self dataController] listDirectoryAtPath:self.currentPath];
    }
}

- (UIButton *)makeDetailDisclosureButton:(DisclosureType)disclosureType {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 37, 37);
    switch (disclosureType) {
        case DisclosureDirType:
            [button setBackgroundImage:[UIImage imageNamed:@"browseDirectoryIcon.png"] forState:UIControlStateNormal];
            break;
        case DisclosureFileType:
            [button setBackgroundImage:[UIImage imageNamed:@"downloadIcon.png"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    
    [button addTarget:self action: @selector(accessoryButtonTapped:withEvent:) forControlEvents: UIControlEventTouchUpInside];
    return ( button );
}

- (void)accessoryButtonTapped:(UIControl *)button withEvent:(UIEvent *) event {
    
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.tableView]];
    if ( indexPath == nil )
        return;
    
    DBMetadata *file = (DBMetadata*)[self.dataController.list objectAtIndex:indexPath.row];
    
    if ([file isDirectory]) {        
        NSString *subpath = [NSString stringWithFormat:@"%@%@/",self.currentPath, file.filename];
        self.currentPath = subpath;        
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.labelText = @"Retrieving Data..";
        [self performSelector:@selector(timeout:) withObject:nil afterDelay:30.0];
        [[self dataController] listDirectoryAtPath:subpath];
    }
    else if (![file.filename hasSuffix:@".exe"] && [file totalBytes] < 10000000) {
        UITableViewCell *tcell = [self.tableView cellForRowAtIndexPath:indexPath];
        for (int i = 0; i < [tcell.subviews count]; i++) {
            UIButton* tView = (UIButton*)[tcell.subviews objectAtIndex:i];
            if (tView.tag == 123456) {
                [tView setEnabled:FALSE];
                break;
            }
        }        
        [[self dataController] downloadFile:file];
        currentFileName = file.filename;
    } else if ([file totalBytes] >= 10000000) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Too Large" message:@"Drop does not work with files larger than 10 MB." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath == nil )
        return;
    
    DBMetadata *file = (DBMetadata*)[self.dataController.list objectAtIndex:indexPath.row];
    if ([file isDirectory]) {
        NSString *subpath = [NSString stringWithFormat:@"%@%@/",self.currentPath, file.filename];
        self.currentPath = subpath;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.labelText = @"Downloading File...";
        [self performSelector:@selector(timeout:) withObject:nil afterDelay:30.0];
        [[self dataController] listDirectoryAtPath:subpath];
    } else if (![file.filename hasSuffix:@".exe"] && [file totalBytes] < 10000000) {
        UITableViewCell *tcell = [self.tableView cellForRowAtIndexPath:indexPath];
        for (int i = 0; i < [tcell.subviews count]; i++) {
            UIButton* tView = (UIButton*)[tcell.subviews objectAtIndex:i];
            if (tView.tag == 123456) {
                [tView setEnabled:FALSE];
                break;
            }
        }
        [[self dataController] downloadFile:file];
        currentFileName = file.filename;
    } else if ([file totalBytes] >= 10000000) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Too Large" message:@"Drop does not work with files larger than 10 MB." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - DataController Delegate

- (void)updateTableData {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self performSelectorOnMainThread:@selector(refreshTableView) withObject:nil waitUntilDone:NO];
    
}

- (void)downloadedFile {
    [self.downloadProgressView setHidden:TRUE];
    self.title = @"Select File to Drop";
    [[self rootViewDelegate] loadedFileFromDropbox:currentFileName];
}

- (void)startDownloadFile {
    [self.downloadProgressView setHidden:FALSE];
    self.title = @"";
}

- (void)downloadedFileFailed {
    [self.downloadProgressView setHidden:TRUE];
    self.title = @"Select File to Drop";
}

- (void)updateDownloadProgressTo:(CGFloat)progress {
    [self.downloadProgressView setProgress:progress];
}

#pragma mark - Synthesize Items
@synthesize dataController;
@synthesize currentPath;
@synthesize rootViewDelegate;
@synthesize hud;
@synthesize downloadProgressView;

@end
