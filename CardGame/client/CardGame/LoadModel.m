//
//  LoadModel.m
//  CardGame
//
//  Created by Ajan Jayant on 2013-08-15.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import "LoadModel.h"

@implementation LoadModel

@synthesize playerNames;

@synthesize numberOfNames;

NSString * reqUUID;

-(id)init{
    self = [super init];
    
    if (self != nil)
    {
        [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self
                                                             withBlock:^(PNMessage *message) {
                                                                 
                                                                 NSString * type = [message.message objectForKey: @"type"];
                                                                                                                                 
                                                                 if([type isEqualToString: @"player-join"])
                                                                     [self handlePlayerJoin: message.message];
                                                                 else if([type isEqualToString: @"authrequest"])
                                                                     [self handleAuthRequest: message.message];
                                                                 else if([type isEqualToString: @"authresponse"])
                                                                     [self handleAuthResponse: message.message];
                                                             }];
        playerNames = [[NSMutableArray alloc]init];
        [[Globals sharedInstance] checkIfHereNow];
    }
    
    return self;
}

-(void) handlePlayerJoin: (NSDictionary *) dict {
    
    NSString * name = [dict objectForKey: @"usernames"];
    NSArray * list = [name componentsSeparatedByString:@","];
    
    for(id appelo in list){
        [playerNames addObject: appelo];
    }
    
    numberOfNames = [list count];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateLabelNames" object:self];
}

-(void) handleAuthRequest: (NSDictionary *) dict {
    
    NSString * reqName = [dict objectForKey: @"requester-name"];
    reqUUID = [dict objectForKey: @"requester-uuid"];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle: [reqName stringByAppendingString: @" wants to join!"] message: @"You can choose to allow or deny them" delegate:self cancelButtonTitle:@"Deny" otherButtonTitles:@"Allow",  nil];
    alert.tag = 3;
    [alert show];
}

-(void) handleAuthResponse: (NSDictionary *) dict {
    
    NSString * auth = [dict objectForKey: @"auth"];
    NSString * creat = [dict objectForKey: @"creator"];
    
    UIAlertView * alert;
    if([auth isEqualToString: @"deny"]) {
        alert = [[UIAlertView alloc] initWithTitle: [creat stringByAppendingString: @" has denied you access"] message: @"Click below to escape" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        alert.tag = 4;
        
    }
    else if([auth isEqualToString: @"allow"]) {
        alert = [[UIAlertView alloc] initWithTitle: @"You succesfully joined!" message: @"Your game will start shortly"delegate:self cancelButtonTitle:@"Awesome!" otherButtonTitles: nil];
        alert.tag = 5;
    }
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger) buttonIndex
{
    if(alertView.tag == 1) {
        if(buttonIndex == 0){
            /*
            [homeViewController enableInteraction:YES arrayOfViews:[[NSArray alloc]initWithObjects:
                                                                    homeViewController.gameName,
                                                                    homeViewController.joinPrivateGameButton,
                                                                    homeViewController.createGameButton,
                                                                    nil]];
            
            */
            return;
        }
    }
    else if(alertView.tag == 2) {
        if(buttonIndex == 0){
            return;
        }
    }
    else if(alertView.tag == 3) {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setObject:@"" forKey: @"game"];
        [dict setObject:[[Globals sharedInstance] userName] forKey: @"creator"];
        [dict setObject:@"authresponse" forKey:@"type"];
        
        if(buttonIndex == 0){
            [dict setObject:@"deny" forKey:@"auth"];
        }
        else if(buttonIndex == 1){
            [dict setObject:@"allow" forKey:@"auth"];
        }
        [PubNub sendMessage:dict toChannel:[PNChannel channelWithName: reqUUID shouldObservePresence:YES]];
        
    }
    else if(alertView.tag == 4) {
        if(buttonIndex == 0){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"goToHome" object:self];
        }
    }
    else if(alertView.tag == 5) {
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        [dict setObject:[[Globals sharedInstance] udid] forKey: @"uuid"];
        [dict setObject:[[Globals sharedInstance] userName] forKey: @"username"];
        [dict setObject:@"join" forKey:@"type"];
        [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] gameChannel]];
        
    }
}

@end
