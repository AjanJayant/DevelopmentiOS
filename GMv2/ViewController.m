//
//  ViewController.m
//  GMv2
//
//  Created by Ajan Jayant on 2013-06-27.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

// tell compiler to create setters and getters for add user name controller

@synthesize addUsernameButton;

@synthesize adduserNameLabel;

@synthesize addUsernameField;

@synthesize addUserNumberField;

// Tells compiler to create setter and getter for send controller

@synthesize sendNavBar;

@synthesize backButton;

@synthesize viewEditButton;

@synthesize sendButton;

@synthesize message;

@synthesize bubbleTable;

@synthesize bubbleData;

@synthesize sendView;

// Tells compiler to create setter and getter for add controller

@synthesize addGroupNavBar;

@synthesize addGroupBackButton;

@synthesize addGroup;

@synthesize selectContacts;

@synthesize showMembers;

@synthesize nameTable;

@synthesize addContactsSearchBar;

@synthesize addContactsSearchController;

@synthesize addContactsButton;

@synthesize viewEditSearchController;

@synthesize viewGroupSearchBar;


// Tells compiler to create setters and getters for vc that allows users to edit and view groups

@synthesize viewEditNavBar;

@synthesize memberView;

@synthesize addNameButton;

@synthesize backToSendButton;

@synthesize deleteNamesButton;

NSMutableArray * namesForRemoval;

NSMutableArray * searchResults;

NSMutableArray * namesAdded;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    // Also to allow us to select table name

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    namesAdded = [[NSMutableArray alloc] init];
    // Delegate views to self; done so we can customize table behaviour
    // memberView, nameTable, addGroup, addContactsSearchController, addGroup
    memberView.DataSource = self;
    memberView.delegate = self;
    nameTable.DataSource = self;
    nameTable.delegate = self;
    addGroup.delegate = self;
    addContactsSearchController.searchResultsTableView.DataSource = self;
    addContactsSearchController.searchResultsTableView.delegate = self;
    addGroup.delegate = self;
    viewEditSearchController.searchResultsTableView.DataSource = self;
    viewEditSearchController.searchResultsTableView.delegate = self;
    viewGroupSearchBar.delegate = self;
    
    // Set table view tags
    bubbleTable.tag = 0;
    nameTable.tag = 1;
    memberView.tag = 2;
    addContactsSearchController.searchResultsTableView.tag = 3;
    viewEditSearchController.searchResultsTableView.tag =  4;
    
    addContactsSearchController.searchBar.tag = 1;
    viewEditSearchController.searchBar.tag =  2;

    // For adding users
    
    // Add User name label
    adduserNameLabel.text = @"Type your name and number!";
    [addUsernameButton setTitle:@ "Begin!" forState:UIControlStateNormal];
    addUsernameField.placeholder = @"Type name here..";
    addUserNumberField.placeholder = @"Type number here..";
    
    // Message view setup
    message.text = @"";
    message.layer.cornerRadius = 5.0;
    message.clipsToBounds = YES;
    [message setHolder: @"Type message..."];
    message.delegate = self;
    
    [self.view endEditing:YES];
    
    // For adding groups
    
    addGroupNavBar.topItem.backBarButtonItem = addGroupBackButton;
    addGroupNavBar.topItem.title = @"New group";

    [addContactsButton setTitle: @"Add Contacts" forState:UIControlStateNormal];
    addContactsSearchBar.placeholder = @"Type the contact name, click to select";
    viewGroupSearchBar.placeholder = @"Type the contact name, click to select";

    addGroupBackButton.title = @"Back";
    
    // Set addGroup placeholders
    addGroup.placeholder = @"Type a group name here...";
    addGroup.tag = 0;
        
    // Following code alters textview
    // showMembers.hidden = YES;
    
    nameTable.layer.cornerRadius = 7;
    
    // For sending messages
    
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    
    sendNavBar.topItem.backBarButtonItem = backButton;
    backButton.title = @"Back";
    viewEditButton.title = @"View/Edit";
    
    sendNavBar.topItem.title = [[Globals sharedInstance] selectedGroupName];
    
    // For view edit page
    viewEditNavBar.topItem.backBarButtonItem = backToSendButton;
    backToSendButton.title = @"Back";
    viewEditNavBar.topItem.title = [[Globals sharedInstance] selectedGroupName];
    // Names to be removed
    namesForRemoval = [[NSMutableArray alloc] init];
    
    // No delete button if no names present
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setDictionary: [[Globals sharedInstance] nameDict]];
    NSMutableArray *arr = [dict objectForKey: [[Globals sharedInstance] selectedGroupName]];
    if([arr count] == 0) {
        [self toggleBarButton: false button: deleteNamesButton];
    }
    [addNameButton setTitle: @"Add!" forState:UIControlStateNormal];

    // Helper code
    
    // Following code setups bubble table

    bubbleData = [[[Globals sharedInstance] groupMess]  objectForKey:[[Globals sharedInstance] selectedGroupName]];

    bubbleTable.bubbleDataSource = self;

    // The line below sets the snap interval in seconds. This defines how the bubbles will be grouped in time.
    // Interval of 120 means that if the next messages comes in 2 minutes since the last message, it will be added into the same group.
    // Groups are delimited with header which contains date and time for the first message in the group.

    bubbleTable.snapInterval = 120;
    
    [bubbleTable reloadData];

    // Keyboard events
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    // V. Imp! Makes sure timer fires every 0.05 s so new table data can beloaded
    [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(reloadTable) userInfo:nil repeats:YES];
    
    searchResults = [[NSMutableArray alloc] init];
}

