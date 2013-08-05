//
//  ViewController.m
//  CardGame
//
//  Created by Ajan Jayant on 2013-07-16.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import "ViewController.h"
#import "CustomCell.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize appLabel;

@synthesize loginField;

@synthesize addUser;

@synthesize loginUser;

@synthesize loginProgress;

@synthesize createGameButton;

@synthesize joinPrivateGameButton;

@synthesize joinPublicGameButton;

@synthesize settings;

@synthesize gameName;

@synthesize bgImageView;

@synthesize firstNameLabel;

@synthesize secondNameLabel;

@synthesize thirdnameLabel;

@synthesize fourthNameLabel;

@synthesize fifthNameLabel;

@synthesize sixthNameLabel;

@synthesize seventhNameLabel;

@synthesize eightNameLabel;

@synthesize startGameButton;

@synthesize mainView;

@synthesize ownCardTwoView;

@synthesize ownCardOneView;

@synthesize deckCardOne;

@synthesize deckCard2;

@synthesize deckCard3;

@synthesize deckCard4;

@synthesize deckCard5;

@synthesize potImageView;

@synthesize potLabel;

@synthesize initialBankLabel;

@synthesize recentBetLabel;

@synthesize bankLabel;

@synthesize raiseTextField;

@synthesize raiseButton;

@synthesize callButton;

@synthesize foldButton;

@synthesize blindImage;

@synthesize isBlind;

@synthesize minRaise;

BOOL isCreator;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    isCreator = NO;
    
    // Setup for login screen
    if([[self title] isEqualToString: @"login"]){
        appLabel.text = @"PubNubPoker";
        [loginField configureTextField: @"Type user name here" color:[UIColor blackColor] hideSelf:YES];
        [addUser setTitle:@"Add" forState:UIControlStateNormal];
        [loginUser setTitle:@"Login" forState:UIControlStateNormal];
        if([[[Globals sharedInstance] udid] isEqualToString: @""]) {
            CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
            NSString * uid = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject) ;
            [[Globals sharedInstance] setuDID: uid];
        }
        
        [PubNub setClientIdentifier: [[Globals sharedInstance] udid]];
        PNChannel *channel_self = [PNChannel channelWithName: [[Globals sharedInstance] udid]];
        [PubNub subscribeOnChannel: channel_self];
        loginProgress.hidden = YES;
    }
    // Setup for home screen
    // Setup for button
    else if([[self title] isEqualToString: @"home"]){
        [createGameButton setTitle: @"Create a game" forState: UIControlStateNormal];
        [joinPrivateGameButton setTitle: @"Join private" forState:
         UIControlStateNormal];
        [joinPublicGameButton setTitle: @"Join public" forState:
         UIControlStateNormal];
        [settings setTitle: @"Settings" forState:
         UIControlStateNormal];
    
        [gameName configureTextField: @"Type game name here" color:[UIColor whiteColor]returnHidesKB:YES movesLeft:NO hideOthers:[NSArray arrayWithObjects:createGameButton, joinPrivateGameButton, joinPublicGameButton, settings, nil]];
    }
    // Make all labels hidden
    else if([[self title] isEqualToString: @"load"]){

        firstNameLabel.hidden = YES;
        secondNameLabel.hidden = YES;
        thirdnameLabel.hidden = YES;
        fourthNameLabel.hidden = YES;;
        fifthNameLabel.hidden = YES;
        sixthNameLabel.hidden = YES;
        seventhNameLabel.hidden = YES;
        eightNameLabel.hidden = YES;
        startGameButton.hidden = YES;
        [startGameButton setTitle:@"Start!" forState:UIControlStateNormal];
        
        if(isCreator)
            [self setGameButton];
    }
    // For game setup
    else if([[self title] isEqualToString: @"room"]) {
        
        deckCardOne.hidden = YES;
        deckCard2.hidden = YES;
        deckCard3.hidden = YES;
        deckCard4.hidden = YES;
        deckCard5.hidden = YES;
        potLabel.hidden = YES;
        initialBankLabel.hidden = YES;
        bankLabel.hidden = YES;
        recentBetLabel.hidden = YES;
        raiseTextField.hidden = YES;
        raiseButton.hidden = YES;
        callButton.hidden = YES;
        foldButton.hidden = YES;
        blindImage.hidden = YES;
        
        [raiseButton setTitle:@"Raise" forState:UIControlStateNormal];
        [callButton setTitle:@"Call" forState:UIControlStateNormal];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(saveVaraiables) userInfo:nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeBlind:) name:@"removeBlind" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Start screen buttons

- (IBAction)createGameButton:(id)sender {
    
    if([gameName.text isEqualToString:@""]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Game could not be joined" message: @"Please type a game name" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
    else
        [self doGameSetup:@"create" game:gameName.text];
    isCreator = YES;
}

- (IBAction)addUser:(id)sender {
    [self checkIfHereNow];

    [self genericLogin:@"create-user"];
}

- (IBAction)loginUser:(id)sender {
    
    [self checkIfHereNow];
    
    [self genericLogin:@"login"];
}

#pragma mark - Home screen buttons

- (IBAction)joinPrivateGameButton:(id)sender {
    
    if([gameName.text isEqualToString:@""]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Game could not be joined" message: @"Please type a game name" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
    else
        [self doGameSetup:@"joinable" game:gameName.text];
}

- (IBAction)joinPublicGameButton:(id)sender {
    [self doGameSetup:@"join" game:@"public"];
}

- (IBAction)settings:(id)sender {
}


#pragma mark - Load screen buttons

- (IBAction)startButton:(id)sender {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    NSString * user =  [[Globals sharedInstance] userName];
    NSString * udid = [[Globals sharedInstance] udid];
    
    [dict setObject:@"start" forKey:@"type"];
    [dict setObject:udid forKey: @"uuid"];
    [dict setObject:user forKey:@"username"];
    
    [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] gameChannel]];

}

