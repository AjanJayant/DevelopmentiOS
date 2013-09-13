//
//  ViewController.m
//  DictionaryDemo2
//
//  Created by Ajan Jayant on 2013-09-06.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [PubNubKeyUpdate subscribeToChannelWithUpdates:self
                                    onChannel:@"Ajan"
                                      forKeys:[[NSArray alloc] initWithObjects:
                                               @"balanceLabel.text", nil]
                                      withErrorCallback:^(){
                                                NSLog(@"Sample Callback");
                                    }];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)moneyEarnedButton:(id)sender {
    float balance = [_balanceLabel.text doubleValue];
    float change = [_moneyEarnedField.text doubleValue];
    balance += change;
    _balanceLabel.text =  [NSString stringWithFormat:@"%.02f", balance];
}

- (IBAction)moneySpentButton:(id)sender {
    float balance = [_balanceLabel.text doubleValue];
    float change = [_moneySpentField.text doubleValue];
    balance -= change;
    _balanceLabel.text =  [NSString stringWithFormat:@"%.02f", balance];
}
@end