// Used to make sure keyboard appears on load

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    // Following line makes the message controller scroll
    // to bottom
    NSMutableArray * arr = [[[Globals sharedInstance] groupMess] objectForKey: [[Globals sharedInstance] selectedGroupName]];
    int l = [arr count];
    if(l > 0 && ([bubbleTable contentSize].height >  (CGRectGetHeight(sendView.frame)/2))) {
        [self.bubbleTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow: ([bubbleTable numberOfRowsInSection: 0] - 1) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    //[addMembers becomeFirstResponder];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Add users

//////////////////////////////////////////////////////////////////////////
// Following functions implement the view controller where we add users //
//////////////////////////////////////////////////////////////////////////

- (IBAction)addUserNameButton:(id)sender {
    if([addUsernameField.text isEqualToString: @""])
        adduserNameLabel.text = @"User name not added! ";
    else
    {
        [[Globals sharedInstance] setUserName : addUsernameField.text];
        [[Globals sharedInstance] setUserNumber : addUserNumberField.text];
        [self sanitizeUserNumber];

        // Save variables
        [[Globals sharedInstance] saveVariables];
        
        // Segue
        [self performSegueWithIdentifier: @"addToFirst" sender: self];
    }
}

#pragma mark - Send Messages

//////////////////////////////////////////////////////////////////////////////
// Following functions implement the view controller where we send messages //
//////////////////////////////////////////////////////////////////////////////

-(IBAction)sendButton:(id)sender {
    
    //Bubble data code
    
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    
    // Send message in dictionary form to all group memebers

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setDictionary:  [[Globals sharedInstance] nameDict]];
    
    NSArray* names = [dict valueForKey: [[Globals sharedInstance] selectedGroupName]];

    PNChannel *channels[[names count]];
    
    // Set dictionary: Value is channel, key is msg.
    // The value is actually the name of the group, with the name of the member append on
    // For added security.
    // Suppose someone sends a message to "Family" and they mistakenly add you to that group
    // You will get the message, though that person is not part of your group!
    // Thus we append names on the back for added security
    NSMutableDictionary *msg = [[NSMutableDictionary alloc] init];
    [msg setValue:[[[Globals sharedInstance] selectedGroupName] stringByAppendingString: [[Globals sharedInstance] userNumber]] forKey:message.text];
    
    for(int j = 0; j < [names count]; j++) {
        PNChannel *c = [PNChannel channelWithName: names[j] shouldObservePresence:YES];
        channels[j] = c;
        [PubNub sendMessage: msg toChannel:channels[j]];
    }
    
    NSMutableDictionary * msgDict = [[NSMutableDictionary alloc] init];
    [msgDict setDictionary: [[Globals sharedInstance] groupMess]];
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    temp = [msgDict valueForKey: [[Globals sharedInstance] selectedGroupName]] ;
        
    NSArray *dateSender = [[NSArray alloc] initWithObjects: [NSDate dateWithTimeIntervalSinceNow:0], @"Me", nil];
    NSMutableDictionary *msgDate = [[NSMutableDictionary alloc] init];
    [msgDate setObject: dateSender forKey: message.text];
    [temp addObject: msgDate];
        
    [msgDict removeObjectForKey: [[Globals sharedInstance] selectedGroupName]];
    [msgDict setObject: temp forKey: [[Globals sharedInstance] selectedGroupName]];
    [[Globals sharedInstance] setGroupMess: msgDict];
        
    // Call to ViewWillAppear so that most recent messages viewed
    [self viewWillAppear: YES];
    
    message.text = @"";
    [message resignFirstResponder];
    
    // Save variables
    [[Globals sharedInstance] saveVariables];
}

- (IBAction)backButton:(id)sender {
    [[Globals sharedInstance] setSelectedGroupName: @""];
    [self performSegueWithIdentifier: @"sendToFirst" sender: self];
}

#pragma mark - Add groups

///////////////////////////////////////////////////////////////////////////
// Following functions implement the view controller where we add groups //
///////////////////////////////////////////////////////////////////////////

// Note; name is a misnoymr; actually 'done button'
- (IBAction)selectContacts:(id)sender {

    UIAlertView * alert;
    NSString *potGroup = [NSString stringWithString : addGroup.text];
    bool isPresent = false;
    for (id obj in [[Globals sharedInstance] groups]) {
        isPresent = [potGroup isEqualToString:obj];
    }
    if(isPresent) {
        alert = [[UIAlertView alloc] initWithTitle:@"Group already exist!" message:@"Go to the group, and click view/edit" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Overwrite", nil];
        [alert setTag:0];
        [alert show];
        [self.view endEditing:YES];
    }
    else {
        if([potGroup isEqualToString: @"" ]) {
            // Implemented below
            alert = [[UIAlertView alloc] initWithTitle:@"No group name found" message:@"The group will be lost!" delegate:self cancelButtonTitle:@"Escape" otherButtonTitles:@"Return", nil];
            [alert setTag:1];
            [alert show];
            [self.view endEditing:YES];
        }
        else if(![[[Globals sharedInstance] namesForGroup] count]) {
            alert = [[UIAlertView alloc] initWithTitle:@"Gotta add some names!" message:@"" delegate:self cancelButtonTitle:@"Escape" otherButtonTitles:@"Select names", nil];
            [alert setTag:2];
            [alert show];
            [self.view endEditing:YES];
        }
        else {
            
            NSMutableArray *temp= [[Globals sharedInstance] groups];
            [temp addObject:potGroup];
            [[Globals sharedInstance] setGroups: temp];
            
            // Store names into dict
            NSMutableArray * arr = [[Globals sharedInstance] namesForGroup];
            
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            [dict setDictionary: [[Globals sharedInstance] nameDict]];
            [dict setObject: arr forKey: addGroup.text];
            [[Globals sharedInstance] setNameDict: dict];
            
            // Store group name in messgaes dictionary
            
            NSMutableDictionary * msgDict = [[NSMutableDictionary alloc] init];
            [msgDict setDictionary:[[Globals sharedInstance] groupMess]];
            [msgDict setObject: [[NSMutableArray alloc] init] forKey: addGroup.text];
            [[Globals sharedInstance] setGroupMess: msgDict];
            
            addGroup.text = @"";
            [[Globals sharedInstance] setNamesForGroup: [[NSMutableArray alloc] init]];
            [nameTable reloadData];
            
            // Save variables
            [[Globals sharedInstance] saveVariables];
            addGroupNavBar.topItem.title = @"New group";
        }
    }
    [[Globals sharedInstance] setNamesForGroup:[[NSMutableArray alloc] init]];
    [nameTable reloadData];
}

- (IBAction)addContactsButton:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add name and Number" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    UITextField * alertTextField2 = [alert textFieldAtIndex:1];
    
    alertTextField.keyboardType = UIKeyboardTypeNamePhonePad;
    alertTextField.placeholder = @"Enter a name";
    
    alertTextField2.keyboardType = UIKeyboardTypeNumberPad;
    alertTextField2.placeholder = @"Enter a number";
    alertTextField2.secureTextEntry = NO;
    alertTextField2.text = @"";

    [alert setTag:3];
    [alert show];
    [self.view endEditing:YES];

}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger) buttonIndex
{
    if(alertView.tag == 0){
        if(buttonIndex == 0) {
            return;
        }
        else if (buttonIndex == 1){
            // Store names into dict
            NSMutableArray * arr = [[Globals sharedInstance] namesForGroup];
            
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            [dict setDictionary: [[Globals sharedInstance] nameDict]];
            [dict removeObjectForKey: [[Globals sharedInstance] selectedGroupName]];
            [dict setObject: arr forKey: addGroup.text];
            [[Globals sharedInstance] setNameDict: dict];
            
            // Store group name in messgaes dictionary
            
            NSMutableDictionary * msgDict = [[NSMutableDictionary alloc] init];
            [msgDict setDictionary:[[Globals sharedInstance] groupMess]];
            [msgDict setObject: [[NSMutableArray alloc] init] forKey: addGroup.text];
            [[Globals sharedInstance] setGroupMess: msgDict];
            [self performSegueWithIdentifier: @"addGroupsToSelect" sender:self];

        }
    }
    else if(alertView.tag == 1) {
        if (buttonIndex == 0){
            [self performSegueWithIdentifier: @"addGroupsToSelect" sender:self];
        }
        else if (buttonIndex == 1){

        }

    }
    else if(alertView.tag == 2) {
        if (buttonIndex == 0){
            [self performSegueWithIdentifier: @"addGroupsToSelect" sender:self];
        }
        else if (buttonIndex == 1){
            // If time permits, find way of triggering search controller
        }
    }
    else if(alertView.tag == 3) {
        if (buttonIndex == 0)
            return;
        else if (buttonIndex == 1){
            if([[alertView textFieldAtIndex:0].text isEqualToString: @""] && [[alertView textFieldAtIndex:1].text isEqualToString: @""]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Contact not added" message:@"Name and number not entered" delegate:self cancelButtonTitle:@"Hide" otherButtonTitles: nil];
                [alert show];
                return;
            }
            else if([[alertView textFieldAtIndex:0].text isEqualToString: @""]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Contact not added" message:@"Name not entered" delegate:self cancelButtonTitle:@"Hide" otherButtonTitles: nil];
                [alert show];
                return;
            }
            else if([[alertView textFieldAtIndex:1].text isEqualToString: @""]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Contact not added" message:@"Number not entered" delegate:self cancelButtonTitle:@"Hide" otherButtonTitles: nil];
                [alert show];
                return;
            }
            else
            {
                NSString* name = [alertView textFieldAtIndex:0].text;
                NSString *number = [alertView textFieldAtIndex:1].text;
                NSMutableDictionary *dict = [[Globals sharedInstance] nameNumber];
                [dict setValue: number forKey: name];
                [[Globals sharedInstance] setNameNumber: dict];
                [[[Globals sharedInstance] namesForGroup] addObject: name];
                [nameTable reloadData];
            }
        }
    }
    else if(alertView.tag == 4) {
        if (buttonIndex == 0)
            return;
        else if (buttonIndex == 1){
            if([[alertView textFieldAtIndex:0].text isEqualToString: @""] && [[alertView textFieldAtIndex:1].text isEqualToString: @""]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Contact not added" message:@"Name and number not entered" delegate:self cancelButtonTitle:@"Hide" otherButtonTitles: nil];
                [alert show];
                return;
            }
            else if([[alertView textFieldAtIndex:0].text isEqualToString: @""]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Contact not added" message:@"Name not entered" delegate:self cancelButtonTitle:@"Hide" otherButtonTitles: nil];
                [alert show];
                return;
            }
            else if([[alertView textFieldAtIndex:1].text isEqualToString: @""]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Contact not added" message:@"Number not entered" delegate:self cancelButtonTitle:@"Hide" otherButtonTitles: nil];
                [alert show];
                return;
            }
            else {
                NSString* name = [alertView textFieldAtIndex:0].text;
                NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                [dict setDictionary: [[Globals sharedInstance] nameDict]];
                NSMutableArray *arr = [dict objectForKey: [[Globals sharedInstance] selectedGroupName]];
                [dict removeObjectForKey: [[Globals sharedInstance] selectedGroupName]];
                [arr addObject: name];
                [dict setObject: arr forKey:[[Globals sharedInstance] selectedGroupName]];
                [[Globals sharedInstance] setNameDict: dict];
                
                NSString *number = [alertView textFieldAtIndex:1].text;
                NSMutableDictionary * appeloNumerus = [[NSMutableDictionary alloc] init];
                [appeloNumerus setDictionary: [[Globals sharedInstance] nameNumber]];
                [appeloNumerus setObject: number forKey: name];
                [[Globals sharedInstance] setNameNumber: appeloNumerus];


                
                [memberView reloadData];
            }
        }
    }
}

