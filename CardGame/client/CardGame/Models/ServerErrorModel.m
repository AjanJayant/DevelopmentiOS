//
//  ServerErrorModel.m
//  CardGame
//
//  Created by Ajan Jayant on 2013-08-13.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import "ServerErrorModel.h"

@implementation ServerErrorModel

@synthesize autoTimer;

/**********************************************************
 * The init function initialises the model and adds a
 * initialises an autotimer. This timer checks every 3 seconds, 
 * if the server is reconnected.
 **********************************************************/
-(id)init
{
    self = [super init];
    
    if (self != nil) {
        autoTimer = [NSTimer scheduledTimerWithTimeInterval:(3.0)
                                                     target:self
                                                   selector:@selector(checkIfServerRunning)
                                                   userInfo:nil
                                                    repeats:YES];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupWhenServerHasStarted) name:@"serverIsRunning" object:nil];
    
    return self;
}

/**********************************************************
 * checkIfServerRunning checks if the server is runninf by 
 * calling th function defined in Globals.
 **********************************************************/
-(void)checkIfServerRunning
{
    
    if([[Globals sharedInstance] serverIsRunning] == NO){
        [[Globals sharedInstance] checkIfHereNow];
    }
}

/**********************************************************
 * setupWhenServerHasStarted invalidates the autoTimer when
 * the server restarts. It also removes the observers.
 **********************************************************/
-(void) setupWhenServerHasStarted
{
    
    [autoTimer invalidate];
    autoTimer = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"serverRestarted" object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"serverIsRunning" object:nil];

}

@end
