//
//  JSSimpleSenderTests.h
//  JSSimpleSenderTests
//
//  Created by Steve Brokaw on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
@class JSSMTPConnection;

@interface JSMailSenderTests_iOS : SenTestCase {
    JSSMTPConnection *_smtp;
    BOOL done;
}
@end
