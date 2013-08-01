//
//  CustomTextField.h
//  CardGame
//
//  Created by Ajan Jayant on 2013-07-19.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

// configureTextField is overloaded

#import <UIKit/UIKit.h>

@interface CustomTextField : UITextField <UITextFieldDelegate>

@property (nonatomic) CGFloat screenWidth;

@property (nonatomic) CGFloat screenHeight;

- (void)configureTextField:(NSString *) place color:(UIColor *) col;

- (void)configureTextField:(NSString *) place color:(UIColor *) col moveWithKB:(BOOL) move returnHidesKB:(BOOL)ret;

- (void)configureTextField:(NSString *) place color:(UIColor *) col returnHidesKB:(BOOL)ret movesLeft:(BOOL) moveLeft;

- (void)configureTextField:(NSString *) place color:(UIColor *) col returnHidesKB:(BOOL)ret movesLeft:(BOOL) moveLeft hideOthers:(NSArray *)arr;

@end
