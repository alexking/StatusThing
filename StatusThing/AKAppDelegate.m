
#import "AKAppDelegate.h"

@implementation AKAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    // Settings
    self.settings = [[AKSettings alloc] init];
    
    // Launch
    self.launch = [[AKLaunchItem alloc] init];
    
    // Setup
    self.items = [[NSMutableArray alloc] init];
    self.preferencesTemperatureSensorTitleToId = [[NSMutableDictionary alloc] init];
    
    // Use AKSmartThings
    self.things = [[AKSmartThings alloc] init];
    self.things.delegate = self; 
    [self.things setPort: 2324];

    // Set the ID and secret if we have them
    self.things.clientId = self.settings.clientId;
    self.things.clientSecret = self.settings.clientSecret;
    self.things.accessToken = self.settings.accessToken;
    
    // Lets use the application url scheme feature
    self.things.applicationUrlScheme = @"statusthing";
    
    // Setup our status bar item
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength: NSVariableStatusItemLength];
    [self.statusItem setHighlightMode: YES];
    
    
    // Setup the menu for the status bar item
    self.statusMenu = [[NSMenu alloc] initWithTitle: @"Menu"];
    [self.statusItem setMenu: self.statusMenu];
    
    // Load preferences
    [self loadPreferences];
    
    // If there aren't any items, the menu will be disconnected, and it will default to the action
    [self.statusItem setAction: @selector(showPreferences)];
    
    // If we have an access token
    if (self.settings.accessToken != nil) {
        
        // Set preferences default to general
        [self.preferencesToolbar setSelectedItemIdentifier: @"general"];
        [self.preferenceTabs selectTabViewItemWithIdentifier: @"general"];
     
        
    }
    else
    {
        // If we don't have the access token, start connecting and show preferences on the account tab
        [self.preferencesToolbar setSelectedItemIdentifier: @"account"];
        [self.preferenceTabs selectTabViewItemWithIdentifier: @"account"];
        
        [self showPreferences];
    }
    

    // Handles temperature / icon display
    [self refreshStatusItem];
    
    // Build the menu
    [self refreshMenu];
}


- (IBAction)clearAllSettings:(NSButton *)sender {

    NSAlert *confirm = [NSAlert alertWithMessageText: @"Clear All Settings" defaultButton: @"Cancel" alternateButton: @"Yes, Delete Them All" otherButton: nil informativeTextWithFormat:@"Are you sure you want to remove all application settings, including OAuth configuration?"];
    
    [confirm beginSheetModalForWindow: self.window completionHandler:^(NSModalResponse returnCode) {
        
        // Make sure they clicked the alternate button
        if (returnCode == NSAlertAlternateReturn)
        {
            
            // Clear all settings
            [self.settings reset];
            
            self.things.clientId = nil;
            self.things.clientSecret = nil;
            self.things.accessToken = nil;
            
            // Remove the data
            self.temperatures = nil;
            self.items = nil;
            
            [self requestUpdateFromServer];
            [self clearPreferences];
            [self forceRefreshInterface];
        }
        
    }];

}

- (void) authorize {
    
    bool success = [self.things askUserForPermissionUsingClientSecret: self.settings.clientSecret];
    
    if (!success)
    {
        
        // Failure
        [self.statusLabel setStringValue: @"Unable to authorize – please make sure port 2323 is available"];
        
    }

}

- (void)handleError: (NSError *)error
{
    
    NSLog(@"%@", error);
    
}


- (void) authorized {
    
    [self refreshPreferences];
    
}

- (void) forceRefreshInterface
{
    [self forceRefreshMenu];
    [self refreshStatusItem];
    [self refreshPreferences];
}

- (void) refreshInterface
{
    [self refreshMenu];
    [self refreshStatusItem];
    [self refreshPreferences];
}

