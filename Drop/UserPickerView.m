//
//  UserPickerTextView.m
//  UserPicker
//
//  Created by Kyle Plattner on 5/27/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import "UserPickerView.h"
#import "UserBubble.h"

@interface UserPickerView (){
    BOOL _shouldSelectTextView;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableDictionary *users;
@property (nonatomic, strong) NSMutableArray *userKeys;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UserBubbleColor *bubbleColor;
@property (nonatomic, strong) UserBubbleColor *bubbleSelectedColor;

@end

@implementation UserPickerView

#define kViewPadding 5
#define kHorizontalPadding 2 
#define kVerticalPadding 4 
#define kTextViewMinWidth 130

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code        
        [self setup];
    }
    return self;
}

- (void)setup {
    self.viewPadding = kViewPadding;
    
    self.users = [NSMutableDictionary dictionary];
    self.userKeys = [NSMutableArray array];
    
    // Create a user bubble to determine the height of a line
    UserBubble *userBubble = [[UserBubble alloc] initWithName:@"Sample"];
    self.lineHeight = userBubble.frame.size.height + 2 * kVerticalPadding;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
    
    // Create TextView
    // It would make more sense to use a UITextField (because it doesnt wrap text), however, there is no easy way to detect the "delete" key press using a UITextField when there is no 
    self.textView = [[UITextView alloc] init];
    self.textView.delegate = self;
    self.textView.font = userBubble.label.font;
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.contentInset = UIEdgeInsetsMake(-11, -6, 0, 0);
    self.textView.scrollEnabled = NO;
    self.textView.scrollsToTop = NO;
    [self.textView becomeFirstResponder];
    
    // Add shadow to bottom border
    self.backgroundColor = [UIColor whiteColor];
    CALayer *layer = [self layer];
    [layer setShadowColor:[[UIColor colorWithRed:225.0/255.0 green:226.0/255.0 blue:228.0/255.0 alpha:1] CGColor]];
    [layer setShadowOffset:CGSizeMake(0, 2)];
    [layer setShadowOpacity:1];
    [layer setShadowRadius:1.0f];
    
    // Add placeholder label
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, self.viewPadding, self.frame.size.width, self.lineHeight)];
    self.placeholderLabel.font = userBubble.label.font;
    self.placeholderLabel.textColor = [UIColor grayColor];
    self.placeholderLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.placeholderLabel];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapGesture];
}

#pragma mark - Public functions

- (void)disableDropShadow {
    CALayer *layer = [self layer];
    [layer setShadowRadius:0];
    [layer setShadowOpacity:0];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    UserBubble *userBubble = [[UserBubble alloc] initWithName:@"Sample"];
    [userBubble setFont:font];
    self.lineHeight = userBubble.frame.size.height + 2 * kVerticalPadding;
    
    self.textView.font = font;
    [self.textView sizeToFit];
    
    self.placeholderLabel.font = font;
    self.placeholderLabel.frame = CGRectMake(8, self.viewPadding, self.frame.size.width, self.lineHeight);
}

- (void)addUser:(id)user withName:(NSString *)name {
    id userKey = [NSValue valueWithNonretainedObject:user];
    if ([self.userKeys containsObject:userKey]){
        NSLog(@"Cannot add the same object twice to UserPickerView");
        return;
    }
    
    self.textView.text = @"";
    
    UserBubble *userBubble = [[UserBubble alloc] initWithName:name color:self.bubbleColor selectedColor:self.bubbleSelectedColor];
    if (self.font != nil){
        [userBubble setFont:self.font];
    }
    userBubble.delegate = self;
    [self.users setObject:userBubble forKey:userKey];
    [self.userKeys addObject:userKey];
    
    [self layoutView];
    
    // scroll to bottom
    _shouldSelectTextView = YES;
    [self scrollToBottomWithAnimation:YES];
}

- (void)selectTextView {
    self.textView.hidden = NO;
    [self.textView becomeFirstResponder];
}

- (void)removeAllUsers {
    for(id user in [self.users allKeys]){
      UserBubble *userBubble = [self.users objectForKey:user];
      [userBubble removeFromSuperview];
    }
    [self.users removeAllObjects];
    [self.userKeys removeAllObjects];
  
    // update layout
    [self layoutView];
  
    self.textView.hidden = NO;
    self.textView.text = @"";
}

- (void)removeUser:(id)user {
  
    id userKey = [NSValue valueWithNonretainedObject:user];
    UserBubble *userBubble = [self.users objectForKey:userKey];
    [userBubble removeFromSuperview];
    
    // Remove user from memory
    [self.users removeObjectForKey:userKey];
    [self.userKeys removeObject:userKey];
    
    // update layout
    [self layoutView];

    [self.textView becomeFirstResponder];
    self.textView.hidden = NO;
    self.textView.text = @"";
    
    [self scrollToBottomWithAnimation:NO];
}

