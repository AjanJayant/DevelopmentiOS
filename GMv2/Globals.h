//
//  Globals.h
//  GMv2
//
//  Created by Ajan Jayant on 2013-06-27.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Globals : NSObject

// Global variables here

@property (strong, nonatomic) NSString * userName;

@property (strong, nonatomic) NSString * userNumber;

@property (strong, nonatomic) NSMutableArray * groups;

@property (strong, nonatomic) NSString * selectedGroupName;

@property (strong, nonatomic) NSMutableDictionary * nameDict;

@property (strong, nonatomic) NSMutableDictionary * groupMess;

@property (strong, nonatomic) NSMutableDictionary * nameNumber;

@property (strong, nonatomic) NSMutableArray * namesForGroup;
;

@property (strong, nonatomic) NSDictionary * isoToCountry;

+ (Globals *)sharedInstance;

// Setters follow

-(void)setUserName : (NSString *) str;

-(void)setUserNumber : (NSString *) num;

-(void)setGroups : (NSMutableArray *) str;

-(void)setSelectedGroupName : (NSString *) str;

-(void)setNameDict : (NSMutableDictionary *) dict;

-(void)setGroupMess : (NSMutableDictionary *) dict;

-(void)setNameNumber : (NSMutableDictionary *) dict;

-(void)setIsoToCountry : (NSDictionary *) dict;

-(void)setNamesForGroup : (NSMutableArray *) arr;

// Save all the preeceding variables

-(void) saveVariables;

@end
