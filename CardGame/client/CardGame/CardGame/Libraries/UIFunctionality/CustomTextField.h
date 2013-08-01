//
//  CustomTextField.h
//  CardGame
//
//  Created by Ajan Jayant on 2013-07-19.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

// configureTextField is overloaded

#import <UIKit/UIKit.h>
#import "CustomTextFieldDelegate.h"

@interface CustomTextField : UITextField

@property (nonatomic) CGFloat screenWidth;

@property (nonatomic) CGFloat screenHeight;

@property (nonatomic, retain) CustomTextFieldDelegate * c;

- (void)configureTextField:(NSString *) place color:(UIColor *) col;

- (void)configureTextField: (NSString *) place color:(UIColor *) col hideSelf: (BOOL) hideSelf;

- (void)configureTextField:(NSString *) place color:(UIColor *) col moveWithKB:(BOOL) move ;

- (void)configureTextField:(NSString *) place color:(UIColor *) col returnHidesKB:(BOOL)ret movesLeft:(BOOL) moveLeft;

- (void)configureTextField:(NSString *) place color:(UIColor *) col returnHidesKB:(BOOL)ret movesLeft:(BOOL) moveLeft hideOthers:(NSArray *)arr;

- (void)configureTextField:(NSString *) place color:(UIColor *) col autoLoadKeyboard:(BOOL)autoLoad hideOthers:(NSArray *) arr;

- (void)configureTextField:(NSString *) place color:(UIColor *) col  hideOthers:(NSArray *) arr hideSelf: (BOOL) hideSelf;

- (void)configureTextField:(NSString *) place hideOthers:(NSArray *) arr setOther:(UIView *) other setText:(NSString *) text;

- (void) setOrigin:(int) x y:(int)y;

@end