- (void)setPlaceholderString:(NSString *)placeholderString {
    self.placeholderLabel.text = placeholderString;

    [self layoutView];
}

- (void)resignKeyboard {
    [self.textView resignFirstResponder];
}

- (void)setViewPadding:(CGFloat)viewPadding {
    _viewPadding = viewPadding;

    [self layoutView];
}

- (void)setBubbleColor:(UserBubbleColor *)color selectedColor:(UserBubbleColor *)selectedColor {
    self.bubbleColor = color;
    self.bubbleSelectedColor = selectedColor;

    for (id userKey in self.userKeys){
        UserBubble *userBubble = (UserBubble *)[self.users objectForKey:userKey];

        userBubble.color = color;
        userBubble.selectedColor = selectedColor;

        // thid stuff reloads bubble
        if (userBubble.isSelected)
            [userBubble select];
        else
            [userBubble unSelect];
    }
}

#pragma mark - Private functions

- (void)scrollToBottomWithAnimation:(BOOL)animated {
    if (animated){
        CGSize size = self.scrollView.contentSize;
        CGRect frame = CGRectMake(0, size.height - self.scrollView.frame.size.height, size.width, self.scrollView.frame.size.height);
        [self.scrollView scrollRectToVisible:frame animated:animated];
    } else {
        CGPoint offset = self.scrollView.contentOffset;
        offset.y = self.scrollView.contentSize.height - self.scrollView.frame.size.height;
        self.scrollView.contentOffset = offset;
    }
}

- (void)removeuserBubble:(UserBubble *)userBubble {
    id user = [self userForuserBubble:userBubble];
    if (user == nil){
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(userPickerDidRemoveUser:)]){
        [self.delegate userPickerDidRemoveUser:[user nonretainedObjectValue]];
    }
    
    [self removeUserByKey:user];
}

- (void)removeUserByKey:(id)userKey {
  
  // Remove userBubble from view
  UserBubble *userBubble = [self.users objectForKey:userKey];
  [userBubble removeFromSuperview];
  
  // Remove user from memory
  [self.users removeObjectForKey:userKey];
  [self.userKeys removeObject:userKey];
  
  // update layout
  [self layoutView];
  
  [self.textView becomeFirstResponder];
  self.textView.hidden = NO;
  self.textView.text = @"";
  
  [self scrollToBottomWithAnimation:NO];
}

- (id)userForuserBubble:(UserBubble *)userBubble {
    NSArray *keys = [self.users allKeys];
    
    for (id user in keys){
        if ([[self.users objectForKey:user] isEqual:userBubble]){
            return user;
        }
    }
    return nil;
}

