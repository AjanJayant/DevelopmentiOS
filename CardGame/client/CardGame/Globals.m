//
//  Globals.m
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

@synthesize gameChannel;


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
        self.userName = @"AJ";
        self.serverChannel = [PNChannel channelWithName:@"PokerServer" shouldObservePresence:YES];
    }
    return self;
}

-(void)setuDID: (NSString *) uid{
    udid = [NSString stringWithString: uid];; //@"73BE398D-E3AE-449B-9327-4730DE2984C8"
}

-(void)setUserName: (NSString *) str {
    userName = [NSString stringWithString: str];
}

-(void)setGameChannel: (PNChannel *) chan {
    gameChannel = chan;
}

-(void) loadVariables {
    
    NSMutableDictionary *dictionary;
    
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:@"Data.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"Data" ofType:@"plist"];
    }
    dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    
    [[Globals sharedInstance] setuDID:[dictionary objectForKey:@"udid"]];
    [[Globals sharedInstance] setUserName:[dictionary objectForKey:@"userName"]];

}

-(void) saveVariables {
    NSString *error;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"Data.plist"];
    
    NSDictionary *plistDict = [NSDictionary dictionaryWithObjects:
                               [NSArray arrayWithObjects:
                                [[Globals sharedInstance] udid],
                                [[Globals sharedInstance] userName],
                                nil]
                                                          forKeys:[NSArray arrayWithObjects: @"udid",
                                                                   @"userName",
                                                                   nil]];
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];
    //[plistData writeToFile:@"/Users/ajanjayant/Code/DevelopmentiOS/CardGame/CardGame/Data.plist"  atomically:YES];
    if(plistData) {
        [plistData writeToFile:plistPath atomically:YES];
    }
    
}


@end