#pragma mark - view/edit

/////////////////////////////////////////////////////////////////////////////////////
// Following functions implement the view controller where we view and edit groups //
/////////////////////////////////////////////////////////////////////////////////////

- (IBAction)addNameButton:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add name and Number" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    UITextField * alertTextField2 = [alert textFieldAtIndex:1];
    
    alertTextField.keyboardType = UIKeyboardTypeNamePhonePad;
    alertTextField.placeholder = @"Enter a name";
    
    alertTextField2.keyboardType = UIKeyboardTypeNumberPad;
    alertTextField2.placeholder = @"Enter a number";
    alertTextField2.secureTextEntry = NO;
    alertTextField2.text = @"";
    
    [alert setTag:4];
    [alert show];
    [self.view endEditing:YES];

}

- (IBAction)deleteNamesButton:(id)sender {
    
    NSString * str = [[NSString alloc] init];
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setDictionary: [[Globals sharedInstance] nameDict]];
    NSMutableArray *arr = [dict objectForKey: [[Globals sharedInstance] selectedGroupName]];
    NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
    bool isSame;
    for(int i = 0; i < [arr count];  i++) {
        isSame = false;
        for(int j = 0; j < [namesForRemoval count]; j++){
            if([arr[i] isEqualToString: namesForRemoval[j]]) {
                isSame = true;
                if(![str isEqualToString: @""])
                    str = [str stringByAppendingString: @", "];
                str = [str stringByAppendingString: arr[i]];
                break;
            }
        }
        if(!isSame){
            [filteredArray addObject: arr[i]];
        }
    }
    arr = filteredArray;
    [dict removeObjectForKey: [[Globals sharedInstance] selectedGroupName]];
    [dict setObject: arr forKey:[[Globals sharedInstance] selectedGroupName]];
    [[Globals sharedInstance] setNameDict: dict];
    [nameTable reloadData];
    
    //Add a message saying someon'es deleted
    
    NSMutableDictionary * msgDict = [[NSMutableDictionary alloc] init];
    [msgDict setDictionary: [[Globals sharedInstance] groupMess]];
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    temp = [msgDict valueForKey: [[Globals sharedInstance] selectedGroupName]] ;
    
    NSArray *dateSender = [[NSArray alloc] initWithObjects: [NSDate dateWithTimeIntervalSinceNow:0], @"Me", nil];
    NSMutableDictionary *msgDate = [[NSMutableDictionary alloc] init];
    str = [str stringByAppendingString: @" deleted! :("];
    [msgDate setObject: dateSender forKey: str];
    [temp addObject: msgDate];
    
    [msgDict removeObjectForKey: [[Globals sharedInstance] selectedGroupName]];
    [msgDict setObject: temp forKey: [[Globals sharedInstance] selectedGroupName]];
    [[Globals sharedInstance] setGroupMess: msgDict];

    
    // Hide delete key if nothing can be deleted
    if([arr count] == 0) {
        [self toggleBarButton: false button: deleteNamesButton];
    }
    
    // Save variables
    [[Globals sharedInstance] saveVariables];

}