- (void)layoutView {
    CGRect frameOfLastBubble = CGRectNull;
    int lineCount = 0;
    
    // Loop through selectedusers and position/add them to the view
    for (id userKey in self.userKeys){
        UserBubble *userBubble = (UserBubble *)[self.users objectForKey:userKey];
        CGRect bubbleFrame = userBubble.frame;

        if (CGRectIsNull(frameOfLastBubble)){ // first line
            bubbleFrame.origin.x = kHorizontalPadding;
            bubbleFrame.origin.y = kVerticalPadding + self.viewPadding;
        } else {
            // Check if user bubble will fit on the current line
            CGFloat width = bubbleFrame.size.width + 2 * kHorizontalPadding;
            if (self.frame.size.width - frameOfLastBubble.origin.x - frameOfLastBubble.size.width - width >= 0){ // add to the same line
                // Place user bubble just after last bubble on the same line
                bubbleFrame.origin.x = frameOfLastBubble.origin.x + frameOfLastBubble.size.width + kHorizontalPadding * 2;
                bubbleFrame.origin.y = frameOfLastBubble.origin.y;
            } else { // No space on line, jump to next line
                lineCount++;
                bubbleFrame.origin.x = kHorizontalPadding;
                bubbleFrame.origin.y = (lineCount * self.lineHeight) + kVerticalPadding + 	self.viewPadding;
            }
        }
        frameOfLastBubble = bubbleFrame;
        userBubble.frame = bubbleFrame;
        // Add user bubble if it hasn't been added
        if (userBubble.superview == nil){
            [self.scrollView addSubview:userBubble];
        }
    }
    
    // Now add a textView after the comment bubbles
    CGFloat minWidth = kTextViewMinWidth + 2 * kHorizontalPadding;
    CGRect textViewFrame = CGRectMake(0, 0, self.textView.frame.size.width, self.lineHeight - 2 * kVerticalPadding);
    // Check if we can add the text field on the same line as the last user bubble
    if (self.frame.size.width - frameOfLastBubble.origin.x - frameOfLastBubble.size.width - minWidth >= 0){ // add to the same line
        textViewFrame.origin.x = frameOfLastBubble.origin.x + frameOfLastBubble.size.width + kHorizontalPadding;
        textViewFrame.size.width = self.frame.size.width - textViewFrame.origin.x;
    } else { // place text view on the next line
        lineCount++;
        if (self.users.count == 0){
            lineCount = 0;
        }
        
        textViewFrame.origin.x = kHorizontalPadding;
        textViewFrame.size.width = self.frame.size.width - 2 * kHorizontalPadding;
    }
    self.textView.frame = textViewFrame;
    self.textView.center = CGPointMake(self.textView.center.x, lineCount * self.lineHeight + self.lineHeight / 2 + kVerticalPadding + self.viewPadding);
    
    // Add text view if it hasn't been added 
    if (self.textView.superview == nil){
        [self.scrollView addSubview:self.textView];
    }

    // Hide the text view if we are limiting number of selected users to 1 and a user has already been added
    if (self.limitToOne && self.users.count >= 1){
        self.textView.hidden = YES;
        lineCount = 0;
    }
    
    // Adjust scroll view content size
    CGRect frame = self.bounds;
    CGFloat maxFrameHeight = 2 * self.lineHeight + 2 * self.viewPadding; // limit frame to two lines of content
    CGFloat newHeight = (lineCount + 1) * self.lineHeight + 2 * self.viewPadding;
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width, newHeight);

    // Adjust frame of view if necessary
    newHeight = (newHeight > maxFrameHeight) ? maxFrameHeight : newHeight;
    if (self.frame.size.height != newHeight){
        // Adjust self height
        CGRect selfFrame = self.frame;
        selfFrame.size.height = newHeight;
        self.frame = selfFrame;
        
        // Adjust scroll view height
        frame.size.height = newHeight;
        self.scrollView.frame = frame;
        
        if ([self.delegate respondsToSelector:@selector(userPickerDidResize:)]){
            [self.delegate userPickerDidResize:self];
        }
    }
    
    // Show placeholder if no there are no users
    if (self.users.count == 0){
        self.placeholderLabel.hidden = NO;
    } else {
        self.placeholderLabel.hidden = YES;
    }
}

#pragma mark - UITextViewDelegate 

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    self.textView.hidden = NO;
    
    if ( [text isEqualToString:@"\n"] ) { // Return key was pressed
        return NO;
    }
    
    // Capture "delete" key press when cell is empty
    if ([textView.text isEqualToString:@""] && [text isEqualToString:@""]){
        // If no users are selected, select the last user
        self.selectedUserBubble = [self.users objectForKey:[self.userKeys lastObject]];
        [self.selectedUserBubble select];
    }

    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {    
    if ([self.delegate respondsToSelector:@selector(userPickerTextViewDidChange:)]){
        [self.delegate userPickerTextViewDidChange:textView.text];
    }
    
    if ([textView.text isEqualToString:@""] && self.users.count == 0){
        self.placeholderLabel.hidden = NO;
    } else {
        self.placeholderLabel.hidden = YES;
    }
}

#pragma mark - UserBubbleDelegate Functions

- (void)userBubbleWasSelected:(UserBubble *)userBubble {
    if (self.selectedUserBubble != nil){
        [self.selectedUserBubble unSelect];
    }
    self.selectedUserBubble = userBubble;
    
    [self.textView resignFirstResponder];
    self.textView.text = @"";
    self.textView.hidden = YES;
}

- (void)userBubbleWasUnSelected:(UserBubble *)userBubble {
    if (self.selectedUserBubble != nil){
        
    }
    [self.textView becomeFirstResponder];
    self.textView.text = @"";
    self.textView.hidden = NO;
}

- (void)userBubbleShouldBeRemoved:(UserBubble *)userBubble {
    [self removeuserBubble:userBubble];
}

#pragma mark - Gesture Recognizer

- (void)handleTapGesture {
    if (self.limitToOne && self.userKeys.count == 1){
        return;
    }
    [self scrollToBottomWithAnimation:YES];
    
    // Show textField
    self.textView.hidden = NO;
    [self.textView becomeFirstResponder];
    
    // Unselect user bubble
    [self.selectedUserBubble unSelect];
    self.selectedUserBubble = nil;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (_shouldSelectTextView){
        _shouldSelectTextView = NO;
        [self selectTextView];
    }
}

@end
