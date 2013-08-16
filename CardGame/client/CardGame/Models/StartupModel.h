//
//  StartupModel.h
//  CardGame
//
//  Created by Ajan Jayant on 2013-08-13.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Globals.h"

@interface StartupModel : NSObject

@property BOOL serverIsRunning;

-(NSString*) findFirstController;

@end