///////////////////////
// Helper functions //
/////////////////////


- (void) sanitizeUserNumber {
    NSString * num = [[Globals sharedInstance] userNumber];
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"()- "];
    num = [[num componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
    NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
    NSString *isoCode = [currentLocale objectForKey:NSLocaleCountryCode];
    NSString *countryCode =  [[[Globals sharedInstance] isoToCountry] objectForKey:isoCode];
    
    NSString * userNum = [countryCode stringByAppendingString:num];
    [[Globals sharedInstance] setUserNumber: userNum];
}

// BubbleTable Code

#pragma mark - UIBubbleTableViewDataSource implementation


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [[[[Globals sharedInstance] groupMess] valueForKey: [[Globals sharedInstance] selectedGroupName]] count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    NSMutableDictionary * msgDate = [[[[Globals sharedInstance] groupMess] valueForKey: [[Globals sharedInstance] selectedGroupName]] objectAtIndex:row];
    
    NSString *key;
    for(id k in msgDate)
        key = k;
  
    NSArray *dateUser = [msgDate valueForKey: key];
    NSDate *date = dateUser[0];
    NSString *user = dateUser[1];
    if([user isEqualToString: @"Me"])
        return [NSBubbleData dataWithText:key date:date type:BubbleTypeMine];
    else
    {
        NSString *temp = @" - ";
        user = [temp stringByAppendingString: user];
        return [NSBubbleData dataWithText:[key stringByAppendingString: user] date:date type:BubbleTypeSomeoneElse];
    }
}

#pragma mark - Keyboard events



// Make keyboard dissapear with retrun

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if(textField == addGroup)
        addGroupNavBar.topItem.title = addGroup.text;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField.tag == 0)
        addGroupNavBar.topItem.title = textField.text;
}


- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        // For send controller
        CGRect frame = message.frame;
        frame.origin.y -= kbSize.height;
        message.frame = frame;
        
        frame = sendButton.frame;
        frame.origin.y -= kbSize.height;
        sendButton.frame = frame;
                
        frame = bubbleTable.frame;
        frame.size.height -= kbSize.height;
        bubbleTable.frame = frame;
        
        // For add group controller
        frame = addGroup.frame;
        frame.origin.y -= kbSize.height;
        addGroup.frame = frame;
        
        frame = showMembers.frame;
        frame.size.height -= kbSize.height;
        showMembers.frame = frame;

    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        // For send controller
        CGRect frame = message.frame;
        frame.origin.y += kbSize.height;
        message.frame = frame;
        
        frame = sendButton.frame;
        frame.origin.y += kbSize.height;
        sendButton.frame = frame;
        
        frame = bubbleTable.frame;
        frame.size.height += kbSize.height;
        bubbleTable.frame = frame;
        
        // For add group controller
        frame = addGroup.frame;
        frame.origin.y += kbSize.height;
        addGroup.frame = frame;
        
        frame = showMembers.frame;
        frame.size.height += kbSize.height;
        showMembers.frame = frame;
        
    }];

}

// used to reload bubble data so that we get real time chat info
// otherwise we dont get texts from them, only on reload
-(void)reloadTable{
    [self.bubbleTable reloadData];
    //NSLog([[Globals sharedInstance] selectedGroupName]);
    /*
    if(sendNavBar.topItem.title != [[Globals sharedInstance] selectedGroupName] )
        sendNavBar.topItem.title = [[Globals sharedInstance] selectedGroupName];
     */
    
}