- (void) statusMenuSeparatorItemWithTag: (NSUInteger)tag atPosition: (NSUInteger)position shouldExist: (BOOL)shouldExist
{
    
    // Add
    if (shouldExist)
    {
        
        if ([self.statusMenu itemWithTag: tag] == nil)
        {
            
            // Preferences separator [NSMenuItem separatorItem]
            NSMenuItem *betweenItemsAndPreferences = [NSMenuItem separatorItem];
            
            [betweenItemsAndPreferences setTag: tag];
            
            [self.statusMenu insertItem: betweenItemsAndPreferences atIndex: position];
            
        }
        
        position++;
      
    // Remove
    } else {
        
        NSMenuItem *removeIfExists = [self.statusMenu itemWithTag: tag];
        if (removeIfExists != nil)
        {
            [self.statusMenu removeItem: removeIfExists];
        }
        
    }
    

    
}

/*! Handle menu building */
- (void) forceRefreshMenu {
    
    [self.statusMenu removeAllItems];
    
    [self refreshMenu];
    
}

- (void) refreshMenu {

    
    // We may want to give up on the menu before we start
    if (self.items == nil || [self.items count] == 0)
    {
        
        // Remove the menu
        [self.statusItem setMenu: nil];
        
        return;
        
    } else {

        // Reattach if it's missing
        if ([self.statusItem menu] == nil)
        {
            [self.statusItem setMenu: self.statusMenu];
        }
        
    }
    
    // Keep track of where we are, move forward when we
    // create an item or confirm an item exists
    NSUInteger position = 0;
    
    // If we're not showing the temperature in the status bar, show it in the menu
    if (![self.settings showTemperatureInStatusBar] && [self temperaturesForDisplay] != nil)
    {
        NSArray *temperatures = [self temperaturesForDisplay];
        for (NSDictionary *temperature in temperatures) {
            
            // Find a possible item
            NSMenuItem *temperatureItem = [self.statusMenu itemWithTag: 200 + [temperatures indexOfObject: temperature]];
            
            // Find the string we need
            NSString *temperatureTitle = [NSString stringWithFormat: @"%@ – %@", [temperature objectForKey: @"temperature"], [temperature objectForKey: @"name"] ];
            
            // Add it if it doesn't exist
            if (temperatureItem == nil)
            {
                
                temperatureItem = [[NSMenuItem alloc] initWithTitle: temperatureTitle
                                           action: nil
                                    keyEquivalent: @""];
                
                [self.statusMenu insertItem: temperatureItem atIndex: position];
            
            } else {
                
                [temperatureItem setTitle: temperatureTitle];
                
            }
            
            position ++;

        }
        
        
        [self statusMenuSeparatorItemWithTag: 300 atPosition: position shouldExist: YES];
        position ++;
    }
    
    // Items
    for (NSDictionary *item in self.items)
    {
        
        NSUInteger itemTag = (100 + [self.items indexOfObject: item]);
        
        // Does this item already exist?
        NSMenuItem *itemMenuItem = [self.statusMenu itemWithTag: itemTag];
        
        // Create a new one if it doesn't exist
        if (itemMenuItem == nil)
        {
            
            // Create the item
            itemMenuItem = [[NSMenuItem alloc] initWithTitle: [item objectForKey: @"label"]
                                                      action: @selector(itemClick:)
                                               keyEquivalent: @""];
            
            // Set the tag
            [itemMenuItem setTag: itemTag];
            
            // Add the item
            [self.statusMenu insertItem: itemMenuItem atIndex: position];
        }
        
        // Set the on off status
        if ([[item objectForKey: @"status"] isEqualToString: @"on"])
        {
            [itemMenuItem setState: NSOnState];
        } else {
            [itemMenuItem setState: NSOffState];
        }
        
        // Move forward
        position++;
        
    }
    
    // Separator
    int betweenItemsAndPreferencesTag = 1;
    if ([self.items count] > 0)
    {

        if ([self.statusMenu itemWithTag: betweenItemsAndPreferencesTag] == nil)
        {
        
            // Preferences separator [NSMenuItem separatorItem]
            NSMenuItem *betweenItemsAndPreferences = [NSMenuItem separatorItem];
            
            [betweenItemsAndPreferences setTag: betweenItemsAndPreferencesTag];
            
            [self.statusMenu insertItem: betweenItemsAndPreferences atIndex: position];
            
        }
            
        position++;
        
    } else {
        
        // Remove it
        NSMenuItem *removeIfExists = [self.statusMenu itemWithTag: betweenItemsAndPreferencesTag];
        if (removeIfExists != nil)
        {
            [self.statusMenu removeItem: removeIfExists];
        }
        
    }
    
    // Preferences
    int preferencesTag = 2;
    if ([self.statusMenu itemWithTag: preferencesTag] == nil)
    {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle: @"Preferences..."
                                                      action: @selector(showPreferences)
                                               keyEquivalent: @","];
        
        [item setTag: preferencesTag];
        
        [item setKeyEquivalentModifierMask: NSCommandKeyMask];
        
        [self.statusMenu insertItem: item atIndex: position];
       
    }
    
    position ++;
   
    
    // Quit Separator
    int quitSeparatorTag = 3;
    if ([self.statusMenu itemWithTag: quitSeparatorTag] == nil)
    {
        NSMenuItem *quitSeparator = [NSMenuItem separatorItem];
        [quitSeparator setTag: quitSeparatorTag];
        
        [self.statusMenu insertItem: quitSeparator atIndex: position];
    }
  
    position ++;
    
    // Quit
    int quitTag = 4;
    if ([self.statusMenu itemWithTag: quitTag] == nil)
    {
        
        NSMenuItem *quit = [[NSMenuItem alloc] initWithTitle: @"Quit"
                                                      action: @selector(terminate:)
                                               keyEquivalent: @"q"];
        
        [quit setTag: quitTag];
        
        [self.statusMenu insertItem: quit atIndex: position];
        
    }
    
    position ++;
    


}


