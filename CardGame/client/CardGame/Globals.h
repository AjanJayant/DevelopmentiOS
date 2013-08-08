//
//  Globals.h
//  CardGame
//
//  Created by Ajan Jayant on 2013-07-17.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Globals : NSObject

@property (strong, nonatomic) NSString * udid;

@property (strong, nonatomic) PNChannel * serverChannel;

@property (strong, nonatomic) PNChannel * gameChannel;

@property (strong, nonatomic) NSString * userName;

+ (Globals *)sharedInstance;

-(void)setuDID: (NSString *) str;

-(void)setUserName: (NSString *) str;

-(void)setGameChannel: (PNChannel *) chan;

-(void) saveVariables;

-(void) loadVariables;

@end
