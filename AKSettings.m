
#import "AKSettings.h"

@implementation AKSettings

- (id) init
{
    self = [super init];
    
    if (self != nil)
    {
        
        [self defaultDefaults];
        
    }
    
    return self; 
    
}

- (void)defaultDefaults
{
    
    // Register our default defaults
    NSDictionary *defaults = @{ @"showTemperatureInStatusBar" : @YES,
                                @"showTemperatureInCelsius"   : @YES,
                                @"selectedTemperatureId"      : @""
                              };
    
    [[NSUserDefaults standardUserDefaults] registerDefaults: defaults];
    

}

/*! Remove all settings, passwords, and tokens */
- (void)reset
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"clientId"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"showTemperatureInStatusBar"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"showTemperatureInCelsius"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"temperatureId"];

    [[FXKeychain defaultKeychain] removeObjectForKey: @"clientSecret"];
    [[FXKeychain defaultKeychain] removeObjectForKey: @"accessToken"];

    [self defaultDefaults];
    
}

/* clientId */
- (void)setClientId: (NSString *)value
{
    [[NSUserDefaults standardUserDefaults] setObject: value forKey: @"clientId"];
}

- (NSString *)clientId
{
    return [[NSUserDefaults standardUserDefaults] objectForKey: @"clientId"];
}

 
/* clientSecret */
-(void)setClientSecret:(NSString *)clientSecret
{
    [FXKeychain defaultKeychain][@"clientSecret"] = clientSecret;
}

-(NSString *)clientSecret
{
    return [FXKeychain defaultKeychain][@"clientSecret"];
}

/* clientSecret */
-(void)setAccessToken:(NSString *)accessToken
{
    [FXKeychain defaultKeychain][@"accessToken"] = accessToken;
}

-(NSString *)accessToken
{
    return [FXKeychain defaultKeychain][@"accessToken"];
}


/* TemperatureInStatusBar */
-(void)setShowTemperatureInStatusBar: (bool)value
{
    [[NSUserDefaults standardUserDefaults] setObject: @(value)
                                              forKey: @"showTemperatureInStatusBar"];
}

-(bool)showTemperatureInStatusBar
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey: @"showTemperatureInStatusBar"] boolValue];
}

/* TemperatureInCelsius */
-(void)setShowTemperatureInCelsius: (bool)value
{
    [[NSUserDefaults standardUserDefaults] setObject: @(value)
                                              forKey: @"showTemperatureInCelsius"];
}

-(bool)showTemperatureInCelsius
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey: @"showTemperatureInCelsius"] boolValue];
}

/* TemperatureId */
- (void)setTemperatureId: (NSString *)value
{
    [[NSUserDefaults standardUserDefaults] setObject: value forKey: @"temperatureId"];
}

- (NSString *)temperatureId
{
    return [[NSUserDefaults standardUserDefaults] objectForKey: @"temperatureId"];
}



@end
