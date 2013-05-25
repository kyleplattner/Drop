//
//  DroppedPinViewController.m
//  Drop
//
//  Created by Kyle Plattner on 5/1/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import "DroppedPinViewController.h"
#import "Drop.h"
#import "AppDelegate.h"
#import "PreviewController.h"

@interface DroppedPinViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
-(IBAction)viewFileButtonPressed:(id)sender;
-(IBAction)deleteDropButtonPressed:(id)sender;
-(IBAction)shareFileButtonPressed:(id)sender;
-(NSString *)fileExtension;
@end

@implementation DroppedPinViewController

-(id)initWithNibName:(NSString *)nibName mapView:(MKMapView *)mapView annotation:(Drop*)droppedPin {
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        _mapView = mapView;
        _droppedPin = droppedPin;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[_droppedPin filename] isEqualToString:@""]) {
        PFQuery *query = [PFQuery queryWithClassName:kParsePostsClassKey];
        PFObject *object = [query getObjectWithId:_droppedPin.object.objectId];
        [object fetchIfNeeded];
        [_label setText:[object objectForKey:kParseFilenameKey]];
    } else {
        [_label setText:[_droppedPin filename]];
    }
    [_usernameLabel setText:[NSString stringWithFormat:@"Posted by: %@", [_droppedPin getUsername]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)viewFileButtonPressed:(id)sender {
    NSURL *fileURL;
    if([[_droppedPin url] length] > 1) {
        fileURL = [[NSURL alloc] initFileURLWithPath:[_droppedPin url] isDirectory:NO];
    } else {
        PFQuery *query = [PFQuery queryWithClassName:kParsePostsClassKey];
        PFObject *object = [query getObjectWithId:_droppedPin.object.objectId];
        [object fetchIfNeeded];
        PFFile *file = [object objectForKey:kParseFileKey];
        NSData *data = [file getData];
        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* localPath = [documentsPath stringByAppendingPathComponent:file.name];
        [data writeToFile:localPath atomically:YES];
        fileURL = [[NSURL alloc] initFileURLWithPath:localPath isDirectory:NO];
    }
    PreviewController* previewController = [[PreviewController alloc] initWithItems:1 fileUrl:fileURL];
    [previewController setModalInPopover:YES];
    [previewController setModalPresentationStyle:UIModalPresentationPageSheet];
    [self presentViewController:previewController animated:YES completion:nil];
}

- (IBAction)deleteDropButtonPressed:(id)sender {
    [_mapView removeAnnotation:_droppedPin];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DismissPopoverNotification" object:nil];
    [_droppedPin deleteDrop];
}

- (IBAction)shareFileButtonPressed:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Not Implemented Yet" message:@"Feature Under Construction" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

-(NSString *)fileExtension {
    if([[_droppedPin filename] length] > 3) {
        return [[_droppedPin filename] substringFromIndex:[[_droppedPin filename] length] - 3];
    } else {
        return nil;
    }
}

@end
