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

@synthesize serverErrModel;

@synthesize logModel;

@synthesize homeModel;

@synthesize loadModel;

@synthesize roomModel;

@synthesize appLabel;

@synthesize loginField;

@synthesize addUser;

@synthesize loginUser;

@synthesize loginProgress;

@synthesize createGameButton;

@synthesize joinPrivateGameButton;

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

@synthesize messageNotifyingUser;

/**********************************************************
 * viewDidLoad calls various functions to load initial 
 * conditions based on the title of the controller
 **********************************************************/
- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    if([[self title] isEqualToString: @"login"]){
        
        [self loadInitalLoginConditions];
    }
    else if([[self title] isEqualToString: @"home"]){
        
        [self loadInitalHomeConditions];
    }
    else if([[self title] isEqualToString: @"load"]){

        [self loadInitalLoadConditions];
    }
    else if([[self title] isEqualToString: @"room"]) {

        [self loadInitalRoomConditions];
    }
    else if([[self title] isEqualToString: @"serverError"]) {
        
        [self loadInitalServerErrorConditions];
    }
        
    [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(saveVaraiables) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkIfServerRunning) userInfo:nil repeats:YES];
}

/**********************************************************
 * didReceiveMemoryWarning should be used to release
 * unnecessary data.
 **********************************************************/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**********************************************************
 * Following start screen buttons respond to user interaction
 **********************************************************/
#pragma mark - Start screen buttons

- (IBAction)addUser:(id)sender
{
    
    [self genericLogin:@"create-user"];
}

- (IBAction)loginUser:(id)sender
{
    
    [self genericLogin:@"login"];
}

/**********************************************************
 * Following home screen buttons respond to user interaction
 **********************************************************/
#pragma mark - Home screen buttons

- (IBAction)createGameButton:(id)sender
{
    if([[Globals sharedInstance] canPlayGame] == NO){
        
        [self handleCaseWhereThereAreNoFunds];
    }
    else if([gameName.text isEqualToString:@""]) {
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Game could not be joined" message: @"Please type a game name" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
    else {
        
        [[Globals sharedInstance] setWetherIsFirstGame: YES];
        [[Globals sharedInstance] setCreator: YES];
        [self doGameSetup:@"create" game:gameName.text];
        [self enableInteraction:NO arrayOfViews:[[NSArray alloc]initWithObjects: createGameButton, gameName, joinPrivateGameButton, nil]] ;
    }
}

- (IBAction)joinPrivateGameButton:(id)sender
{
    if([[Globals sharedInstance] canPlayGame] == NO){
        
        [self handleCaseWhereThereAreNoFunds];
    }
    else if([gameName.text isEqualToString:@""]) {
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Game could not be joined" message: @"Please type a game name" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }
    else {
        
        [self doGameSetup:@"joinable" game:gameName.text];
        [self enableInteraction:NO arrayOfViews:[[NSArray alloc]initWithObjects: createGameButton, gameName, joinPrivateGameButton, nil]];
    }
}

/**********************************************************
 * Following load screen buttons respond to user interaction
 **********************************************************/

#pragma mark - Load screen buttons

- (IBAction)startButton:(id)sender
{
    
    // When start button is hit, a message is sient to the server saying that
    // the creator is ready to start the game
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    NSString * user =  [[Globals sharedInstance] userName];
    NSString * udid = [[Globals sharedInstance] udid];
    
    [dict setObject:@"start" forKey:@"type"];
    [dict setObject:udid forKey: @"uuid"];
    [dict setObject:user forKey:@"username"];
    
    [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] gameChannel]];
    
    [self enableInteraction:NO arrayOfViews:[[NSArray alloc]initWithObjects:startGameButton, nil]];
}

/**********************************************************
 * Following room screen buttons respond to user interaction
 **********************************************************/

#pragma mark- Room screen buttons

/**********************************************************
 * raiseButton checks whether the raise amount is permissible
 * it checks if the amount input is less than minimum, not a 
 * a string, or greater than bank.
 **********************************************************/
