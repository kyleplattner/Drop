//
//  THBubbleColor.h
//  UserPicker
//
//  Created by Kyle Plattner on 5/27/13.
//  Copyright (c) 2013 Kyle Plattner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserBubbleColor : NSObject

@property (nonatomic, strong) UIColor *gradientTop;
@property (nonatomic, strong) UIColor *gradientBottom;
@property (nonatomic, strong) UIColor *border;

- (id)initWithGradientTop:(UIColor *)gradientTop gradientBottom:(UIColor *)gradientBottom border:(UIColor *)border;

@end
