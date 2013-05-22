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
- (IBAction)viewFileButtonPressed:(id)sender;
@end

@implementation DroppedPinViewController

-(id)initWithNibName:(NSString *)nibName mapView:(MKMapView *)mapView annotation:(Drop*)droppedPin {
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        _mapView = mapView;
        _droppedPin = droppedPin;
//        PFQuery *query = [PFQuery queryWithClassName:kParsePostsClassKey];
//        [query getObjectWithId:droppedPin.object.objectId];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    PFObject *object = [_droppedPin object];
    [object fetchIfNeeded];
    PFFile *file = [object objectForKey:kParseFileKey];
    [_label setText:[file name]];
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

@end
