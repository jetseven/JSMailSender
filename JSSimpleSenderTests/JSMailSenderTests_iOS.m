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
    done = NO;
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testConnection
{
    [_smtp connect];
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