- (void) refreshStatusItem
{
    
    // Show the temperature
    if ([self.settings showTemperatureInStatusBar])
    {
        
        [self.statusItem setImage: nil];
        [self.statusItem setAlternateImage: nil];
        
        [self.statusItem setTitle: [self temperatureInScale]];
        
    // Show the icon
    } else {
        
        [self.statusItem setTitle: nil];
        [self.statusItem setImage: [NSImage imageNamed: @"StatusBarItem"]];
        [self.statusItem setAlternateImage: [NSImage imageNamed: @"StatusBarItemAlt"]];
        
    }
    
}

- (NSArray *)temperaturesForDisplay
{
    NSMutableArray *temperatures = [[NSMutableArray alloc] init];
    
    // If we don't have any temperatures yet
    if (self.temperatures == nil)
    {
        return nil;
    }

    // Each temperature
    for (NSDictionary *sensor in self.temperatures) {
        
        NSNumber *temperatureNumber = [sensor objectForKey: @"value"];
        
        if (temperatureNumber == nil)
        {
            continue;
        }
            
        // Convert to long
        long temperature = [temperatureNumber longValue];
        
        // Convert to celsius if requested
        if ([self.settings showTemperatureInCelsius])
        {
            temperature = (temperature - 32) * (5.0 / 9.0);
        }
        
        // Add a dictionary to our array
        [temperatures addObject: [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSString stringWithFormat: @"%ld°", temperature], @"temperature",
                                  [sensor objectForKey: @"name"], @"name",
                                  nil]];

    }

    return temperatures;
    
}

