//
//  ViewController.h
//  DictionaryDemo2
//
//  Created by Ajan Jayant on 2013-09-06.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PubNubKeyUpdate.h"

@interface ViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIButton *moneyEarnedButton;

@property (weak, nonatomic) IBOutlet UIButton *moneySpentButton;

@property (weak, nonatomic) IBOutlet UITextField *moneySpentField;

@property (weak, nonatomic) IBOutlet UITextField *moneyEarnedField;

@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;

- (IBAction)moneyEarnedButton:(id)sender;

- (IBAction)moneySpentButton:(id)sender;

@end
