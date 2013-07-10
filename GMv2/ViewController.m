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

@synthesize addButton;

@synthesize addMembers;

@synthesize warnLabel;

@synthesize selectContacts;

@synthesize addPhoneNumber;

@synthesize addMember;

@synthesize showMembers;

@synthesize nameTable;

// Tells compiler to create setters and getters for vc that allows users to edit and view groups

@synthesize viewEditNavBar;

@synthesize memberView;

@synthesize addNameView;

@synthesize addNameButton;

@synthesize backToSendButton;

@synthesize deleteNamesButton;

NSMutableArray * namesForRemoval;

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
    
    // Delegate views to self; done so we can customize table behaviour
    
    memberView.DataSource = self;
    memberView.delegate = self;
    nameTable.DataSource = self;
    nameTable.delegate = self;
    
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
    addGroupBackButton.title = @"Back";
    
    // Only do so if empty

    addGroupNavBar.topItem.title = @"New group";
    warnLabel.text = @"";
    
    // Set addGroup placeholders
    addGroup.placeholder = @"Type a group name here...";
    
    // Set groupNameSend to selected group name
    // Make Text view Rounded
    addMembers.layer.cornerRadius = 10;
    addMembers.clipsToBounds = YES;
    
    [addButton setTitle: @"Done" forState:UIControlStateNormal];
    [addMember setTitle: @"Add!" forState:UIControlStateNormal];
    
    selectContacts.title = @"Select from contacts";
    
    // Following code alters textview
    [addMembers setHolder: @"Type name here"];
    addPhoneNumber.placeholder = @"Type number here";
    if(![[Globals sharedInstance] namesForGroup].count)
        showMembers.hidden = YES;
    
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
    [addNameView setHolder: @"Add someone here!"];
    
    // Names to be removed
    namesForRemoval = [[NSMutableArray alloc] init];
    
    // No delete button if no names present
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setDictionary: [[Globals sharedInstance] nameDict]];
    NSMutableArray *arr = [dict objectForKey: [[Globals sharedInstance] selectedGroupName]];
    if([arr count] == 0)
        deleteNamesButton.customView = [[UIView alloc] init];

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button implementation

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

//////////////////////////////////////////////////////////////////////////////
// Following functions implement the view controller where we send messages //
//////////////////////////////////////////////////////////////////////////////

-(IBAction)sendButton:(id)sender {
    
    //Bubble data code
    
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    // NSBubbleData *sayBubble = [NSBubbleData dataWithText:message.text date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
    
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

///////////////////////////////////////////////////////////////////////////
// Following functions implement the view controller where we add groups //
///////////////////////////////////////////////////////////////////////////

- (IBAction)addButton:(id)sender {
    
    // Add group, or report that group already exists
    NSString *potGroup = [NSString stringWithString : addGroup.text];
    bool isPresent = false;
    for (id obj in [[Globals sharedInstance] groups]) {
        isPresent = [potGroup isEqualToString:obj];
    }
    if(isPresent) {
        warnLabel.text =@"Group already exist. Go to the group, and click view/edit";
        [self.view endEditing:YES];
    }
    else {
        if([potGroup isEqualToString: @"" ]) {
            warnLabel.text = @"Can't add a group with no name!";
            [self.view endEditing:YES];
        }
        else if(![[Globals sharedInstance]namesForGroup].count) {
                warnLabel.text = @"No names!";
                [self.view endEditing:YES];
            }
        else {

            warnLabel.text = @"";
            NSMutableArray *temp= [[Globals sharedInstance] groups];
            [temp addObject:potGroup];
            [[Globals sharedInstance] setGroups: temp];
        
            // Separate names, store them into dict
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
    
            addGroup.text = @"";
            [[Globals sharedInstance] setNamesForGroup: [[NSMutableArray alloc] init]];
            [nameTable reloadData];
            
            // Save variables
            [[Globals sharedInstance] saveVariables];
            
        }
    }
    [[Globals sharedInstance] setNamesForGroup: [[NSMutableArray alloc] init]];

}

- (IBAction)addMember:(id)sender {
    
    // Following check for conditions where we should not add members
    for(id name in [[Globals sharedInstance] namesForGroup]) {
        if([name isEqualToString: addMembers.text]) {
            warnLabel.text = @"Can't! Name and number already present";
            addMembers.text = @"";
            addPhoneNumber.text = @"";
            [self.view endEditing:YES];
            return;
        }
    }
    if([addMembers.text isEqualToString: @""]) {
        warnLabel.text = @"Must add name";
        addMembers.text = @"";
        addPhoneNumber.text = @"";
        [self.view endEditing:YES];
        return;
    }
    else if([addPhoneNumber.text isEqualToString: @""]) {
        warnLabel.text = @"Must add number";
        addMembers.text = @"";
        addPhoneNumber.text = @"";
        [self.view endEditing:YES];
        return;
    }

    // Add members now that conditions satisfied
    NSMutableDictionary *dict = [[Globals sharedInstance] nameNumber];
    [dict setValue: addPhoneNumber.text forKey: addMembers.text];
    [[Globals sharedInstance] setNameNumber: dict];
    [[[Globals sharedInstance]namesForGroup] addObject: addMembers.text];
    addMembers.text = @"";
    addPhoneNumber.text = @"";
    showMembers.hidden = NO;
    [nameTable reloadData];
    return;
}

- (IBAction)selectContacts:(id)sender {
    [self performSegueWithIdentifier: @"addGroupsToSelect" sender: self];
}

/////////////////////////////////////////////////////////////////////////////////////
// Following functions implement the view controller where we view and edit groups //
/////////////////////////////////////////////////////////////////////////////////////

- (IBAction)addNameButton:(id)sender {
    if([addNameView.text isEqualToString: @""]) {
        [addNameView setHolder: @"Please add someone"];
        //[addNameView resignFirstResponder];
    }
    else
    {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setDictionary: [[Globals sharedInstance] nameDict]];
        NSMutableArray *arr = [dict objectForKey: [[Globals sharedInstance] selectedGroupName]];
        
        [arr addObject: (addNameView.text)];
        [dict removeObjectForKey: [[Globals sharedInstance] selectedGroupName]];
        [dict setObject: arr forKey:[[Globals sharedInstance] selectedGroupName]];
        [[Globals sharedInstance] setNameDict: dict];
        [memberView reloadData];
        [addNameView resignFirstResponder];
        addNameView.text = @"";
    }
}

