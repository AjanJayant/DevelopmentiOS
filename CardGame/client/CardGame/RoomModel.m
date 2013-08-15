//
//  RoomModel.m
//  CardGame
//
//  Created by Ajan Jayant on 2013-08-15.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import "RoomModel.h"

@implementation RoomModel

@synthesize isBlind;

@synthesize minRaise;

@synthesize card1;

@synthesize card2;

@synthesize blind;

@synthesize initialFunds;

@synthesize pot;

@synthesize currBet;

@synthesize lastAct;

@synthesize myFunds;

@synthesize communityCard1;

@synthesize communityCard2;

@synthesize communityCard3;

@synthesize communityCard4;

@synthesize communityCard5;

BOOL shouldGoToHome;

UIAlertView * endAlert;

-(id)init{
    self = [super init];
    
    if (self != nil)
    {
        [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self
                                                             withBlock:^(PNMessage *message) {
                                                                 
                                                                 NSString * type = [message.message objectForKey: @"type"];
                                                                 
                                                                 if([type isEqualToString: @"update"])
                                                                     [self handleUpdate: message.message];
                                                                 else if([type isEqualToString: @"take-turn"])
                                                                     [self handleTakeTurn: message.message];
                                                                 else if([type isEqualToString: @"end"])
                                                                     [self handleEnd: message.message];
                                                                
                                                             }];
        
        card1 = [NSString stringWithString: [[Globals sharedInstance] card1]];
        card2 = [NSString stringWithString: [[Globals sharedInstance] card2]];
        blind = [NSString stringWithString: [[Globals sharedInstance] initialBlind]];
        initialFunds = [NSString stringWithString: [[Globals sharedInstance] initialFunds]];
        isBlind = NO;
    }
    
    return self;
}


-(void) handleUpdate: (NSDictionary *) dict {
    
    pot =     [dict objectForKey: @"pot"];
    currBet = [dict objectForKey: @"current-bet"];
    lastAct = [dict objectForKey: @"last-act"];
    myFunds = [dict objectForKey: @"my-funds" ];
    NSString * comm = [dict objectForKey: @"community" ];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateGameLabels" object:self];
        
    if(![comm isEqualToString: @""]) {
        NSArray * list = [comm componentsSeparatedByString:@" "];
        
        communityCard1 = [NSString stringWithString: list[0]];
        communityCard2 = [NSString stringWithString: list[1]];
        communityCard3 = [NSString stringWithString: list[2]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFlopCards" object:self];

        if([list count] > 3) {

            communityCard4 = [NSString stringWithString: list[3]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTurnCard" object:self];

        }
        if([list count] > 4) {
            
            communityCard5 = [NSString stringWithString: list[4]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateRiverCard" object:self];
        }
    }
}

-(void) handleTakeTurn: (NSDictionary *) dict {
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Your turn playa" message: @"It's now or never" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
    [alert show];
    
    minRaise = [[NSString alloc] init];
    minRaise = [@"Min-raise:" stringByAppendingString: [dict objectForKey: @"min-raise"]];
    
    isBlind = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"removeBlind" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMinRaise" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"enableInteractionForTurn" object :self];
}

-(void) handleEnd: (NSDictionary *) dict {
    NSString * msg = [dict objectForKey: @"message"];
    
    shouldGoToHome = YES;
    endAlert = [[UIAlertView alloc] initWithTitle: msg message: @"Please choose wether to continue or weather to exit" delegate:self cancelButtonTitle:@"Exit" otherButtonTitles:@"Continue", nil];
    endAlert.tag = 6;
    [endAlert show];
    
    [NSTimer scheduledTimerWithTimeInterval:15.0
                                     target:self
                                   selector:@selector(goToHome)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger) buttonIndex
{

    if(alertView.tag == 6) {
        if(buttonIndex == 0){
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            [dict setObject:[[Globals sharedInstance] udid] forKey: @"uuid"];
            [dict setObject:[[Globals sharedInstance] userName] forKey: @"username"];
            [dict setObject:@"play-again" forKey:@"type"];
            [dict setObject:@"false" forKey:@"yes"];
            [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] gameChannel]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"goToHome" object:self];
        }
        else if(buttonIndex == 1) {
            
            shouldGoToHome = NO;
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            [dict setObject:[[Globals sharedInstance] udid] forKey: @"uuid"];
            [dict setObject:[[Globals sharedInstance] userName] forKey: @"username"];
            [dict setObject:@"play-again" forKey:@"type"];
            [dict setObject:@"true" forKey:@"yes"];
            [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] gameChannel]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"goToLoad" object:self];
            
        }
    }
}

-(void) goToHome {
    if(shouldGoToHome)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"goToHome" object:self];
}

@end
