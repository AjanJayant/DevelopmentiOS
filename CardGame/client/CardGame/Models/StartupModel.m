//
//  StartupModel.m
//  CardGame
//
//  Created by Ajan Jayant on 2013-08-13.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import "StartupModel.h"

@implementation StartupModel

@synthesize serverIsRunning;

-(id)init{
    self = [super init];
    
    if (self != nil)
    {
        [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self
                                                             withBlock:^(PNMessage *message) {
                                                                 
                                                                 NSString * type = [message.message objectForKey: @"type"];
                                                                 
                                                                 if([type isEqualToString: @"login"])
                                                                     [self processLoginFromServer: message.message];
                                                             }];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToServerError) name:@"serverNotRunning" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkIfNamesLoaded) name:@"serverIsRunning" object:nil];
        
        [[Globals sharedInstance] checkIfHereNow];
    }
    
    return self;
}

-(void)goToServerError{
    
    serverIsRunning = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"serverNotLoaded" object:self];
}

-(void)checkIfNamesLoaded{
    
    serverIsRunning = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"serverLoaded" object:self];
}

-(NSString*) findFirstController{
    
    if([[[Globals sharedInstance] userName] isEqualToString: @""] || [[[Globals sharedInstance] udid] isEqualToString: @""])
    {
        return @"login";
    }
    else
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        [dict setObject: [[Globals sharedInstance] userName] forKey: @"username"];
        [dict setObject: [[Globals sharedInstance] udid] forKey:@"uuid"];
        [dict setObject: @"login" forKey:@"type"];
        
        [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] serverChannel]];
                
        return @"unsure";
    }
}

-(void) processLoginFromServer:(NSDictionary *) dict{
    
    NSString * suc = [dict objectForKey: @"success"];
    
    if([suc isEqualToString: @"True"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadHomeAsInitialController" object:self];
    }
    else if([suc isEqualToString: @"False"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadLoginAsInitialController" object:self];
    }
}

@end