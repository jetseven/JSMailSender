//
//  JSSimpleSenderTests.m
//  JSSimpleSenderTests
//
//  Created by Steve Brokaw on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSMailSenderTests_iOS.h"
#import "JSSMTPConnection.h"

NSString * const kTestServerName = @"mail.mac.com";

@implementation JSMailSenderTests_iOS

- (void)setUp
{
    [super setUp];
    NSString *path = [NSString stringWithFormat:@"%s/JSSimpleSenderTests/ServerInfo.plist", __PROJECT_DIR__];
    STAssertNotNil(path, @"Couldn't load server info file.");
    _settings = [NSArray arrayWithContentsOfFile:path];
    done = NO;
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testConnection
{

    NSDictionary *dict = [_settings objectAtIndex:0];
    JSSMTPConnection *connection = [[JSSMTPConnection alloc] initWithRelay:[dict valueForKey:@"relayHost"]
                                                                      port:[[dict valueForKey:@"port"] integerValue]];
    connection.username = [dict valueForKey:@"username"];
    connection.password =  [dict valueForKey:@"password"];
    connection.recipientEmail = [dict valueForKey:@"recipientEmail"];
    connection.senderEmail = [dict valueForKey:@"senderEmail"];
    connection.message = [[dict valueForKey:@"message"] dataUsingEncoding:NSUTF8StringEncoding];
    
    [connection begin];
    

    STAssertTrue([self waitForCompletion:60], @"Timeout before done");
}


- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs {
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if([timeoutDate timeIntervalSinceNow] < 0.0)
            break;
    } while (!done);
    
    return done;
}

@end