-(void)toggleBarButton:(bool)show button:(UIBarButtonItem *) btn
{
    if (show) {
        btn.style = UIBarButtonItemStyleBordered;
        btn.enabled = true;
        btn.title = @"MyTitle";
    } else {
        btn.style = UIBarButtonItemStylePlain;
        btn.enabled = false;
        btn.title = nil;
    }
}


#pragma mark Table view data source for edit/view controller and send message controller

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    if(tableView.tag == 0) {
        arr = [[[Globals sharedInstance] groupMess] valueForKey: [[Globals sharedInstance] selectedGroupName]];
    }
    else if(tableView.tag == 1)
            arr = [[Globals sharedInstance] namesForGroup];
    else if(tableView.tag ==2)
        arr = [[[Globals sharedInstance] nameDict] valueForKey: [[Globals sharedInstance] selectedGroupName]];
    else if(tableView.tag == 3)
            arr = searchResults;
    else if(tableView.tag == 4)
        arr = searchResults;

    return [arr count];
}

// Customize the appearance of table view cells.
- (TableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    static NSString *CellIdentifier = @"Cell";
    TableViewCell * cell = [nameTable dequeueReusableCellWithIdentifier:CellIdentifier];

    // Configure the cell...
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    if(tableView.tag == 0) {
        arr = [[[Globals sharedInstance] nameDict] valueForKey: [[Globals sharedInstance] selectedGroupName]];
    }
    else if (tableView.tag == 1) {
        arr = [[Globals sharedInstance] namesForGroup];
    }
    else if(tableView.tag == 2) {
        arr = [[[Globals sharedInstance] nameDict] valueForKey: [[Globals sharedInstance] selectedGroupName]];
    }
    else if (tableView.tag == 3)
        arr = searchResults;
    else if (tableView.tag == 4)
        arr = searchResults;

    cell.nameLabel.text = [arr objectAtIndex: indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;  // Turn off blue highlight
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; // Deselect each row
    cell.accessoryType = UITableViewCellAccessoryNone; // Make sure reloaded data is not selected
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (tableView.tag == 3 || tableView.tag == 4) {
        for(id name in [[Globals sharedInstance] namesForGroup]) {
            if([name isEqualToString: [arr objectAtIndex: indexPath.row]])
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }

    return cell;
}

// For view edit text selection

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    TableViewCell *cell = (TableViewCell *) [tableView cellForRowAtIndexPath:indexPath];

    if(tableView.tag == 0) {
        if(cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            for(int i = 0; i < [namesForRemoval count]; i++){
                if([namesForRemoval[i] isEqualToString: cell.nameLabel.text])
                [namesForRemoval removeObject:namesForRemoval[i]];
            }
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [namesForRemoval addObject: cell.nameLabel.text];
        }
    }
    else if (tableView.tag == 1) {
        // Check if users want this
        /*
        TableViewCell *cell = (TableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
        for(int i = 0; i < [[[Globals sharedInstance] namesForGroup] count]; i++){
            if([[[Globals sharedInstance] namesForGroup][i] isEqualToString: cell.nameLabel.text])
                [[[Globals sharedInstance] namesForGroup] removeObject:[[Globals sharedInstance] namesForGroup][i]];
        }
    [nameTable reloadData];
         */
    }
    else if(tableView.tag == 2){
        if(cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            for(int i = 0; i < [namesForRemoval count]; i++){
                if([namesForRemoval[i] isEqualToString: cell.nameLabel.text])
                    [namesForRemoval removeObject:namesForRemoval[i]];
            }
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [namesForRemoval addObject: cell.nameLabel.text];
        }
    }
    else if(tableView.tag == 3)
    {
        if(cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [[[Globals sharedInstance] namesForGroup] removeObject:cell.nameLabel.text];
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [[[Globals sharedInstance] namesForGroup] addObject: cell.nameLabel.text];
        }
        [addContactsSearchBar resignFirstResponder];

    }
    else if(tableView.tag == 4)
    {
        if(cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            NSMutableDictionary * dict = [[Globals sharedInstance] nameDict];
            NSMutableArray * arr = [dict valueForKey: [[Globals sharedInstance] selectedGroupName]];
            [arr removeObject:cell.nameLabel.text];
            [dict setObject: arr forKey:[[Globals sharedInstance] selectedGroupName]];
            [[Globals sharedInstance] setNameDict: dict];
            
            for(id name in namesAdded) {
                if ([name isEqualToString: cell.nameLabel.text])
                    [namesAdded removeObject: cell.nameLabel.text];
            }
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            NSMutableDictionary * dict = [[Globals sharedInstance] nameDict];
            NSMutableArray * arr = [dict valueForKey: [[Globals sharedInstance] selectedGroupName]];
            [arr addObject: cell.nameLabel.text];
            [dict setObject: arr forKey:[[Globals sharedInstance] selectedGroupName]];
            [[Globals sharedInstance] setNameDict: dict];
            
            [self toggleBarButton:true button:deleteNamesButton];
            
            bool flag = true;
            for(id name in namesAdded) {
                if ([name isEqualToString: cell.nameLabel.text]) {
                    flag = false;
                    break;
                }
            }
            if(flag)
                [namesAdded addObject: cell.nameLabel.text];
        

        }
        [viewGroupSearchBar resignFirstResponder];
        
    }

}

#pragma mark - Search bar controller methods

// Search functions etc.

- (void)searchForText:(NSString *)searchText scope:(int)scopeOption tag:(int) tag
{
    NSDictionary *dict = [[Globals sharedInstance] nameNumber];
    searchResults =[[NSMutableArray alloc] init];
    searchText = [searchText lowercaseString];
    
    bool flag = true; // To make sure name in group isn't shown
    NSArray *names = [dict allKeys];
    if(scopeOption == 0) {
        for(id appelo in names) { // appelo is latin for name
            id appeloLow = [appelo lowercaseString];
            if([searchText length] >[appeloLow length]) {
                if([[searchText substringWithRange:NSMakeRange(0, [appeloLow length])]isEqualToString: appeloLow] && [self isPresent:searchResults str:appeloLow])
                {
                    if(tag == 2)
                        flag = [self isPresent: [[[Globals sharedInstance] nameDict] valueForKey: [[Globals sharedInstance] selectedGroupName]] str:appeloLow];
                    if(flag)
                        [searchResults addObject: appelo];
                }
            }
            else if([[appeloLow substringWithRange:NSMakeRange(0, [searchText length])]isEqualToString: searchText] && [self isPresent:searchResults str:appeloLow])
            {
                if(tag == 2)
                    flag = [self isPresent: [[[Globals sharedInstance] nameDict] valueForKey: [[Globals sharedInstance] selectedGroupName]] str:appeloLow];
                if(flag)                
                [searchResults addObject: appelo];
            }
        }
    }
    else if(scopeOption == 1){
        for(id appelo in names) {// appelo is latin for nam
            id numerus = [dict objectForKey:appelo];
            if([searchText length] >[numerus length]) {
                if([[searchText substringWithRange:NSMakeRange(0, [numerus length])]isEqualToString: numerus] && [self isPresent:searchResults str:appelo])
                    if(tag == 2)
                        flag = [self isPresent: [[[Globals sharedInstance] nameDict] valueForKey: [[Globals sharedInstance] selectedGroupName]] str:appelo];
                    if(flag)
                    [searchResults addObject: appelo];
            }
            else if([[numerus substringWithRange:NSMakeRange(0, [searchText length])]isEqualToString: searchText] && [self isPresent:searchResults str:appelo])
                if(tag == 2)
                    flag = [self isPresent: [[[Globals sharedInstance] nameDict] valueForKey: [[Globals sharedInstance] selectedGroupName]] str:appelo];
                if(flag)
                    [searchResults addObject: appelo];
        }
    }
}

-(BOOL) isPresent:(NSArray * )arr str:(NSString *) name {
    for(id element in arr) {
        id elemento = [element lowercaseString];
        if([elemento isEqualToString: name])
            return FALSE;
    }
    return TRUE;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    searchResults = [[NSMutableArray alloc] init];
    int scopepOption = controller.searchBar.selectedScopeButtonIndex;
    [self searchForText:searchString scope:scopepOption tag:controller.searchBar.tag];
    addContactsSearchController.searchResultsTableView.tag = 3;
    viewEditSearchController.searchResultsTableView.tag = 4;
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    NSString *searchString = controller.searchBar.text;
    [self searchForText:searchString scope:searchOption tag: controller.searchBar.tag];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {

}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar sizeToFit];
    searchBar.showsScopeBar = YES;
    [nameTable reloadData];
    [memberView reloadData];
    

    return YES;
}

