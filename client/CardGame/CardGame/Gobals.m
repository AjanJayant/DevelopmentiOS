//
//  Gobals.m
//  CardGame
//
//  Created by Ajan Jayant on 2013-07-17.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import "Globals.h"

@implementation Globals

@synthesize udid;

@synthesize userName;

@synthesize serverChannel;

+(Globals *)sharedInstance {
    static Globals *myInstance = nil;
    
    // check to see if an instance already exists
    if (nil == myInstance) {
        myInstance  = [[[self class] alloc] init];
    }
    // return the instance of this class
    return myInstance;
}

-(id)init {
    if (self = [super init]) {
        
        self.udid = [[NSString alloc] init];
        self.userName = [[NSString alloc] init];
        self.serverChannel = [PNChannel channelWithName:@"PokerServer" shouldObservePresence:YES];
    }
    return self;
}

-(void)setuDID {
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    NSString * uid = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject) ;
    udid = uid;
}

-(void)setUserName: (NSString *) str {
    userName = [NSString stringWithString: str];
}

@end
