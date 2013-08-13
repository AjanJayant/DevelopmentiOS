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

@synthesize c;

BOOL shouldHide;

BOOL setLeft;

BOOL hideIfEmpty;

BOOL modOther;

NSArray * otherViews;

NSString * viewString;

UIButton * modView;

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

// Maybe remove this?
/*
- (id)initWithCoder:(NSCoder *)inCoder{
    if (self = [super initWithCoder:inCoder]) {

    }
    return self;

}
 */

// Basic configure
- (void)configureTextField: (NSString *) place color:(UIColor *) col
{
    [self setProperties: place color: col];
    hideIfEmpty = NO;
    c = [[CustomTextFieldDelegate alloc] init];
    self.delegate = c;
}

- (void)configureTextField: (NSString *) place color:(UIColor *) col hideSelf: (BOOL) hideSelf
{
    [self configureTextField: place color: col];
    hideIfEmpty = hideSelf;
    
}


// Configure with options
- (void)configureTextField: (NSString *) place color:(UIColor *) col moveWithKB:(BOOL) move 
{
    [self configureTextField: place color:col];
    
    if(move)
        [self setObservers];
    
}

// Configure and set left
- (void)configureTextField:(NSString *) place color:(UIColor *) col returnHidesKB:(BOOL)ret movesLeft:(BOOL) moveLeft {
    [self configureTextField: place color:col moveWithKB: YES];
    setLeft = moveLeft;
}

// Configure and hide Others
- (void)configureTextField:(NSString *) place color:(UIColor *) col returnHidesKB:(BOOL)ret movesLeft:(BOOL) moveLeft hideOthers:(NSArray *)arr {
    [self configureTextField: place color:col returnHidesKB: ret movesLeft: moveLeft];
    otherViews = arr;
    shouldHide = true;
}

// Configure and set other to state if desired
- (void)configureTextField:(NSString *) place view:(UIButton *) view state:(NSString *) state hideOthers:(NSArray *)arr{
    [self configureTextField:place  color:[UIColor blackColor] returnHidesKB: YES movesLeft: NO];
    modOther = YES;
    viewString = [NSString stringWithString: state];
    modView = view;
}

// Configure and auto load keyboard
- (void)configureTextField:(NSString *) place color:(UIColor *) col autoLoadKeyboard:(BOOL)autoLoad  hideOthers:(NSArray *) arr{
    [self configureTextField: place color:col returnHidesKB: YES movesLeft: NO hideOthers: arr];
    if(autoLoad)
        [self becomeFirstResponder];
}

// Configure, load keyboard and hide self if empty
- (void)configureTextField:(NSString *) place color:(UIColor *) col hideOthers:(NSArray *) arr hideSelf: (BOOL) hideSelf {
    [self configureTextField: place color:col autoLoadKeyboard:YES hideOthers: arr];
    hideIfEmpty = hideSelf;
}

// Configure, setText of other object
- (void)configureTextField:(NSString *) place hideOthers:(NSArray *) arr setOther:(UIView *) other setText:(NSString *) text;
{
    [self configureTextField: place color: [UIColor blackColor] autoLoadKeyboard:YES  hideOthers: arr];
    if([other isKindOfClass:[UIButton class]]){
        UIButton * but = (UIButton *) other;
        [but setTitle:text forState:UIControlStateNormal];
    }
    else if([other isKindOfClass:[UILabel class]]){
        UILabel * lbl = (UILabel *) other;
        lbl.text= text; 
    }
}

#pragma mark - Private Functions
// Functions not visible to usre; hidding implementation details


//Set properties
-(void) setProperties: (NSString *) place color:(UIColor *) col {
    
    // Set properties
    self.placeholder = [NSString stringWithString: place];
    self.textColor = col;
    
    shouldHide = false;
    
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
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        self.screenWidth = screenRect.size.width;
        self.screenHeight = screenRect.size.height;
        
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
        
        if(setLeft){
            textRect.origin.x = originX;
        }
        
        self.frame = textRect;
        
        originX = 0;
        originY = 0;
        
    }];
    
    if(shouldHide){
        for(UIView * view in otherViews) {
            view.hidden = NO;
        }
    }
    if(hideIfEmpty)
        if([self.text isEqualToString:@""])
            self.hidden = YES;;
    if(modOther) {
        if([modView isKindOfClass:[UIButton class]]) {
            [modView setTitle:viewString forState:UIControlStateNormal];
         }
    }
}

- (void) setOrigin:(int) x y:(int)y {
    CGRect textRect = self.frame;
    textRect.origin.y = y;
    textRect.origin.x = x;

}

- (void) drawPlaceholderInRect:(CGRect)rect {
    [[UIColor darkGrayColor] setFill];
    [[self placeholder] drawInRect:rect withFont:[UIFont systemFontOfSize:16]];
}

@end
