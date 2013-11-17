
#import <Foundation/Foundation.h>
#import <FXKeychain/FXKeychain.h>

@interface AKSettings : NSObject {
    
}

@property NSString *clientId;
@property NSString *clientSecret;
@property NSString *accessToken;

@property NSString *temperatureId;

-(void)setShowTemperatureInStatusBar: (bool)value;
-(bool)showTemperatureInStatusBar;
-(void)setShowTemperatureInCelsius: (bool)value;
-(bool)showTemperatureInCelsius;
- (void)reset;

@end