- (NSString *) temperatureInScale
{
    
    // If we don't have any temperatures yet
    if (self.temperatures == nil)
    {
        
        // Display a placeholder
        return @"--°";
        
    }
    
    // Look for the temperature
    NSNumber *temperatureNumber;
    
    // Display the temperature
    if (! [[self.settings temperatureId] isEqualToString: @""])
    {
        
        NSString *sensorId = [self.settings temperatureId];

        for (NSDictionary *sensor in self.temperatures) {
            
            if ([[sensor objectForKey: @"id"] isEqualToString: sensorId])
            {
                temperatureNumber = [sensor objectForKey: @"value"];
                continue;
            }
            
        }
        
    }
    
    // If temperature number is still nil, then just use the first object
    if (temperatureNumber == nil)
    {
        temperatureNumber = [[self.temperatures firstObject] objectForKey: @"value"];
    }
    
    // If we still don't have anything, whatever we do, don't show crazy long values
    if (temperatureNumber == nil)
    {
        return @"--°";
    }
    
    // Convert to long
    long temperature = [temperatureNumber longValue];

    // Convert to celsius if requested
    if ([self.settings showTemperatureInCelsius])
    {
        temperature = (temperature - 32) * (5.0 / 9.0);
    }
    
    return [NSString stringWithFormat: @"%ld°", temperature];
    


}

/*! Handle status bar */
- (void)readyForApiRequests:(AKSmartThings *)sender
{
    
    // Find all the info!
    [self requestUpdateFromServer];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval: (60.0)
                                                  target: self
                                                selector: @selector(requestUpdateFromServer)
                                                userInfo: nil
                                                 repeats: YES];
    
    [self.timer setTolerance: 12.0];
    
    
}

- (void) debugFound: (id)json
{
    NSLog(@"Debug: %@", json);
}

/*! Request an update from server */
- (void) requestUpdateFromServer
{

    if (self.settings.accessToken)
    {
    
        [self.things getJSONFor: @"updateItemsAndTemperature" withCallback: @selector(itemsAndTemperatureFound:)];
        
    }

}

/*! Update the interface from SmartThings */
- (void) itemsAndTemperatureFound: (id) json
{

    NSArray *items = [json objectForKey: @"items"];
    self.temperatures = [json objectForKey: @"temperatures" ];
    
    NSMutableArray *allItems = [[NSMutableArray alloc] init];
    
    for (NSDictionary *item in items) {

        // Save the items for building menus later
        [allItems addObject: [NSDictionary dictionaryWithObjectsAndKeys:
                                [item objectForKey: @"id"],    @"id",
                                [item objectForKey: @"name"],  @"label",
                                [item objectForKey: @"state"], @"status",
                                nil]];
        
    }
    
    // Set items
    self.items = allItems;
    
    [self refreshPreferences];
    
    // Refresh the interface
    [self refreshInterface];
    
}


- (void) itemClick: (NSMenuItem *) sender
{
    
    NSDictionary *item = [self.items objectAtIndex: ([sender tag] - 100)];
    
    // Find the item ID
    NSString *itemId = [item objectForKey: @"id"];
    
    // Toggle the state
    NSString *itemState;
    
    if ([[item objectForKey: @"status"] isEqualToString: @"off"]) {
        
        itemState = @"on";
    
    } else {
     
        itemState = @"off";
    
    }
    
    [self.things getJSONFor: [NSString stringWithFormat: @"itemChangeToState/%@/%@", itemId, itemState]
               withCallback: @selector(itemsAndTemperatureFound:)];
    
}


- (IBAction)authorizeButton:(id)sender {
    
    // Request use
    [self authorize];
    
}


- (void)handleAccessToken:(NSString *)accessToken
{
    // Show that authorization was successful
    [self authorized];
    
    self.settings.accessToken = accessToken;
    
}


/*! Load preferences - this only happens the first time the app loads */
- (void)loadPreferences 
{
    
    // Load in our preferences
    [self.preferencesShowTemperatureInStatusBar setIntegerValue: [self.settings showTemperatureInStatusBar] ];
    
    [self.preferencesTemperatureScale selectItemWithTag: [self.settings showTemperatureInCelsius]];
    
    // Set the OAuth fields
    if (self.settings.clientId)
    {
        [self.preferencesClientId setStringValue: self.settings.clientId];
    }
    
    if (self.settings.clientSecret)
    {
        [self.preferencesClientSecret setStringValue: self.settings.clientSecret];
    }
    
    [self validateOAuthFields];

    if (self.settings.accessToken != nil)
    {
        [self authorized];
        
    }
    
}