- (IBAction)raiseButton:(id)sender
{
    
    if([raiseTextField.text isEqualToString: @""]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"You must raise a value" message: @"Type a value in the field" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    int raise = [raiseTextField.text intValue];
    
    if(raise == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invalid raise amount" message: @"Please type a number" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
        return;
    }
    else if(raise < [roomModel.minRaise intValue]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invalid raise amount" message: @"The value is less than the minimum raise" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
        return;
        
    }
    else if(raise > roomModel.maxRaise) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invalid raise amount" message: @"The value is greater than the money you have" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:@"raise" forKey:@"type"];
    [dict setObject:raiseTextField.text forKey:@"amount"];
    [self setUIDAndUserName:dict];
    [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] gameChannel]];
    
    [self enableInteraction:NO arrayOfViews:[[NSArray alloc]initWithObjects: raiseTextField, raiseButton, callButton, foldButton, nil]];
    
    raiseTextField.text = @"";
}

- (IBAction)callButton:(id)sender
{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:@"call" forKey:@"type"];
    [self setUIDAndUserName:dict];
    
    [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] gameChannel]];
    
    [self enableInteraction:NO arrayOfViews:[[NSArray alloc]initWithObjects: raiseTextField, raiseButton, callButton, foldButton, nil]];

}

- (IBAction)foldButton:(id)sender
{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:@"fold" forKey:@"type"];
    [self setUIDAndUserName:dict];
    
    [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] gameChannel]];
    
    [self enableInteraction:NO arrayOfViews:[[NSArray alloc]initWithObjects: raiseTextField, raiseButton, callButton, foldButton, nil]];
    
}

/**********************************************************
 * Following functions load the inital conditons for each
 * view controller
 **********************************************************/
#pragma mark - Initial load conditions for each sepecific view controller

- (void)loadInitalLoginConditions
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToServerError) name:@"serverNotRunning" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startObservingForServerErrorsAgain" object:self];

    logModel = [[LoginModel alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToHomeFromLogin) name:@"goToHomeFromLogin" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideLoginProgress) name:@"hideLoginProgress" object:nil];
    
    
    appLabel.text = @"PubNub Poker";
    [loginField configureTextField: @"Type user name here" color:[UIColor blackColor] hideSelf:YES];
    [addUser setTitle:@"Add" forState:UIControlStateNormal];
    [loginUser setTitle:@"Login" forState:UIControlStateNormal];
    if([[[Globals sharedInstance] udid] isEqualToString: @""]) {
        
        [logModel setupUUIDIfNotPresent];
    }
    
    loginProgress.hidden = YES;
  
}

- (void)loadInitalHomeConditions
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToServerError) name:@"serverNotRunning" object:nil];
    
    homeModel = [[HomeModel alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableHomeScreenButtons) name:@"enableHomeScreenButtons" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToLoadFromHome) name:@"goToLoadFromHome" object:nil];
    
    [createGameButton setTitle: @"Create a game" forState: UIControlStateNormal];
    [joinPrivateGameButton setTitle: @"Join private" forState:
     UIControlStateNormal];
    [gameName configureTextField: @"Type game name here" color:[UIColor whiteColor]returnHidesKB:YES movesLeft:NO hideOthers:[NSArray arrayWithObjects:createGameButton, joinPrivateGameButton, nil]];

}

- (void)loadInitalLoadConditions
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToServerError) name:@"serverNotRunning" object:nil];
    
    loadModel = [[LoadModel alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabelNames) name:@"updateLabelNames" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToRoomFromLoad) name:@"goToRoomFromLoad" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToHomeFromLoad) name:@"goToHomeFromLoad" object:nil];
    
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

}

