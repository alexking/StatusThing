
#import <Cocoa/Cocoa.h>
#import <AKSmartThings/AKSmartThings.h>
#import <CocoaHTTPServer/HTTPServer.h>
#import "AKSettings.h"
#import "AKLaunchItem.h"

@interface AKAppDelegate : NSObject <NSApplicationDelegate, AKSmartThingsDelegate, NSTextDelegate>

@property (assign) IBOutlet NSWindow *window;

// Library Instances
@property (strong) AKSmartThings *things;
@property (strong) AKSettings *settings;
@property (strong) AKLaunchItem *launch; 

// State management
@property NSMutableArray *items;
@property NSMutableArray *temperatures; 
@property NSNumber *selectedTemperatureId;

//@property (nonatomic) NSString *clientId;
//@property NSString *clientSecret;

// Interface Items
@property NSStatusItem *statusItem;
@property NSMenu *statusMenu;
@property (weak) IBOutlet NSTextField *statusLabel;
@property (weak) IBOutlet NSButton *authorizeButton;
@property (weak) IBOutlet NSTabView *preferenceTabs;
@property (weak) IBOutlet NSToolbar *preferencesToolbar;

@property NSTimer *timer;

-(void)controlTextDidChange:(NSNotification*)aNotification;

// Preferences
- (IBAction)authorizeButton:(id)sender;

- (IBAction)preferencesGeneral:(NSToolbarItem *)sender;
- (IBAction)preferencesAccount:(NSToolbarItem *)sender;
- (IBAction)preferencesShowTemperatureInStatusBar:(NSButton *)sender;
- (IBAction)preferencesTemperatureScale:(NSPopUpButton *)sender;
- (IBAction)preferencesTemperatureSensor:(NSPopUpButton *)sender;

@property (weak) IBOutlet NSButton *preferencesStartAtLogin;
- (IBAction)preferencesStartAtLogin:(NSButton *)sender;


@property (weak) IBOutlet NSImageView *preferencesClientIdStatus;
@property (weak) IBOutlet NSImageView *preferencesClientSecretStatus;

- (void)handleAccessToken:(NSString *)accessToken;

- (IBAction)viewInstructions:(NSButton *)sender;

@property (weak) IBOutlet NSTextField *preferencesClientId;
@property (weak) IBOutlet NSTextField *preferencesClientSecret;

@property (weak) IBOutlet NSPopUpButton *preferencesTemperatureScale;
@property (weak) IBOutlet NSButton *preferencesShowTemperatureInStatusBar;
@property (weak) IBOutlet NSImageView *preferencesAccountStatusImage;
@property (weak) IBOutlet NSPopUpButton *preferencesTemperatureSensor;

@property (weak) IBOutlet NSButton *preferencesDisconnect;
- (IBAction)preferencesDisconnect:(NSButton *)sender;


@property NSMutableDictionary *preferencesTemperatureSensorTitleToId;

@end
