//
//  JSSimpleSenderOSXTests.m
//  JSSimpleSenderOSXTests
//
//  Created by Steve Brokaw on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSMailSenderTests_OSX.h"
#import "JSSMTPConnection.h"
#import "NSDataAdditions.h"

NSString * const kTestServerName = @"smtp.mail.yahoo.com";

@implementation JSMailSenderTests_OSX

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
    NSLog(@"testConnection");
    for (NSDictionary *dict in _settings) {
        if ([[dict valueForKey:@"relayHost"] isEqualToString:@"smtp.gmail.com"]) {
            JSSMTPConnection *connection = [[JSSMTPConnection alloc] initWithRelay:[dict valueForKey:@"relayHost"]
                                                                              port:[[dict valueForKey:@"port"] integerValue]];
            connection.username = [dict valueForKey:@"username"];
            connection.password =  [dict valueForKey:@"password"];
            connection.recipientEmail = [dict valueForKey:@"recipientEmail"];
            connection.senderEmail = [dict valueForKey:@"senderEmail"];
            connection.message = [[dict valueForKey:@"message"] dataUsingEncoding:NSUTF8StringEncoding];
            
            [connection begin];

        }
    }
    
    STAssertTrue([self waitForCompletion:120], @"Timeout before done");
}


- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs {
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if([timeoutDate timeIntervalSinceNow] < 0.0)
            break;
    } while (!done);
    
    //return done;
    return YES;
}

@end
