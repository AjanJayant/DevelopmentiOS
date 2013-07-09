//
//  Globals.m
//  GMv2
//
//  Created by Ajan Jayant on 2013-06-27.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import "Globals.h"

@implementation Globals

@synthesize userName;

//@synthesize userNumber;

@synthesize groups;

@synthesize selectedGroupName;

@synthesize nameDict;

@synthesize groupMess;

@synthesize nameNumber;

@synthesize namesForGroup;

+(Globals *)sharedInstance {
    static Globals *myInstance = nil;
    
    // check to see if an instance already exists
    if (nil == myInstance) {
        myInstance  = [[[self class] alloc] init];
    }
    // return the instance of this class
    return myInstance;
}

- (id)init {
    if (self = [super init]) {
        
        self.userName = [[NSString alloc] init];
//      self.userNumber = [[NSString alloc] init];
        self.groups = [[NSMutableArray alloc] init];
        self.selectedGroupName = [[NSString alloc] init];
        self.nameDict = [[NSMutableDictionary alloc] init];
        self.groupMess = [[NSMutableDictionary alloc] init];
        self.nameNumber = [[NSMutableDictionary alloc] init];
        self.namesForGroup = [[NSMutableArray alloc] init];

    }
    return self;
}

-(void)setuserName : (NSString *) str {
    userName = [NSString stringWithString: str];
}
/*
-(void)setUserNumber : (NSString *) num {
    userNumber = [NSString stringWithString: num];
}
 */

-(void)setGroups: (NSMutableArray *) arr {
    groups = [NSMutableArray arrayWithArray:arr];
}

-(void)setSelectedGroupName : (NSString *) str {
    selectedGroupName = [NSString stringWithString: str];
}

-(void)setNameDict : (NSMutableDictionary *) dict {
    nameDict = [NSMutableDictionary dictionaryWithDictionary: dict];
}

-(void)setGroupMess : (NSMutableDictionary *) dict {
    groupMess = [NSMutableDictionary dictionaryWithDictionary: dict];
}

-(void)setNameNumber : (NSMutableDictionary *) dict {
    nameNumber = [NSMutableDictionary dictionaryWithDictionary: dict];
}

-(void)setnamesForGroup: (NSMutableArray *) arr {
    namesForGroup = [NSMutableArray arrayWithArray:arr];
}

@end