/*! Refresh preferences - call whenever there should be a UI change in preferences */
- (void)refreshPreferences
{
    
    [self validateOAuthFields];
    
    
    /***************
     * General Tab |
     **************/
    
    if ([self.settings showTemperatureInStatusBar])
    {
        [self.preferencesTemperatureSensor setEnabled: YES];
    } else {
        [self.preferencesTemperatureSensor setEnabled: NO];
    }
    
    // Load in temperature items
    if (self.temperatures != nil) {

        [self.preferencesTemperatureSensor removeAllItems];
        
        for (NSDictionary *sensor in self.temperatures) {
            
            // Check if there are any items with this name already
            int tries = 0;
            NSString *sensorName = [sensor objectForKey: @"name"];
            NSString *displayName = sensorName;
            
            while ([self.preferencesTemperatureSensor itemWithTitle: displayName]) {
                tries ++;
                displayName = [NSString stringWithFormat: @"%@ %d", sensorName, tries];
            }
            
            // Add it to the popup
            [self.preferencesTemperatureSensor addItemWithTitle: displayName];
            
            // Add it to the lookup dictionary
            [self.preferencesTemperatureSensorTitleToId setObject: [sensor objectForKey: @"id"] forKey:displayName];
            
            // If this is our item, select it
            if ([self.settings.temperatureId isEqualToString: [sensor objectForKey: @"id"]])
            {
                [self.preferencesTemperatureSensor selectItemWithTitle: displayName];
            }
            
        }
        
    }

    // Start at login?
    if ([self.launch loginItemExists])
    {
        [self.preferencesStartAtLogin setState: NSOnState];
    } else {
        [self.preferencesStartAtLogin setState: NSOffState];
    }
        
    /***************
     | Account Tab *
     **************/
    
    if ([self.settings accessToken])
    {
        
        [self.preferencesClientId setEnabled: NO];
        [self.preferencesClientSecret setEnabled: NO];

        [self.statusLabel setStringValue: @"Connected to SmartThings"];
        [self.preferencesAccountStatusImage setImage: [NSImage imageNamed: @"green"]];
        [self.authorizeButton setTitle: @"Reauthorize"];
        [self.authorizeButton setImage: [NSImage imageNamed: @"NSRefreshTemplate"]];
        [self.preferencesDisconnect setHidden: NO];

    } else {
        
        [self.preferencesClientId setEnabled: YES];
        [self.preferencesClientSecret setEnabled: YES];
        
        [self.statusLabel setStringValue: @"Not connected to SmartThings"];
        [self.preferencesAccountStatusImage setImage: [NSImage imageNamed: @"gray"]];
        [self.authorizeButton setTitle: @"Authorize"];
        [self.authorizeButton setImage: nil];
        [self.preferencesDisconnect setHidden: YES];

    }
    
}

/*! Show preferences - call only to show the preferences dialog */
- (void)showPreferences
{
    
    [self.window makeKeyAndOrderFront: self];
    [NSApp activateIgnoringOtherApps: YES];

}

/*! Clear preferences */
- (void)clearPreferences
{
    [self.preferencesTemperatureSensor removeAllItems];
    [self.preferencesClientId setStringValue: @""];
    [self.preferencesClientSecret setStringValue: @""];

}

- (IBAction)preferencesDisconnect:(NSButton *)sender {

    // Remove the access token
    self.settings.accessToken = nil;
    self.temperatures = nil;
    self.items = nil;
    
    [self forceRefreshMenu];

}

-(bool)looksLikeOAuth: (NSString *)prospect
{
    if (prospect == nil)
    {
        return NO;
    }
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern: @".+-.+-.+-.+-.+" options: 0 error: nil];
    NSUInteger looksLikeOAuth = [regex numberOfMatchesInString: prospect options: 0 range: NSMakeRange(0, [prospect length])];
    
    return looksLikeOAuth ? YES : NO;
}

