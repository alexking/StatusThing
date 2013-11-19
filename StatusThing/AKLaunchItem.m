/*
 * Handle launching at login
 * 
 * Based on the example code from -
 * http://cocoatutorial.grapewave.com/2010/02/creating-andor-removing-a-login-item
 *
 */

#import "AKLaunchItem.h"

@implementation AKLaunchItem

/*! Init using the default main bundle application URL */
- (id)init
{
    return [self initWithApplicationURL: [NSURL fileURLWithPath: [[NSBundle mainBundle] bundlePath]]];
}

/*! Init using a custom application URL */
- (id)initWithApplicationURL: (NSURL *)url
{
    self = [super init];
    if (self) {
        self.applicationURL = url;
    }
    return self;
}


-(void) addLoginItem
{
    
    // Refuse to add a login item that already exists
    if ([self loginItemExists])
    {
        NSLog(@"Login item for this application already exists");
        return;
    }
    
    // Find the URL of the app as a CFURLRef
    NSURL *appURL = self.applicationURL;
    CFURLRef appURLRef = (__bridge CFURLRef)appURL;
    
    // Find the list of login items
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    // Make sure we found some items
    if (loginItems)
    {
        // Insert our login item
        LSSharedFileListItemRef loginItemRef = LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemLast, NULL, NULL, appURLRef, NULL, NULL);
    
        // Release that login item
        if (loginItemRef)
        {
			CFRelease(loginItemRef);
        }
        
        // We know that it exists, so we may release it
        CFRelease(loginItems);
    }
    
}

-(bool) loginItemExists
{
    return [self findLoginItemAndRemove: NO];
}

-(void) removeLoginItem
{
    [self findLoginItemAndRemove: YES];
    
}

-(bool) findLoginItemAndRemove:(bool)remove
{
    
    // Find the URL of the app
    NSURL *appURL = self.applicationURL;
    
    // Find the list of login items
    LSSharedFileListRef loginItemsRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    // Make sure we found some items
    if (loginItemsRef)
    {
        
       
        
        // Define some variables we'll need
        UInt32 snapshotSeed;

        // Find an array of login items (transfering the ownership to our ARC managed NSArray)
        NSArray *loginItems = (__bridge_transfer NSArray *) LSSharedFileListCopySnapshot(loginItemsRef, &snapshotSeed);
        
        // Loop through the items
        for (id loginItem in loginItems)
        {
            
            // Convert the item into a LSSharedFileListItemRef (leaving ownership with ARC managed loginItem)
            LSSharedFileListItemRef loginItemRef = (__bridge LSSharedFileListItemRef) loginItem;
            
            
            // Try to resolve the item
            CFURLRef itemURLRef;
            if (LSSharedFileListItemResolve(loginItemRef, 0, &itemURLRef, NULL) == noErr)
            {
                
                // Check if this is our item
                NSURL *itemURL = (__bridge NSURL*)itemURLRef;
                if ([[appURL path] isEqualToString: [itemURL path]])
                {
                    if (remove)
                    {
                        LSSharedFileListItemRemove(loginItemsRef, loginItemRef);
                    } else {
                        return YES;
                    }
                }
                
                // Release the URL ref, since we never transfered ownership to ARC
                CFRelease(itemURLRef);
                
			}
            
        }
        
        // Release the login items ref
        CFRelease(loginItemsRef);
        
       
    }
    
    return NO;
    
}

@end