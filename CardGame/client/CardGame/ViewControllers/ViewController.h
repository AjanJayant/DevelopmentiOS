//
//  ViewController.h
//  CardGame
//
//  Created by Ajan Jayant on 2013-07-16.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"
#import "UIFunctionality.h"
#import "ServerErrorModel.h"
#import "LoginModel.h"
#import "HomeModel.h"
#import "LoadModel.h"
#import "RoomModel.h"

@class AppDelegate;

@interface ViewController : UIViewController

////////////////////////
// Pointers to models //
////////////////////////

@property ServerErrorModel *serverErrModel;

@property LoginModel *logModel;

@property HomeModel *homeModel;

@property LoadModel *loadModel;

@property RoomModel *roomModel;

////////////////////////////
// Login screen properties//
////////////////////////////

@property (weak, nonatomic) IBOutlet UILabel *appLabel;

@property (weak, nonatomic) IBOutlet CustomTextField *loginField;

@property (weak, nonatomic) IBOutlet UIButton *addUser;

@property (weak, nonatomic) IBOutlet UIButton *loginUser;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loginProgress;

- (IBAction)addUser:(id)sender;

- (IBAction)loginUser:(id)sender;

/////////////////////////
// Home room properties//
/////////////////////////

@property (weak, nonatomic) IBOutlet UIButton *createGameButton;

@property (weak, nonatomic) IBOutlet CustomTextField *gameName;

@property (weak, nonatomic) IBOutlet UIButton *joinPrivateGameButton;

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

- (IBAction)createGameButton:(id)sender;

- (IBAction)joinPrivateGameButton:(id)sender;

/////////////////////////
// Load room properties//
/////////////////////////

@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *secondNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *thirdnameLabel;

@property (weak, nonatomic) IBOutlet UILabel *fourthNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *fifthNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *sixthNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *seventhNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *eightNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *startGameButton;

- (IBAction)startButton:(id)sender;

//////////////////////////
// game room properties //
//////////////////////////

@property (weak, nonatomic) IBOutlet UIImageView *mainView;

@property (weak, nonatomic) IBOutlet UIImageView *ownCardOneView;

@property (weak, nonatomic) IBOutlet UIImageView *ownCardTwoView;

@property (weak, nonatomic) IBOutlet UIImageView *deckCardOne;

@property (weak, nonatomic) IBOutlet UIImageView *deckCard2;

@property (weak, nonatomic) IBOutlet UIImageView *deckCard3;

@property (weak, nonatomic) IBOutlet UIImageView *deckCard4;

@property (weak, nonatomic) IBOutlet UIImageView *deckCard5;

@property (weak, nonatomic) IBOutlet UIImageView *potImageView;

@property (weak, nonatomic) IBOutlet UILabel *initialBankLabel;

@property (weak, nonatomic) IBOutlet UILabel *potLabel;

@property (weak, nonatomic) IBOutlet UILabel *recentBetLabel;

@property (weak, nonatomic) IBOutlet UILabel *bankLabel;

@property (weak, nonatomic) IBOutlet CustomTextField *raiseTextField;

@property (weak, nonatomic) IBOutlet UIButton *callButton;

@property (weak, nonatomic) IBOutlet UIButton *raiseButton;

@property (weak, nonatomic) IBOutlet UIButton *foldButton;

@property (weak, nonatomic) IBOutlet UIImageView *blindImage;

- (IBAction)raiseButton:(id)sender;

- (IBAction)callButton:(id)sender;

- (IBAction)foldButton:(id)sender;

//////////////////
// Server Error //
//////////////////

@property (weak, nonatomic) IBOutlet UILabel *messageNotifyingUser;

@end
