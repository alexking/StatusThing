
#import <Cocoa/Cocoa.h>
#import <AKSmartThings/AKSmartThings.h>
#import <CocoaHTTPServer/HTTPServer.h>
#import <RFKeychain/RFKeychain.h>

@interface AKAppDelegate : NSObject <NSApplicationDelegate, AKSmartThingsDelegate>

@property (assign) IBOutlet NSWindow *window;

// Library Instances
@property (strong) AKSmartThings *things;

// State management
@property NSMutableArray *items;
@property NSMutableArray *temperatures; 
@property NSNumber *selectedTemperatureId;


@property NSString *accessToken;

// Interface Items
@property NSStatusItem *statusItem; 
@property NSMenu *statusMenu;
@property (weak) IBOutlet NSTextField *statusLabel;
@property (weak) IBOutlet NSButton *authorizeButton;
@property (weak) IBOutlet NSTabView *preferenceTabs;
@property (weak) IBOutlet NSToolbar *preferencesToolbar;

@property NSTimer *timer;

// Preferences
- (IBAction)authorizeButton:(id)sender;

- (IBAction)preferencesGeneral:(NSToolbarItem *)sender;
- (IBAction)preferencesAccount:(NSToolbarItem *)sender;
- (IBAction)preferencesShowTemperatureInStatusBar:(NSButton *)sender;
- (IBAction)preferencesTemperatureScale:(NSPopUpButton *)sender;
- (IBAction)preferencesTemperatureSensor:(NSPopUpButton *)sender;


- (void)handleAccessToken:(NSString *)accessToken;

@property (weak) IBOutlet NSPopUpButton *preferencesTemperatureScale;
@property (weak) IBOutlet NSButton *preferencesShowTemperatureInStatusBar;
@property (weak) IBOutlet NSImageView *preferencesAccountStatusImage;
@property (weak) IBOutlet NSPopUpButton *preferencesTemperatureSensor;

@property NSMutableDictionary *preferencesTemperatureSensorTitleToId;

@end
