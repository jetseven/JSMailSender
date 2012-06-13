//
//  JSSMTPOperation.h
//  JSSimpleSender
//
//  Created by Steve Brokaw on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QRunLoopOperation.h"
@interface NSStream (JSSMTPAdditions)

+ (void)JSSMTPAdditions_getStreamsToHostNamed:(NSString *)hostName
                                         port:(NSInteger)port
                                  inputStream:(out NSInputStream __strong **)inputStreamPtr
                                 outputStream:(out NSOutputStream __strong **)outputStreamPtr;

@end

@protocol JSStreamOperationDelegate <NSObject>

- (void)streamDidReceiveResponse:(NSString *)result;
- (void)writeStreamSpaceAvailable;
- (void)operationDidStart;

@end

@interface JSStreamOperation : QRunLoopOperation <NSStreamDelegate> 

@property (weak) id<JSStreamOperationDelegate>delegate;
@property (readonly) BOOL tlsIsActive;

- (id)initWithHost:(NSString *)hostname port:(NSInteger)port;

- (void)openStreams;
- (void)closeStreams;
- (void)putCommand:(NSString *)command;
- (void)startTLS;

@end
