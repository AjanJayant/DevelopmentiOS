//
//  CustomTextFieldDelegate.m
//  CardGame
//
//  Created by Ajan Jayant on 2013-07-30.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import "CustomTextFieldDelegate.h"

@implementation CustomTextFieldDelegate : NSObject

// Make field return if return is hit
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
