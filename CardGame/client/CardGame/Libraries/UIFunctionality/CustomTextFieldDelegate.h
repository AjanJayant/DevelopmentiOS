//
//  CustomTextFieldDelegate.h
//  CardGame
//
//  Created by Ajan Jayant on 2013-07-30.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CustomTextFieldDelegate <NSObject>

- (BOOL)textFieldShouldReturn:(UITextField *)textField;

@end

// Must mention UITextFieldDelegate so delegating object knows that it contains said function
@interface CustomTextFieldDelegate : NSObject <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField;

@end