//
//  ViewController.h
//  CardGame
//
//  Created by Ajan Jayant on 2013-07-16.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"
#import "UIFunctionality.h"

@interface ViewController : UIViewController <UITextFieldDelegate>

// For intial screen where we create a join game
@property (weak, nonatomic) IBOutlet UIButton *createGameButton;

@property (weak, nonatomic) IBOutlet UIButton *joinGameButton;

@property (weak, nonatomic) IBOutlet CustomTextField *gameName;

- (IBAction)createGameButton:(id)sender;

- (IBAction)joinGameButton:(id)sender;

@end
