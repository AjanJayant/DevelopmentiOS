//
//  UIPlaceHolderTextView.h
//  GMv2
//
//  Created by Ajan Jayant on 2013-06-26.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface UIPlaceHolderTextView : UITextView

@property (nonatomic, retain) NSString *placeholder;

@property (nonatomic, retain) UIColor *placeholderColor;

- (void)textChanged:(NSNotification*)notification;

- (void) setHolder: (NSString *) str;

@end