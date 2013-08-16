//
//  LoadModel.h
//  CardGame
//
//  Created by Ajan Jayant on 2013-08-15.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Globals.h"

@interface LoadModel : NSObject

@property NSMutableArray *
playerNames;

@property int numberOfNames;

@property BOOL shouldInvokeLoadFunctions;

@end
