
#import "AKSettings.h"

@implementation AKSettings

- (id) init
{
    self = [super init];
    
    if (self != nil)
    {
        
        // Register our default defaults
        NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithBool: YES], @"showTemperatureInStatusBar",
                                  [NSNumber numberWithBool: YES], @"showTemperatureInCelsius",
                                  @"",                            @"selectedTemperatureId",
                                  nil];

        [[NSUserDefaults standardUserDefaults] registerDefaults: defaults];

        
    }
    
    return self; 
    
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
    [[FXKeychain defaultKeychain] setObject: clientSecret forKey: @"clientSecret"];
}

-(NSString *)clientSecret
{
    return [[FXKeychain defaultKeychain] objectForKey: @"clientSecret"];
}

/* clientSecret */
-(void)setAccessToken:(NSString *)accessToken
{
    [[FXKeychain defaultKeychain] setObject: accessToken forKey: @"accessToken"];
}

-(NSString *)accessToken
{
    return [[FXKeychain defaultKeychain] objectForKey: @"accessToken"];
}


/* TemperatureInStatusBar */
-(void)setShowTemperatureInStatusBar: (bool)value
{
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool: value]
                                              forKey: @"showTemperatureInStatusBar"];
}

-(bool)showTemperatureInStatusBar
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey: @"showTemperatureInStatusBar"] boolValue];
}

/* TemperatureInCelsius */
-(void)setShowTemperatureInCelsius: (bool)value
{
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool: value]
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