- (void)loadInitalRoomConditions
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToServerError) name:@"serverNotRunning" object:nil];
    
    roomModel = [[RoomModel alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setLabels) name:@"updateGameLabels" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFlopCards) name:@"updateFlopCards" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTurnCard) name:@"updateTurnCard" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRiverCard) name:@"updateRiverCard" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeBlind) name:@"removeBlind" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMinRaise) name:@"updateMinRaise" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableInteractionForTurn) name:@"enableInteractionForTurn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToLoadFromRoom) name:@"goToLoadFromRoom" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToHomeFromRoom) name:@"goToHomeFromRoom" object:nil];
    
    deckCardOne.hidden = YES;
    deckCard2.hidden = YES;
    deckCard3.hidden = YES;
    deckCard4.hidden = YES;
    deckCard5.hidden = YES;
    potLabel.hidden = YES;
    bankLabel.hidden = YES;
    recentBetLabel.hidden = YES;
    raiseTextField.hidden = YES;
    raiseButton.hidden = YES;
    callButton.hidden = YES;
    foldButton.hidden = YES;
    blindImage.hidden = YES;
    [raiseButton setTitle:@"Raise" forState:UIControlStateNormal];
    [callButton setTitle:@"Call" forState:UIControlStateNormal];
    [foldButton setTitle:@"Fold" forState:UIControlStateNormal];
    // Own card setup done here
    [self setCards: roomModel.card1 cardView:ownCardOneView];
    [self setCards: roomModel.card2 cardView:ownCardTwoView];
    // Blind setup done here
    if([roomModel.blind isEqualToString: @"smallblind"] || [roomModel.blind isEqualToString: @"bigblind"]){
        [self setBlind: roomModel.blind];
        roomModel.isBlind = YES;
    }
    initialBankLabel.text = roomModel.initialFunds;
    // Raise text field setup here; the array of views contains views hidden when the field is being used
    [raiseTextField configureTextField: @"Current Bet: $0" color:[UIColor blackColor] returnHidesKB: YES movesLeft:NO hideOthers:[NSArray arrayWithObjects:potLabel, ownCardOneView, ownCardTwoView, ownCardTwoView, deckCardOne, deckCard2, deckCard3, deckCard4, deckCard5, potImageView, recentBetLabel, potImageView, initialBankLabel, bankLabel, raiseButton, callButton, foldButton,  nil]];
    // No Buttons hould be allowed to interact initially
    [self enableInteraction:NO arrayOfViews:[[NSArray alloc]initWithObjects: raiseTextField, raiseButton, callButton, foldButton, nil]];

}

- (void)loadInitalServerErrorConditions
{
    
    serverErrModel = [[ServerErrorModel alloc] init];
    
    messageNotifyingUser.text = @"Server not running :( \n There seems to be a error in the space time continuum; we're doing everything we can to rectify it";

}

/**********************************************************
 * Following functions are triggered by notifications. They 
 * mainly update view controller values to ones specified by 
 * respective models
 **********************************************************/
#pragma mark - Notification-triggered functions

- (void)checkIfServerRunning
{
    
    [[Globals sharedInstance] checkIfHereNow];
}

- (void)hideLoginProgress
{
    loginProgress.hidden = YES;
}

- (void)enableHomeScreenButtons
{
    
    [self enableInteraction:YES arrayOfViews:[[NSArray alloc]initWithObjects:
                                              createGameButton,
                                              gameName,
                                              joinPrivateGameButton,
                                              foldButton,
                                              nil]];
}

- (void)enableInteractionForTurn
{
    
    [self enableInteraction:YES arrayOfViews:[[NSArray alloc]initWithObjects:
                                              raiseTextField,
                                              raiseButton,
                                              callButton,
                                              foldButton,
                                              nil]];
    
}

