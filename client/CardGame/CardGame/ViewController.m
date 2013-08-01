//
//  ViewController.m
//  CardGame
//
//  Created by Ajan Jayant on 2013-07-16.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize createGameButton;

@synthesize joinGameButton;

@synthesize gameName;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Delegate and data source
        
    [gameName configureTextField: @"Type game name here" color:[UIColor whiteColor] returnHidesKB:YES movesLeft:NO hideOthers:[NSArray arrayWithObjects:createGameButton, joinGameButton, nil]];

    // Setup for buttons
    [createGameButton setTitle: @"Create" forState: UIControlStateNormal];
    [joinGameButton setTitle: @"Join" forState: UIControlStateNormal];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createGameButton:(id)sender {
    
    NSString * game = gameName.text;
    
    if([game isEqualToString:@""]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Game could not be joined" message: @"Please type a game name" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
    else{
        [self doGameSetup: game type:@"create"];
        [self performSegueWithIdentifier:@"chooseToLoad" sender:self];
    }
}

- (IBAction)joinGameButton:(id)sender {

    [[Globals sharedInstance] setUserName: @"AjanJ"];
    
    [self doGameSetup: @"public" type:@"join"];
}

-(void) doGameSetup:(NSString *)game type:(NSString *)type {
    NSString * user = [[Globals sharedInstance] userName];
    NSString * udid = [[Globals sharedInstance] udid];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:game forKey: @"game"];
    [dict setObject:udid forKey: @"uuid"];
    [dict setObject:user forKey: @"user-name"];
    [dict setObject:type forKey:@"type"];
    
    [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] serverChannel]];

}


@end
