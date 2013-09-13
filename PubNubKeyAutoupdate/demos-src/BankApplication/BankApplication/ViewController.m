//
//  ViewController.m
//  DictionaryDemo
//
//  Created by Ajan Jayant on 2013-08-26.
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
    [self setAllPredeterminedString];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Auxilliary functions

- (void)setAllPredeterminedString
{
    _currecyField.placeholder = @"Type rate here...";
    _balanceLabel.text = @"0.00";
    
    [PubNubKeyUpdate subscribeToChannelWithUpdates:self
                                         onChannel:@"Ajan"
                                           forKeys:[[NSArray alloc] initWithObjects:
                                                    @"balanceLabel.text", nil]
                                 withErrorCallback:^(){
                                     NSLog(@"Sample Callback");
                                 }];
}

- (IBAction)changeButton:(id)sender {
    float rate = [_currecyField.text doubleValue];
    float amount = [_balanceLabel.text doubleValue];
    amount += rate*amount/100;
    _balanceLabel.text =  [NSString stringWithFormat:@"%.02f", amount];
    _currecyField.text = @"";
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)stopUpdates:(id)sender {
  [PubNubKeyUpdate unsubscribeFromChannelWithUpdates:@"Ajan"];
}

- (IBAction)resumeUpdates:(id)sender {
    [PubNubKeyUpdate subscribeToChannelWithUpdates:self
                                         onChannel:@"Ajan"
                                           forKeys:[[NSArray alloc] initWithObjects:
                                                    @"balanceLabel.text", nil]
                                 withErrorCallback:^(){
                                     NSLog(@"Sample Callback");
                                 }];

}

@end