- (void)updateLabelNames
{
    
    switch(loadModel.numberOfNames) {
            
        case 8:
            eightNameLabel.text = loadModel.playerNames[7];
            eightNameLabel.hidden = NO;
        case 7:
            seventhNameLabel.text = loadModel.playerNames[6];
            seventhNameLabel.hidden = NO;
        case 6:
            sixthNameLabel.text = loadModel.playerNames[5];
            sixthNameLabel.hidden = NO;            
        case 5:
            fifthNameLabel.text = loadModel.playerNames[4];
            fifthNameLabel.hidden = NO;
        case 4:
            fourthNameLabel.text = loadModel.playerNames[3];
            fourthNameLabel.hidden = NO;
        case 3:
            thirdnameLabel.text = loadModel.playerNames[2];
            thirdnameLabel.hidden = NO;
        case 2:
            secondNameLabel.text = loadModel.playerNames[1];
            secondNameLabel.hidden = NO;
            if([[Globals sharedInstance] isFirstGame] == YES && [[Globals sharedInstance] isCreator] == YES) {
                [self setGameButton];
            }
        case 1:
            firstNameLabel.text = loadModel.playerNames[0];
            firstNameLabel.hidden = NO;
    }
}

- (void)updateFlopCards
{
    
    [self setCards:roomModel.communityCard1 cardView:deckCardOne];
    deckCardOne.hidden = NO;
    [self setCards:roomModel.communityCard2 cardView:deckCard2];
    deckCard2.hidden = NO;
    [self setCards:roomModel.communityCard3 cardView:deckCard3];
    deckCard3.hidden = NO;
}

- (void)updateTurnCard
{
    
    [self setCards:roomModel.communityCard4 cardView:deckCard4];
    deckCard4.hidden = NO;
}

- (void)updateRiverCard
{
    
    [self setCards:roomModel.communityCard5 cardView:deckCard5];
    deckCard5.hidden = NO;
}

- (void)updateMinRaise
{
    
    raiseTextField.placeholder = [@"Min:" stringByAppendingString: roomModel.minRaise];
}

- (void)setLabels
{
    
    potLabel.text = roomModel.pot;
    potLabel.hidden = NO;
    
    recentBetLabel.text = roomModel.lastAct;
    recentBetLabel.hidden = NO;
    
    bankLabel.text = roomModel.myFunds;
    bankLabel.hidden = NO;
    
    raiseTextField.placeholder = @"Raise here!";
    
    raiseTextField.hidden = NO;
}

- (void)removeBlind
{
    
    blindImage.hidden = YES;
    
    raiseButton.hidden = NO;
    
    callButton.hidden = NO;
    
    foldButton.hidden = NO;
}

- (void)setCards:(NSString *)card cardView:(UIImageView *)cardView
{
    
    card = [card stringByAppendingString: @".png"];
    
    [cardView setImage:[UIImage imageNamed:card]];
}

- (void)setBlind:(NSString *)img
{
    
    blindImage.hidden = NO;
    img = [img stringByAppendingString: @".png"];
    
    UIImage *image1 = [UIImage imageNamed:img];
    
    [blindImage setImage:image1];
}

- (void)saveVaraiables
{
    
    [[Globals sharedInstance] saveVariables];
}

#pragma mark - Auxilliary Functions

/**********************************************************
 * Following functions enables interaction for a set
 * of views defined by an array
 **********************************************************/
- (void)enableInteraction:(BOOL)shouldInteract arrayOfViews:(NSArray *)arrayOfViews
{
    
    for(UIView * view in arrayOfViews){
        
        [view setUserInteractionEnabled:shouldInteract];
    }
}

/**********************************************************
 * handleCaseWhereThereAreNoFunds gerates an alert, 
 * preventing the player from continuing
 **********************************************************/
- (void)handleCaseWhereThereAreNoFunds
{
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"Sorry, you don't have any funds!" message: @"Gotta reinstall the app to play again :(" delegate:self cancelButtonTitle:@"Just sayin'" otherButtonTitles: nil];
    [alert show];
}

/**********************************************************
 * genericLogin handles an add user or login button being 
 * clicked, sending a message and handling error cases 
 * (no input etc.)
 **********************************************************/
- (void)genericLogin:(NSString *)type
{
    
    [loginField resignFirstResponder];
    
    if([loginField.text isEqualToString: @""]) {
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle: @"User not logged in" message: @"User name must be specified" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
    }
    else {
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        [dict setObject:loginField.text forKey: @"username"];
        [dict setObject: [[Globals sharedInstance] udid] forKey:@"uuid"];
        [dict setObject: type forKey:@"type"];

        [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] serverChannel]];
        
        loginProgress.hidden = NO;
    }
}

