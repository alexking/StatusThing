
#import <XCTest/XCTest.h>
#import "AKSettings.h"

@interface AKTestSettings : XCTestCase

@property AKSettings *settings;

@end

@implementation AKTestSettings

- (void)setUp
{
    [super setUp];

    self.settings = [[AKSettings alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testClientId
{
    
    self.settings.clientId = @"123";
    
    XCTAssertTrue([self.settings.clientId isEqualToString: @"123"], @"testClientId");
    XCTAssertFalse([self.settings.clientId isEqualToString: @"1234"], @"testClientId");

    self.settings.clientId = nil;
    
}


- (void)testTemperatureId
{
    
    self.settings.temperatureId = @"123";
    
    XCTAssertTrue([self.settings.temperatureId isEqualToString: @"123"], @"testTemperatureId");
    XCTAssertFalse([self.settings.temperatureId isEqualToString: @"1234"], @"testTemperatureId");

    self.settings.temperatureId = nil;

    
}


- (void)testClientSecret
{
    
    self.settings.clientSecret = @"123";
    
    XCTAssertTrue([self.settings.clientSecret isEqualToString: @"123"], @"testClientSecret");
    XCTAssertFalse([self.settings.clientSecret isEqualToString: @"1234"], @"testClientSecret");
    
    self.settings.clientSecret = nil;
}

- (void)testAccessToken
{
    
    self.settings.accessToken = @"123";
    
    XCTAssertTrue([self.settings.accessToken isEqualToString: @"123"], @"testAccessToken");
    XCTAssertFalse([self.settings.accessToken isEqualToString: @"1234"], @"testAccessToken");
    
    self.settings.accessToken = nil;
}

- (void)testTemperatureInCelsius
{
    [self.settings setShowTemperatureInCelsius: YES];
    XCTAssertTrue([self.settings showTemperatureInCelsius], @"testShowTemperatureInStatusBar");

    [self.settings setShowTemperatureInCelsius: NO];
    XCTAssertFalse([self.settings showTemperatureInCelsius], @"testShowTemperatureInStatusBar");
}

- (void)testTemperatureInStatusBar
{
    [self.settings setShowTemperatureInStatusBar: YES];
    XCTAssertTrue([self.settings showTemperatureInStatusBar], @"setShowTemperatureInStatusBar");
    
    [self.settings setShowTemperatureInStatusBar: NO];
    XCTAssertFalse([self.settings showTemperatureInStatusBar], @"setShowTemperatureInStatusBar");

}

@end
