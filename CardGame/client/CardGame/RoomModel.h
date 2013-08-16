//
//  RoomModel.h
//  CardGame
//
//  Created by Ajan Jayant on 2013-08-15.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Globals.h"

@interface RoomModel : NSObject

@property (strong, nonatomic) NSString * card1;

@property (strong, nonatomic) NSString * card2;

@property (strong, nonatomic) NSString * blind;

@property (strong, nonatomic) NSString * initialFunds;

@property (strong, nonatomic) NSString * pot;

@property (strong, nonatomic) NSString *currBet;

@property (strong, nonatomic) NSString * lastAct;

@property (strong, nonatomic) NSString * myFunds;

@property (strong, nonatomic) NSString * communityCard1;

@property (strong, nonatomic) NSString * communityCard2;

@property (strong, nonatomic) NSString * communityCard3;

@property (strong, nonatomic) NSString * communityCard4;

@property (strong, nonatomic) NSString * communityCard5;

@property BOOL isBlind;

@property (strong, nonatomic) NSString * minRaise;

@property int maxRaise;

@property BOOL shouldInvokeRoomFunctions;

@end
