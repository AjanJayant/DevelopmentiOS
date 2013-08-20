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

@synthesize maxRaise;

@synthesize shouldInvokeRoomFunctions;

BOOL shouldGoToHome;

UIAlertView * endAlert;

/**********************************************************
 * The init function initialises the model and adds a
 * PubNub messageObserver to it. This model will handle
 * messages of the type update, take-turn and end.
 * Server exceptions are also handled.
 * Inital conditons are also set.
 **********************************************************/
-(id)init
{
    self = [super init];
    
    if (self != nil) {
        shouldInvokeRoomFunctions = YES;
        [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self
                                                             withBlock:^(PNMessage *message) {
                                                                 
                                                                 NSString * type = [message.message objectForKey: @"type"];
                                                                 
                                                                 if(shouldInvokeRoomFunctions == YES) {
                                                                     if([type isEqualToString:  @"update"])
                                                                         [self handleUpdate: message.message];
                                                                     else if([type isEqualToString: @"take-turn"])
                                                                         [self handleTakeTurn: message.message];
                                                                     else if([type isEqualToString: @"end"])
                                                                         [self handleEnd: message.message];
                                                                 }
                                                             }];
        
        card1 = [NSString stringWithString: [[Globals sharedInstance] card1]];
        card2 = [NSString stringWithString: [[Globals sharedInstance] card2]];
        blind = [NSString stringWithString: [[Globals sharedInstance] initialBlind]];
        initialFunds = [NSString stringWithString: [[Globals sharedInstance] initialFunds]];
        isBlind = NO;
    }
    
    return self;
}

/**********************************************************
 * handleUpdate updates the pot, currrent bet, last act, your 
 * own funds maximum raise possible and community cards.
 **********************************************************/
-(void) handleUpdate: (NSDictionary *) dict
{
    
    pot =     [dict objectForKey: @"pot"];
    currBet = [dict objectForKey: @"current-bet"];
    lastAct = [dict objectForKey: @"last-act"];
    myFunds = [dict objectForKey: @"my-funds" ];
    maxRaise = [[myFunds substringWithRange:NSMakeRange(1, [myFunds length] - 1)] intValue];
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

/**********************************************************
 * handleTakeTurn allows the user to take a turn,
 * enabling user buttons through notifications
 **********************************************************/
-(void) handleTakeTurn: (NSDictionary *) dict
{
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Your turn playa" message: @"It's now or never" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
    [alert show];
    
    minRaise = [[NSString alloc] init];
    minRaise = [dict objectForKey: @"min-raise"];
    
    isBlind = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"removeBlind" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMinRaise" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"enableInteractionForTurn" object :self];
}

/**********************************************************
 * handleEnd tells the user who has one the game. It gives 
 * the user the option to join another game. if the user 
 * doesn't respond in 15 seconds, it automatically forces the 
 * user to quit the game.
 **********************************************************/
-(void) handleEnd: (NSDictionary *) dict
{
    
    NSString * msg = [dict objectForKey: @"message"];
    
    shouldGoToHome = YES;
    endAlert = [[UIAlertView alloc] initWithTitle: msg message: @"Please choose whether to continue or exit within 15 sec" delegate:self cancelButtonTitle:@"Exit" otherButtonTitles:@"Continue", nil];
    endAlert.tag = 6;
    [endAlert show];
    
    [NSTimer scheduledTimerWithTimeInterval:15.0
                                     target:self
                                   selector:@selector(goToHome)
                                   userInfo:nil
                                    repeats:NO];
}

/**********************************************************
 * handleException handles server exceptions.
 **********************************************************/
-(void) handleException: (NSDictionary *) dict
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Server Exception Occoured" message: @"Please wait while we try to recover" delegate:self cancelButtonTitle:@"Return" otherButtonTitles: nil];
    [alert show];
}

/**********************************************************
 * The following function handles input to alertViews.
 * If the user wants to play another game, or not,
 * it sends a message saying this to the server. The screen then 
 * transitions either to the home screen or to the load screen.
 **********************************************************/
- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger) buttonIndex
{

    if(alertView.tag == 6) {
        if(buttonIndex == 0){
            
            shouldGoToHome = NO;
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            [dict setObject:[[Globals sharedInstance] udid] forKey: @"uuid"];
            [dict setObject:[[Globals sharedInstance] userName] forKey: @"username"];
            [dict setObject:@"play-again" forKey:@"type"];
            [dict setObject:@"false" forKey:@"yes"];
            [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] gameChannel]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"goToHomeFromRoom" object:self];
        
        }
        else if(buttonIndex == 1) {
            
            shouldGoToHome = NO;
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            [dict setObject:[[Globals sharedInstance] udid] forKey: @"uuid"];
            [dict setObject:[[Globals sharedInstance] userName] forKey: @"username"];
            [dict setObject:@"play-again" forKey:@"type"];
            [dict setObject:@"true" forKey:@"yes"];
            [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] gameChannel]];
            [[Globals sharedInstance] setWetherIsFirstGame: NO];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"goToLoadFromRoom" object:self];
        }
    }
}

/**********************************************************
 * The following function causes the user to exit the game, 
 * sending a message to the server, and saying thus.
 **********************************************************/
-(void) goToHome
{
    if(shouldGoToHome) {
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        [dict setObject:[[Globals sharedInstance] udid] forKey: @"uuid"];
        [dict setObject:[[Globals sharedInstance] userName] forKey: @"username"];
        [dict setObject:@"play-again" forKey:@"type"];
        [dict setObject:@"false" forKey:@"yes"];
        [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] gameChannel]];
        
        // To automatically exit alert view
        [endAlert dismissWithClickedButtonIndex:0 animated:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"goToHomeFromRoom" object:self];
    }
}

@end