/**********************************************************
 * doGameSetup handles attempts to create a game, subscribing 
 * to the game channel and setting the sharedInstance singleton 
 * variable
 **********************************************************/
- (void)doGameSetup:(NSString *)type game:(NSString *)game
{
        
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:game forKey: @"game"];
    [dict setObject:type forKey:@"type"];
    [self setUIDAndUserName:dict];
    
    [PubNub sendMessage:dict toChannel:[[Globals sharedInstance] serverChannel]];
    PNChannel * chan = [PNChannel channelWithName:gameName.text shouldObservePresence:YES];
    
    [[Globals sharedInstance] setGameChannel: chan];
}

- (void)setGameButton
{
    
    startGameButton.hidden = NO;
    startGameButton.enabled = YES;
}

/**********************************************************
 * setUIDAndUserName sets singleton variable fields
 **********************************************************/
- (void)setUIDAndUserName:(NSMutableDictionary *)dict
{
    
    [dict setObject: [[Globals sharedInstance] udid] forKey: @"uuid"];
    [dict setObject: [[Globals sharedInstance] userName] forKey: @"username"];
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger) buttonIndex
{
    if(alertView.tag == 1) {
        if(buttonIndex == 0){
            [self enableInteraction:YES arrayOfViews:[[NSArray alloc]initWithObjects: createGameButton, gameName, joinPrivateGameButton, raiseTextField, startGameButton, raiseButton, callButton, foldButton, nil]];
        }
    }
}

/**********************************************************
 * Following functions trigger segues to allow for view
 * controller transitions
 * Form: Make sure PNObservation centre functions not 
 * triggered, remove observers from self, perform segue
 **********************************************************/
#pragma mark - View Controller Navigation

- (void)goToServerError
{
    logModel.shouldInvokeLoginFunctions = NO;
    homeModel.shouldInvokeHomeFunctions = NO;
    loadModel.shouldInvokeLoadFunctions = NO;
    roomModel.shouldInvokeRoomFunctions = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"serverNotRunning" object:nil];
    [self performSegueWithIdentifier:[[self title] stringByAppendingString:@"ToServerError" ] sender:self];
}

- (void)goToHomeFromLogin
{
    
    logModel.shouldInvokeLoginFunctions = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"hideLoginProgress" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"goToHomeFromLogin" object:nil];
    [self performSegueWithIdentifier:@"loginToHome" sender:self];
}

- (void)goToLoadFromHome
{
    
    homeModel.shouldInvokeHomeFunctions = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"enableHomeScreenButtons" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"goToLoadFromHome" object:nil];
    [self performSegueWithIdentifier:@"homeToLoad" sender:self];
}

- (void)goToRoomFromLoad
{
    
    loadModel.shouldInvokeLoadFunctions = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateLabelNames" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"goToRoomFromLoad" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"goToHomeFromLoad" object:nil];
    [self performSegueWithIdentifier:@"loadToRoom" sender:self];
}

- (void)goToHomeFromLoad
{
    loadModel.shouldInvokeLoadFunctions = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateLabelNames" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"goToRoomFromLoad" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"goToHomeFromLoad" object:nil];
    [self performSegueWithIdentifier:@"loadToHome" sender:self];
}

- (void)goToHomeFromRoom
{
    
    roomModel.shouldInvokeRoomFunctions = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"removeBlind" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateMinRaise" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"enableInteractionForTurn" object:nil];
    [self performSegueWithIdentifier:@"roomToHome" sender:self];
}

- (void)goToLoadFromRoom
{

    roomModel.shouldInvokeRoomFunctions = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"removeBlind" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateMinRaise" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"enableInteractionForTurn" object:nil];
    [self performSegueWithIdentifier:@"roomToLoad" sender:self];
}

@end
