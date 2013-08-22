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

@synthesize shouldInvokeLoadFunctions;

NSString * reqUUID;

/**********************************************************
 * The init function initialises the model and adds a
 * PubNub messageObserver to it. This model will handle
 * messages of the type player-join, authrequest, 
 * authresponse, start and disband.
 * Server exceptions are also handled.
 **********************************************************/
- (id)init
{
    
    self = [super init];
    
    if (self != nil) {
        
        shouldInvokeLoadFunctions = YES;
        
        [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self
                                                             withBlock:^(PNMessage *message) {
                                                                 
                                                                 NSString * type = [message.message objectForKey: @"type"];
                                                                 if(shouldInvokeLoadFunctions == YES) {
                                                                     
                                                                     if([type isEqualToString: @"player-join"])
                                                                         [self handlePlayerJoin: message.message];
                                                                     else if([type isEqualToString: @"authrequest"])
                                                                         [self handleAuthRequest: message.message];
                                                                     else if([type isEqualToString: @"authresponse"])
                                                                         [self handleAuthResponse: message.message];
                                                                     else if([type isEqualToString: @"start"])
                                                                         [self handleStart: message.message];
                                                                     else if([type isEqualToString: @"disband"])
                                                                         [self handleDisband: message.message];
                                                                     else if([type isEqualToString:@"exception"])
                                                                         [self handleException:message.message];

                                                                 }
                                                             }];
        playerNames = [[NSMutableArray alloc]init];
        [[Globals sharedInstance] checkIfHereNow];
    }
    
    return self;
}

/**********************************************************
 * handlePlayerJoin takes a string of names, separates them 
 * based on commmas, and then posts a notification telling 
 * the view controller to update the label names. 
 **********************************************************/
- (void)handlePlayerJoin:(NSDictionary *)dict
{
    
    NSString * name = [dict objectForKey: @"usernames"];
    NSArray * list = [name componentsSeparatedByString:@","];
    
    for(id appelo in list){
        [playerNames addObject: appelo];
    }
    
    numberOfNames = [list count];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateLabelNames" object:self];
}

/**********************************************************
 * handleAuthRequest gives the game creator the option of 
 * whether or not a player should be alllowed to join the
 * game.
 **********************************************************/
- (void)handleAuthRequest:(NSDictionary *)dict
{
    
    NSString * reqName = [dict objectForKey: @"requester-name"];
    reqUUID = [dict objectForKey: @"requester-uuid"];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle: [reqName stringByAppendingString: @" wants to join!"] message: @"You can choose to allow or deny them" delegate:self cancelButtonTitle:@"Deny" otherButtonTitles:@"Allow",  nil];
    alert.tag = 3;
    [alert show];
}

/**********************************************************
 * handleAuthResponse handles whether a person was able to 
 * join the game or not. Based on the response, an alert
 * is shown.
 **********************************************************/
- (void)handleAuthResponse:(NSDictionary *)dict
{
    
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

/**********************************************************
 * handleDisband handles when only one player is left in the 
 * game. The game is discontinued, and the player exits the 
 * loading screen.
 **********************************************************/
- (void)handleDisband:(NSDictionary *)dict
{
 
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(goToHomeScreenAfterWaitingForLoadtoLoad) userInfo:nil repeats:NO];
}

/**********************************************************
 * handleStart handles when the game is started. The inital 
 * game conditions are set, and the screen transitions.
 **********************************************************/
- (void)handleStart: (NSDictionary *)dict
{
    
    NSString * suc = [dict objectForKey: @"success"];
    NSString * card1 = [dict objectForKey: @"card1"];
    NSString * card2 = [dict objectForKey: @"card2"];
    NSString * blind = [dict objectForKey: @"blind"];
    NSString * initialFunds = [dict objectForKey: @"initial-funds"];
    
    if([suc isEqualToString: @"True"]){
        
        [[Globals sharedInstance] setCard1: card1];
        [[Globals sharedInstance] setCard2: card2];
        [[Globals sharedInstance] setInitialBlind: blind];
        [[Globals sharedInstance] setInitialFunds: initialFunds];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"goToRoomFromLoad" object:self];
    }
    else if([suc isEqualToString: @"False"]){
        NSString * mess = [dict objectForKey: @"message"];
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Game did not initialise :(" message: mess delegate:self cancelButtonTitle:@"Try Again!" otherButtonTitles: nil];
        [alert show];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**********************************************************
 * handleException handles server exceptions.
 **********************************************************/
- (void)handleException:(NSDictionary *)dict
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Server Exception Occoured" message: @"Please wait while we try to recover" delegate:self cancelButtonTitle:@"Return" otherButtonTitles: nil];
    [alert show];
}

/**********************************************************
 * We execute this function after waiting for the screen to 
 * load; otherwise we get this error: Wait for viewDidAppear/
 * viewDidDisappear to know the current transition has completed
 **********************************************************/
- (void)goToHomeScreenAfterWaitingForLoadtoLoad
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goToHomeFromLoad" object:self];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"There are no players left" message: @"You will be returned to the home sceren" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
    alert.tag = 6;
    [alert show];

}

/**********************************************************
 * The following function handles input to alertViews.
 * If the user allows a player to join the game, a message 
 * is sent to the requester.
 * If he denies the request, the user gets sent back to the 
 * home screen.
 * If a user has been allowed to join the game, a message 
 * saying such is added to the server.
 **********************************************************/
- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger) buttonIndex
{
    
    if(alertView.tag == 3) {
        
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
            [[NSNotificationCenter defaultCenter] postNotificationName:@"goToHomeFromLoad" object:self];
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
