
#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

@interface AKLaunchItem : NSObject

-(bool) loginItemExists;
-(void) addLoginItem;
-(void) removeLoginItem;

@property (strong) NSURL *applicationURL; 

@end