// Used to rsign keyboard if user touches anywhere to help him select stuff better
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [addContactsSearchBar resignFirstResponder];
    [viewGroupSearchBar resignFirstResponder];
}

- (IBAction)backToSendButton:(id)sender {
    // Add a message saying who's added
    if([namesAdded count] > 0) {
        NSMutableDictionary * msgDict = [[NSMutableDictionary alloc] init];
        [msgDict setDictionary: [[Globals sharedInstance] groupMess]];
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        temp = [msgDict valueForKey: [[Globals sharedInstance] selectedGroupName]] ;
    
        NSArray *dateSender = [[NSArray alloc] initWithObjects: [NSDate dateWithTimeIntervalSinceNow:0], @"Me", nil];
        NSMutableDictionary *msgDate = [[NSMutableDictionary alloc] init];
        NSString * str = [[NSString alloc] init];
        
        for(id name in namesAdded){
            if(![str isEqualToString: @""]) {
                str = [str stringByAppendingString: @", "];
            }
            str = [str stringByAppendingString: name];
        }
        str = [str stringByAppendingString: @" added! :)"];

        [msgDate setObject: dateSender forKey: str];
        [temp addObject: msgDate];
    
        [msgDict removeObjectForKey: [[Globals sharedInstance] selectedGroupName]];
        [msgDict setObject: temp forKey: [[Globals sharedInstance] selectedGroupName]];
        [[Globals sharedInstance] setGroupMess: msgDict];
    
        namesAdded = [[NSMutableArray alloc] init];
    }
    [self performSegueWithIdentifier:@"viewToSend" sender:self];
}
@end
