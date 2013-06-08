//
//  UserPickerViewController.m
//  UserPicker
//
//  Created by Kyle Plattner on 5/27/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import "UserPickerViewController.h"
#import "Drop.h"

@interface UserPickerViewController ()
- (void)dispatchDismiss;
@end

@implementation UserPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUsers:(NSArray*)users forDrop:(Drop*)drop {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Share Drop";
        self.users = users;
        self.selectedUsers = [NSMutableArray array];
        self.filteredUsers = self.users;
        self.drop = drop;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem * barButtonLeft = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(removeAllusers:)];
    UIBarButtonItem * barButtonRight = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(dispatchDismiss)];
    [barButtonLeft setTintColor:[UIColor colorWithRed:0.421 green:0.610 blue:0.293 alpha:1.000]];
    [barButtonRight setTintColor:[UIColor colorWithRed:0.421 green:0.610 blue:0.293 alpha:1.000]];
    self.navigationItem.leftBarButtonItem = barButtonLeft;
    self.navigationItem.rightBarButtonItem = barButtonRight;
    self.userPickerView = [[UserPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    self.userPickerView.delegate = self;
    [self.userPickerView setPlaceholderString:@"Type Usernames to Share With"];
    [self.view addSubview:self.userPickerView];
    [self.userPickerView setBackgroundColor:[UIColor colorWithRed:0.988 green:0.984 blue:0.966 alpha:1.000]];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.964 green:0.955 blue:0.914 alpha:1.000];
    
    //add already selected users to selected array
    
    for (NSString *user in _drop.sharedUsers) {
        if(![user isEqualToString:[[PFUser currentUser] username]]) {
            [self.selectedUsers addObject:user];
            [self.userPickerView addUser:user withName:user];
        }
    }
    [self adjustTableViewFrame];
}

- (void)viewWillAppear:(BOOL)animated {
    [self adjustTableViewFrame];
}

-(void)viewWillDisappear:(BOOL)animated {
    [_drop shareFileWithUsers:self.selectedUsers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)adjustTableViewFrame {
    CGRect frame = self.tableView.frame;
    frame.origin.y = self.userPickerView.frame.size.height;
    frame.size.height = self.view.frame.size.height - self.userPickerView.frame.size.height;
    self.tableView.frame = frame;
}

-(void)dispatchDismiss {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CloseUserSharingPopoverNotification" object:nil];
}

#pragma mark - UITableView Delegate and Datasource functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"UsersCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [self.filteredUsers objectAtIndex:indexPath.row];
    if ([self.selectedUsers containsObject:[self.filteredUsers objectAtIndex:indexPath.row]]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSString *user = [self.filteredUsers objectAtIndex:indexPath.row];
    
    if ([self.selectedUsers containsObject:user]){
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedUsers removeObject:user];
        [self.userPickerView removeUser:user];
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedUsers addObject:user];
        [self.userPickerView addUser:user withName:user];
    }
    
    self.filteredUsers = self.users;
    [self.tableView reloadData];
}

#pragma mark - UserPickerTextViewDelegate

- (void)userPickerTextViewDidChange:(NSString *)textViewText {
    if ([textViewText isEqualToString:@""]){
        self.filteredUsers = self.users;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self contains[cd] %@", textViewText];
        self.filteredUsers = [self.users filteredArrayUsingPredicate:predicate];
    }
    [self.tableView reloadData];    
}

- (void)userPickerDidResize:(UserPickerView *)userPickerView {
    [self adjustTableViewFrame];
}

- (void)userPickerDidRemoveUser:(id)user {
    [self.selectedUsers removeObject:user];
    int index = [self.users indexOfObject:user];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)removeAllusers:(id)sender {
    [self.userPickerView removeAllUsers];
    [self.selectedUsers removeAllObjects];
    self.filteredUsers = self.users;
    [self.tableView reloadData];
}

@end