-(void)controlTextDidChange:(NSNotification*)aNotification
{
    
    NSLog(@"%@", [self.preferencesClientSecret stringValue]);
    
    // Validate on each change
    [self validateOAuthFields];

    // Save settings
    [self.settings setClientId: [self.preferencesClientId stringValue]];
    [self.settings setClientSecret: [self.preferencesClientSecret stringValue]];

    // Update things
    self.things.clientId = self.settings.clientId;
    self.things.clientSecret = self.settings.clientSecret;
    
}

-(void)viewInstructions:(NSButton *)sender
{
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"https://github.com/alexking/StatusThing/blob/master/README.md"]];
}

/* OAuth Validation */
-(bool)validateOAuthClientId
{
    bool clientIdValid = [self looksLikeOAuth: [self.preferencesClientId stringValue]];
    
    if (clientIdValid)
    {
        [self.preferencesClientIdStatus setImage: [NSImage imageNamed: @"green"]];
    } else {
        [self.preferencesClientIdStatus setImage: [NSImage imageNamed: @"gray"]];
    }
    
    return clientIdValid;
}

-(bool)validateOAuthClientSecret
{
    bool clientSecretValid = [self looksLikeOAuth: [self.preferencesClientSecret stringValue]];

    // Handle UI changes
    if (clientSecretValid)
    {
        [self.preferencesClientSecretStatus setImage: [NSImage imageNamed: @"green"]];
    } else {
        [self.preferencesClientSecretStatus setImage: [NSImage imageNamed: @"gray"]];
    }
    
    return clientSecretValid;
}

-(bool)validateOAuthFields
{
    
    // Validate both
    bool clientIdValid = [self validateOAuthClientId];
    bool clientSecretValid = [self validateOAuthClientSecret];
    bool oAuthValid = (clientIdValid && clientSecretValid);
    
    // Handle UI changes
    if (oAuthValid)
    {
        [self.authorizeButton setEnabled: YES];
    }
    
    return oAuthValid;
}


/* Tab Switching */
- (IBAction)preferencesGeneral:(NSToolbarItem *)sender
{
    [self.preferenceTabs selectTabViewItemWithIdentifier: [sender itemIdentifier] ];
}

- (IBAction)preferencesAccount:(NSToolbarItem *)sender
{
    [self.preferenceTabs selectTabViewItemWithIdentifier: [sender itemIdentifier] ];
}

- (IBAction)preferencesUpdates:(NSToolbarItem *)sender {
    [self.preferenceTabs selectTabViewItemWithIdentifier: [sender itemIdentifier] ];
}


/* Saving Preferences */
- (IBAction)preferencesShowTemperatureInStatusBar:(NSButton *)sender
{
    [self.settings setShowTemperatureInStatusBar: [sender integerValue]];
    
    [self forceRefreshInterface];
    
}

- (IBAction)preferencesTemperatureScale:(NSPopUpButton *)sender
{
    
    [self.settings setShowTemperatureInCelsius: [[sender selectedItem] tag]];

    [self forceRefreshInterface];
    
}

- (IBAction)preferencesTemperatureSensor:(NSPopUpButton *)sender
{
    
    self.settings.temperatureId = [self.preferencesTemperatureSensorTitleToId objectForKey: [[sender selectedItem] title]];
    
    [self forceRefreshInterface];
}

- (IBAction)preferencesStartAtLogin:(NSButton *)sender {

    if ([sender state] == NSOffState)
    {
        [self.launch removeLoginItem];
    } else {
        [self.launch addLoginItem];
    }

    
    
}


- (IBAction)preferencesViewAbout:(NSButton *)sender {
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"https://github.com/alexking/StatusThing/wiki/About-Page"]];
}

/* Termination */
- (void)applicationWillTerminate:(NSNotification *)notification
{
    
    // Clean up our status bar
    [[NSStatusBar systemStatusBar] removeStatusItem: self.statusItem];
    
}



@end
