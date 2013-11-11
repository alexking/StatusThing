
#import "AKAppDelegate.h"

// User Preferences
NSString * const kShowTemperatureInStatusBar = @"showTemperatureInStatusBar";
NSString * const kShowTemperatureInCelsius   = @"showTemperatureInCelsius";
NSString * const kSelectedTemperatureId      = @"selectedTemperatureId";

// Other Constants
NSString * const kAppName      = @"StatusThing";

// Client ID and Secret (shh)
NSString * const kClientId     = @"543edf56-3f4b-4dfa-b5ae-64dc6273845a";
NSString * const kClientSecret = @"b53a0eda-0472-4268-b0b8-24bf8eba3d0d";

@implementation AKAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

    // Register our default defaults
    NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool: YES], kShowTemperatureInStatusBar,
                                [NSNumber numberWithBool: YES], kShowTemperatureInCelsius,
                                @"", kSelectedTemperatureId,
                              nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults: defaults];
    
    // Setup
    self.items = [[NSMutableArray alloc] init];
    self.preferencesTemperatureSensorTitleToId = [[NSMutableDictionary alloc] init];
    
    // Use AKSmartThings
    self.things = [[AKSmartThings alloc] initWithClientId: kClientId];
    self.things.delegate = self; 
    [self.things setPort: 2323];
    
    // Lets use the application url scheme feature
    self.things.applicationUrlScheme = @"statusthing";
    
    // Look for an existing access token
    self.accessToken = [RFKeychain passwordForAccount: kAppName service: @"SmartThings"];

    // Setup our status bar item
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength: NSVariableStatusItemLength];
    [self.statusItem setHighlightMode: YES];
    
    // Handles temperature / icon display
    [self refreshStatusItem];
    
    // Setup the menu for the status bar item
    self.statusMenu = [[NSMenu alloc] initWithTitle: @"Menu"];
    [self.statusItem setMenu: self.statusMenu];
    
    // If we have an access token
    if (self.accessToken != nil) {

        // Provide AKSmartThings with the access token
        [self.things setAccessToken: self.accessToken];
        
        // Set preferences default to general
        [self.preferencesToolbar setSelectedItemIdentifier: @"general"];
        [self.preferenceTabs selectTabViewItemWithIdentifier: @"general"];
     
        
    }
    else
    {
        // If we don't have the access token, start connecting and show preferences on the account tab
        [self.preferencesToolbar setSelectedItemIdentifier: @"account"];
        [self.preferenceTabs selectTabViewItemWithIdentifier: @"account"];

        // Begin authorization
        [self authorize];
        
        [self showPreferences];
    }
   
    // Build the menu
    [self refreshMenu];
}

- (void) authorize {
    
    bool success = [self.things askUserForPermissionUsingClientSecret: kClientSecret];
    
    if (!success)
    {
        
        // Failure
        [self.statusLabel setStringValue: @"Unable to authorize – please make sure port 2323 is available"];
        
    }

}

- (void) authorized {
    
    [self.statusLabel setStringValue: @"Connected to SmartThings"];
    [self.preferencesAccountStatusImage setImage: [NSImage imageNamed: @"green"]];
    [self.authorizeButton setTitle: @"Reauthorize"];
    
}

- (void) refreshInterface
{
    [self refreshMenu];
    [self refreshStatusItem];
    [self refreshPreferences];
}

/*! Handle menu building */
- (void) refreshMenu {
    
    // Remove existing items
    [self.statusMenu removeAllItems];
    
    // If we're not showing the temperature in the status bar, show it in the menu
    if (![[[NSUserDefaults standardUserDefaults] objectForKey: kShowTemperatureInStatusBar] boolValue])
    {
        
        [self.statusMenu addItem: [[NSMenuItem alloc] initWithTitle: [self temperatureInScale]
                                                             action: nil
                                                      keyEquivalent: @""]];
     
        [self.statusMenu addItem: [NSMenuItem separatorItem]];
        
    }
 

    // Add items
    for (NSDictionary *item in self.items) {
        
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle: [item objectForKey: @"label"]
                                                          action: @selector(itemClick:)
                                                   keyEquivalent: @""];
        

        // Set the on off status
        if ([[item objectForKey: @"status"] isEqualToString: @"on"])
        {
            [menuItem setState: NSOnState];
        }
  
        
        [menuItem setTag: (100 + [self.items indexOfObject: item]) ];
        
        [self.statusMenu addItem: menuItem];
    }
    
    
    
    // Preferences
    [self.statusMenu addItem: [NSMenuItem separatorItem]];
    
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle: @"Preferences..."
                                                         action: @selector(showPreferences)
                                                  keyEquivalent: @","];
    
    [item setKeyEquivalentModifierMask: NSCommandKeyMask];
    
    [self.statusMenu addItem: item];
    
    // Quit
    [self.statusMenu addItem: [NSMenuItem separatorItem]];
    
    [self.statusMenu addItem: [[NSMenuItem alloc] initWithTitle: @"Quit"
                                                         action: @selector(terminate:)
                                                  keyEquivalent: @"q"]];


}


