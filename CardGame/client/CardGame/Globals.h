//
//  Globals.h
//  CardGame
//
//  Created by Ajan Jayant on 2013-07-17.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Globals : NSObject

@property BOOL serverIsRunning;

@property (strong, nonatomic) NSString * udid;

@property (strong, nonatomic) PNChannel * serverChannel;

@property (strong, nonatomic) PNChannel * gameChannel;

@property (strong, nonatomic) NSString * userName;

@property (strong, nonatomic) NSString * card1;

@property (strong, nonatomic) NSString * card2;

@property (strong, nonatomic) NSString * initialBlind;

@property (strong, nonatomic) NSString * initialFunds;

@property BOOL isCreator;

+ (Globals *)sharedInstance;

-(void)setuDID: (NSString *) str;

-(void)setUserName: (NSString *) str;

-(void)setGameChannel: (PNChannel *) chan;

-(void) setCreator:(BOOL) flag;

-(void) saveVariables;

-(void) loadVariables;

-(void) checkIfHereNow;

@end
