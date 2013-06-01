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
#import "UserPickerViewController.h"
#import "NPReachability.h"
#import "GIKPopoverBackgroundView.h"
#import "BButton.h"

@interface DroppedPinViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet BButton *deleteButton;
@property (weak, nonatomic) IBOutlet BButton *shareButton;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UISwitch *publicSwitch;
-(IBAction)publicSwitch:(id)sender;
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissPopover) name:@"CloseUserSharingPopoverNotification" object:nil];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[_droppedPin filename] isEqualToString:@""]) {
        PFQuery *query = [PFQuery queryWithClassName:kParsePostsClassKey];
        PFObject *object = [query getObjectWithId:_droppedPin.object.objectId];
        [object fetchIfNeeded];
        [_droppedPin setFilename:[object objectForKey:kParseFilenameKey]];
        [_label setText:[object objectForKey:kParseFilenameKey]];
    } else {
        [_label setText:[_droppedPin filename]];
    }
    [_usernameLabel setText:[NSString stringWithFormat:@"Posted by: %@", [_droppedPin getUsername]]];
    [_shareButton setHidden:![self shouldAllowDeleteAndShare]];
    [_deleteButton setHidden:![self shouldAllowDeleteAndShare]];
    [_publicSwitch setHidden:![self shouldAllowDeleteAndShare]];
    [_thumbnail setImage:[self fileThumbnail]];
    [_publicSwitch setOn:[_droppedPin isFilePublic]];
    [_shareButton setEnabled:![_droppedPin isFilePublic]];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    if (![[NPReachability sharedInstance] isCurrentlyReachable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"In order to share a file an internet connection is necessary." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        PFQuery *query = [PFQuery queryWithClassName:kParseUserClassKey];
        
        //TODO: can I run a fetch in the background and still have an array to populalate the UITableView with?
        
        NSArray *objects = [query findObjects];
        
        NSMutableArray *users = [[NSMutableArray alloc] init];
        for (PFObject *object in objects) {
            if([[object objectForKey:kParseUsernameKey] isEqualToString:[[PFUser currentUser] username]] || [[object objectForKey:kParseUsernameKey] isEqualToString:@"public"]) {
                [users addObject:[object objectForKey:kParseUsernameKey]];
            }
        }
        UserPickerViewController *userPicker = [[UserPickerViewController alloc] initWithNibName:@"UserPickerViewController" bundle:nil andUsers:users forDrop:_droppedPin];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPicker];
        if (self.userSelectorPopoverController == nil) {
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:navigationController];
            popover.delegate = self;
            self.userSelectorPopoverController = popover;
        } else {
            [_userSelectorPopoverController setContentViewController:navigationController animated:YES];
        }
        [_userSelectorPopoverController setPopoverBackgroundViewClass:[GIKPopoverBackgroundView class]];
        [_userSelectorPopoverController setPopoverContentSize:CGSizeMake(320, 250)];
        UIButton *button = sender;
        [_userSelectorPopoverController presentPopoverFromRect:button.frame inView:_mapView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

-(NSString *)fileExtension {
    if([[_droppedPin filename] length] > 3) {
        return [[_droppedPin filename] substringFromIndex:[[_droppedPin filename] length] - 3];
    } else {
        return nil;
    }
}

-(UIImage *)fileThumbnail {
    UIImage *thumbnail = [UIImage imageNamed:[NSString stringWithFormat:@"%@", [self fileExtension]]];
    if (thumbnail) {
        return thumbnail;
    } else {
        return [UIImage imageNamed:[NSString stringWithFormat:@"blank"]];
    }
}

-(BOOL)shouldAllowDeleteAndShare {
    if ([[_droppedPin getUsername] isEqualToString:[[PFUser currentUser] username]]) {
        return true;
    } else {
        return false;
    }
}

-(void)dismissPopover {
    [_userSelectorPopoverController dismissPopoverAnimated:YES];
}

- (IBAction)publicSwitch:(id)sender {
    if ([_publicSwitch isOn]) {
        [_droppedPin makeFilePublic];
        [_shareButton setEnabled:NO];
    } else {
        [_droppedPin makeFilePrivate];
        [_shareButton setEnabled:YES];
    }
}

@end
