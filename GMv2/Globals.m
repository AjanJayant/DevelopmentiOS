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

@synthesize userNumber;

@synthesize groups;

@synthesize selectedGroupName;

@synthesize nameDict;

@synthesize groupMess;

@synthesize nameNumber;

@synthesize namesForGroup;

@synthesize isoToCountry;

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
        self.userNumber = [[NSString alloc] init];
        self.groups = [[NSMutableArray alloc] init];
        self.selectedGroupName = [[NSString alloc] init];
        self.nameDict = [[NSMutableDictionary alloc] init];
        self.groupMess = [[NSMutableDictionary alloc] init];
        self.nameNumber = [[NSMutableDictionary alloc] init];
        self.namesForGroup = [[NSMutableArray alloc] init];
        self.isoToCountry = [[NSDictionary alloc] init];
    }
    return self;
}

-(void)setuserName : (NSString *) str {
    userName = [NSString stringWithString: str];
}

-(void)setUserNumber : (NSString *) num {
    userNumber = [NSString stringWithString: num];
}

-(void)setGroups: (NSMutableArray *) arr {
    groups = [NSMutableArray arrayWithArray:arr];
}

-(void)setSelectedGroupName : (NSString *) str {
    selectedGroupName = [NSString stringWithString: str];
}

-(void)setIsoToCountry : (NSDictionary *) dict {
    isoToCountry = [NSDictionary dictionaryWithDictionary: dict];
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

-(void) saveVariables {
    NSString *error;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"Data.plist"];

    NSDictionary *plistDict = [NSDictionary dictionaryWithObjects:
                               [NSArray arrayWithObjects:
                                [[Globals sharedInstance] userName],
                                [[Globals sharedInstance] userNumber],
                                [[Globals sharedInstance] groups],
                                [[Globals sharedInstance] selectedGroupName],
                                [[Globals sharedInstance] nameDict],
                                [[Globals sharedInstance] groupMess],
                                [[Globals sharedInstance] namesForGroup],
                                [[Globals sharedInstance] nameNumber],
                                [[Globals sharedInstance] isoToCountry],
                                nil]
                                                          forKeys:[NSArray arrayWithObjects: @"userName",
                                                                   @"userNumber",
                                                                   @"groups",
                                                                   @"selectedGroupName",
                                                                   @"nameDict",
                                                                   @"groupMess",
                                                                   @"namesForGroup",
                                                                   @"nameNumber",
                                                                   @"isoToCountry",
                                                                   nil]];
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];
    //[plistData writeToFile:@"/Users/ajanjayant/Code/DevelopmentiOS/GMv2/GMv2/Data.plist"  atomically:YES];
    if(plistData) {
        [plistData writeToFile:plistPath atomically:YES];
    }

}

@end