#pragma Mark- room Buttons


- (IBAction)raiseButton:(id)sender {
    
    if([raiseTextField.text isEqualToString: @""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"You must raise a value" message: @"Type a value in the field" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:@"raise" forKey:@"type"];
    
    [dict setObject:raiseTextField.text forKey:@"amount"];
    
    [self setUIDAndUserName:dict];
    
    [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] gameChannel]];
    
    [self enableInteraction:NO];
    
    raiseTextField.text = @"";
}

- (IBAction)callButton:(id)sender {
}

- (IBAction)foldButton:(id)sender {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:@"call" forKey:@"type"];
    
    [dict setObject:raiseTextField.text  forKey:@"amount"];
    
    [self setUIDAndUserName:dict];
    
    [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] gameChannel]];
    
    [self enableInteraction:NO];
}


// Helper Funtions
#pragma mark - Auxilliary Functions

-(void) enableInteraction:(BOOL) shouldInteract{
    [raiseTextField setUserInteractionEnabled:shouldInteract];
    [raiseButton setUserInteractionEnabled:shouldInteract];
    [callButton setUserInteractionEnabled:shouldInteract];
    [foldButton setUserInteractionEnabled:shouldInteract];
}

-(void) genericLogin:(NSString *) type {
    [loginField resignFirstResponder];
    
    if([loginField.text isEqualToString: @""]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"User not logged in" message: @"User name must be specified" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
    }
    else{
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        [dict setObject:loginField.text forKey: @"username"];
        [dict setObject: [[Globals sharedInstance] udid] forKey:@"uuid"];
        [dict setObject: type forKey:@"type"];
        
        [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] serverChannel]];
        loginProgress.hidden = NO;
    }
}

-(void) doGameSetup:(NSString *)type game:(NSString * ) game{
    
    NSString * user =  [[Globals sharedInstance] userName];
    NSString * udid = [[Globals sharedInstance] udid];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:game forKey: @"game"];
    [dict setObject:udid forKey: @"uuid"];
    [dict setObject:user forKey: @"username"];
    [dict setObject:type forKey:@"type"];
    
    [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] serverChannel]];
    PNChannel * chan = [PNChannel channelWithName:gameName.text shouldObservePresence:YES];
    
    [[Globals sharedInstance] setGameChannel: chan];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    // change background here
    if(UIInterfaceOrientationIsPortrait(fromInterfaceOrientation))
    {
        bgImageView.image = [UIImage imageNamed:@"awesome_poker3.png"];
    }
    else
        bgImageView.image = [UIImage imageNamed:@"awesome_poker2.png"];
}

-(void) setCards :(NSString *) card cardView:(UIImageView *) cardView{
    
    card = [card stringByAppendingString: @".png"];
        
    [cardView setImage:[UIImage imageNamed:card]];
    
}

-(void) setInitialFunds:(NSString *) initialFunds {
    initialBankLabel.hidden = NO;
    initialBankLabel.text = initialFunds;
}

-(void) setBlind: (NSString *) img {
    blindImage.hidden = NO;
    img = [img stringByAppendingString: @".png"];
    
    UIImage *image1 = [UIImage imageNamed:img];
    
    [blindImage setImage:image1];
    
}

-(void) setGameButton {
    startGameButton.hidden = NO;
}

-(void) saveVaraiables {
    [[Globals sharedInstance] saveVariables];
}


- (void)setLabels:pot lastAct:(NSString *) lastAct myFunds:(NSString *)myFunds  currentBet:(NSString *)currentBet
{
    potLabel.text = pot;
    potLabel.hidden = NO;
    
    recentBetLabel.text = lastAct;
    recentBetLabel.hidden = NO;
    
    bankLabel.text = myFunds;
    bankLabel.hidden = NO;
    
    [raiseTextField configureTextField: [@"Curent bet: " stringByAppendingString: currentBet] color:[UIColor blackColor] returnHidesKB: YES movesLeft:NO hideOthers:[NSArray arrayWithObjects:ownCardOneView, ownCardTwoView, ownCardTwoView, deckCardOne, deckCard2, deckCard3, deckCard4, deckCard5, potImageView, recentBetLabel, potImageView, initialBankLabel, bankLabel, raiseButton, callButton, foldButton,  nil]];
    
    raiseTextField.hidden = NO;
    
}

- (void)removeBlind {
    blindImage.hidden = YES;
    
    raiseButton.hidden = NO;
    
    callButton.hidden = NO;

    foldButton.hidden = NO;
    
    [foldButton setTitle:@"Fold" forState:UIControlStateNormal];
}

        

-(void) checkIfHereNow{
    [PubNub requestParticipantsListForChannel:[[Globals sharedInstance] serverChannel]withCompletionBlock:^(NSArray *udids,
                                                                                                            PNChannel *channel,
                                                                                                            PNError *error) {
        if (error == nil) {
            
            if([udids count] == 0) {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Server not running :(" message: @"There seems to be a error in the space time continuum" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                [alert show];
                loginProgress.hidden = YES;
            }
        }
        else {  
            
            // Handle participants request error  
        }  
    }];;
}

-(void) setUIDAndUserName:(NSMutableDictionary *) dict {
    [dict setObject: [[Globals sharedInstance] udid] forKey: @"uuid"];
    [dict setObject: [[Globals sharedInstance] userName] forKey: @"username"];
}
@end