- (void) refreshStatusItem
{
    
    // Show the temperature
    if ([[[NSUserDefaults standardUserDefaults] objectForKey: kShowTemperatureInStatusBar] boolValue])
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

- (NSString *) temperatureInScale
{
    
    // If we don't have a temperature yet
    if (self.temperatures == nil)
    {
        
        // Display a placeholder
        return @"--°";
        
    } else {
        
        long temperature;
        
        // Display the temperature
        if ([[[NSUserDefaults standardUserDefaults] objectForKey: kSelectedTemperatureId] isEqualToString: @""])
        {
            temperature = [[[self.temperatures firstObject] objectForKey: @"value"] longValue];
        } else {
            NSString *sensorId = [[NSUserDefaults standardUserDefaults] objectForKey: kSelectedTemperatureId];

            for (NSDictionary *sensor in self.temperatures) {
                
                if ([[sensor objectForKey: @"id"] isEqualToString: sensorId])
                {
                    temperature = [[sensor objectForKey: @"value"] longValue];
                    continue;
                }
                
            }
            
        }
        
        
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey: kShowTemperatureInCelsius] boolValue]) {
            temperature = (temperature - 32) * (5.0 / 9.0);
        }
        
        return [NSString stringWithFormat: @"%ld°", temperature];
        
    }

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

    [self.things getJSONFor: @"updateItemsAndTemperature" withCallback: @selector(itemsAndTemperatureFound:)];

}

/*! Update the interface from SmartThings */
- (void) itemsAndTemperatureFound: (id) json
{
    NSLog(@"%@", json);
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
    
    [RFKeychain setPassword: accessToken account: kAppName service: @"SmartThings"];
    
}


- (void)applicationWillTerminate:(NSNotification *)notification
{

    [[NSStatusBar systemStatusBar] removeStatusItem: self.statusItem];

}


/* Preferences */
- (void)showPreferences
{
    
    // Load in our preferences
    [self.preferencesShowTemperatureInStatusBar setIntegerValue:
     [[[NSUserDefaults standardUserDefaults] objectForKey: kShowTemperatureInStatusBar] integerValue] ];

    [self.preferencesTemperatureScale selectItemWithTag:
        [[[NSUserDefaults standardUserDefaults] objectForKey: kShowTemperatureInCelsius] integerValue] ];
    

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
            if ([[[NSUserDefaults standardUserDefaults] objectForKey: kSelectedTemperatureId] isEqualToString: [sensor objectForKey: @"id"]])
            {
                [self.preferencesTemperatureSensor selectItemWithTitle: displayName];
            }
        }
        
      
        
    }
    
    if (self.accessToken != nil)
    {
        
        [self authorized];
    }
    
    [self refreshPreferences];
    
    [self.window makeKeyAndOrderFront: self];
    [NSApp activateIgnoringOtherApps: YES];
}


- (NSArray *)toolbarSelectableItemIdentifiers: (NSToolbar *)toolbar;
{
    return [NSArray arrayWithObjects: @"general", @"account", nil];
}


- (IBAction)preferencesGeneral:(NSToolbarItem *)sender
{
    [self.preferenceTabs selectTabViewItemWithIdentifier: [sender itemIdentifier] ];
}


- (IBAction)preferencesAccount:(NSToolbarItem *)sender
{
    [self.preferenceTabs selectTabViewItemWithIdentifier: [sender itemIdentifier] ];
}


- (IBAction)preferencesShowTemperatureInStatusBar:(NSButton *)sender {
    
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool: [sender integerValue]]
                                              forKey: kShowTemperatureInStatusBar];
    
    [self refreshInterface];
    
}


- (IBAction)preferencesTemperatureScale:(NSPopUpButton *)sender {
    
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithInteger: [[sender selectedItem] tag]]
                                              forKey: kShowTemperatureInCelsius];

    [self refreshInterface];
    
}

- (IBAction)preferencesTemperatureSensor:(NSPopUpButton *)sender {

    NSString *sensorId = [self.preferencesTemperatureSensorTitleToId objectForKey: [[sender selectedItem] title]];
    
    [[NSUserDefaults standardUserDefaults] setObject: sensorId
                                              forKey: kSelectedTemperatureId];

    [self refreshInterface];
}

- (void) refreshPreferences {
    
    if ([self.preferencesShowTemperatureInStatusBar integerValue] == 0)
    {
        [self.preferencesTemperatureSensor setEnabled: NO];
    } else {
        [self.preferencesTemperatureSensor setEnabled: YES];
    }
    
}

@end
