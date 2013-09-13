//
//  ViewController.h
//  DictionaryDemo
//
//  Created by Ajan Jayant on 2013-08-26.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PubNubKeyUpdate.h"

@interface ViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UILabel *balanceLabel;

@property (weak, nonatomic) IBOutlet UITextField *currecyField;

- (IBAction)changeButton:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *stopUpdates;

- (IBAction)stopUpdates:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *resumeUpdates;

- (IBAction)resumeUpdates:(id)sender;

@end