- (IBAction)deleteNamesButton:(id)sender {
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
                break;
            }
        }
        if(!isSame)
            [filteredArray addObject: arr[i]];
    }
    arr = filteredArray;
    [dict removeObjectForKey: [[Globals sharedInstance] selectedGroupName]];
    [dict setObject: arr forKey:[[Globals sharedInstance] selectedGroupName]];
    [[Globals sharedInstance] setNameDict: dict];
    [nameTable reloadData];
    [addNameView resignFirstResponder];
    
    // Hide delete key if nothing can be deleted
    if([arr count] == 0) {
        deleteNamesButton.customView = [[UIView alloc] init];
    }
    
    // Save variables
    [[Globals sharedInstance] saveVariables];

}

///////////////////////
// Helper functions //
/////////////////////

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
    [addMembers becomeFirstResponder];
}

// Make keyboard dissapear with retrun

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

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

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = message.frame;
        frame.origin.y -= kbSize.height;
        message.frame = frame;
        
        frame = addNameView.frame;
        frame.origin.y -= kbSize.height;
        addNameView.frame = frame;

        frame = sendButton.frame;
        frame.origin.y -= kbSize.height;
        sendButton.frame = frame;
        
        frame = addNameButton.frame;
        frame.origin.y -= kbSize.height;
        addNameButton.frame = frame;
        
        frame = bubbleTable.frame;
        frame.size.height -= kbSize.height;
        bubbleTable.frame = frame;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = message.frame;
        frame.origin.y += kbSize.height;
        message.frame = frame;

        frame = addNameView.frame;
        frame.origin.y += kbSize.height;
        addNameView.frame = frame;
        
        frame = sendButton.frame;
        frame.origin.y += kbSize.height;
        sendButton.frame = frame;


        frame = addNameButton.frame;
        frame.origin.y += kbSize.height;
        addNameButton.frame = frame;
        
        frame = bubbleTable.frame;
        frame.size.height += kbSize.height;
        bubbleTable.frame = frame;
    }];
    [bubbleTable reloadData];
}

// used to reload bubble data so that we get real time chat info
// otherwise we dont get texts from them, only on reload
-(void)reloadTable{
    [self.bubbleTable reloadData];
}

#pragma mark Table view data source for edit/view controller

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    if(tableView.tag == 0) {
        arr = [[[Globals sharedInstance] nameDict] valueForKey: [[Globals sharedInstance] selectedGroupName]];
    }
    else if(tableView.tag == 1)
            arr = [[Globals sharedInstance] namesForGroup];

    return [arr count];
}

// Customize the appearance of table view cells.
- (TableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    static NSString *CellIdentifier = @"Cell";
    
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    // Configure the cell...
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    if(tableView.tag == 0) {
        arr = [[[Globals sharedInstance] nameDict] valueForKey: [[Globals sharedInstance] selectedGroupName]];
    }
    else if (tableView.tag == 1) {
        arr = [[Globals sharedInstance] namesForGroup];

    }
    cell.nameLabel.text = [arr objectAtIndex: indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;  // Turn off blue highlight
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; // Deselect each row
    cell.accessoryType = UITableViewCellAccessoryNone; // Make sure reloaded data is not selected

    return cell;
}

// For view edit text selection

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == 0) {
        TableViewCell *cell = (TableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
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
}

@end
