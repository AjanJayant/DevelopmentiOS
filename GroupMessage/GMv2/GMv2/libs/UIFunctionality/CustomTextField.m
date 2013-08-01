//
//  CustomTextField.m
//  CardGame
//
//  Created by Ajan Jayant on 2013-07-19.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

@synthesize screenWidth;

@synthesize screenHeight;

BOOL shouldHide;

BOOL setLeft;

NSArray  * otherViews;

int originX;

int originY;

// Init function

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
    }
    return self;
}

// Basic configure
- (void)configureTextField: (NSString *) place color:(UIColor *) col
{
    [self setProperties: place color: col];
}

// Configure with options
- (void)configureTextField: (NSString *) place color:(UIColor *) col moveWithKB:(BOOL) move returnHidesKB:(BOOL)ret
{
    [self configureTextField: place color:col];
    
    if(move)
        [self setObservers];
    
    if(ret)
        [self resignFirstResponder];
}

// Configure and set left
- (void)configureTextField:(NSString *) place color:(UIColor *) col returnHidesKB:(BOOL)ret movesLeft:(BOOL) moveLeft {
    [self configureTextField: place color:col moveWithKB: YES returnHidesKB: ret];
    setLeft = moveLeft;
}

- (void)configureTextField:(NSString *) place color:(UIColor *) col  returnHidesKB:(BOOL)ret movesLeft:(BOOL) moveLeft hideOthers:(NSArray *)arr {
    [self configureTextField: place color:col returnHidesKB: ret movesLeft: moveLeft];
    otherViews = arr;
    shouldHide = true;
}


#pragma mark - Private Functions
// Functions not visible to usre; hidding implementation details


//Set properties
-(void) setProperties: (NSString *) place color:(UIColor *) col {
    self.delegate = self;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.screenWidth = screenRect.size.width;
    self.screenHeight = screenRect.size.height;
    
    // Set properties
    self.placeholder = [NSString stringWithString: place];
    self.textColor = col;
    
    shouldHide = false;
}

// Make field return if return is hit
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

// Set observes so that if keyboard is shown, function is triggered
-(void)setObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        // For send controller
        CGRect textRect = self.frame;
        originX = textRect.origin.x;
        originY = textRect.origin.y;
        
        textRect.origin.y = screenHeight - kbSize.height - (textRect.size.height*2);
        
        if(setLeft){
            textRect.origin.x = 0;
        }
        
        self.frame = textRect;

    }];
    
    if(shouldHide){
        for(UIView * view in otherViews) {
           view.hidden = YES;
        }
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [UIView animateWithDuration:0.2f animations:^{
        
        // For send controller
        CGRect textRect = self.frame;
        textRect.origin.y = originY;
        textRect.origin.x = originX;
        self.frame = textRect;
        
    }];
    
    if(shouldHide){
        for(UIView * view in otherViews) {
            view.hidden = NO;
        }
    }
}

@end
