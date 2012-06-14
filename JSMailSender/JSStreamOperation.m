//
//  JSSMTPOperation.m
//  JSSimpleSender
//
//  Created by Steve Brokaw on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSStreamOperation.h"
#import "JSUtilities.h"

@implementation NSStream (JSSMTPAdditions)

+ (void)JSSMTPAdditions_getStreamsToHostNamed:(NSString *)hostName
                                         port:(NSInteger)port
                                  inputStream:(out NSInputStream __strong **)inputStreamPtr
                                 outputStream:(out NSOutputStream __strong **)outputStreamPtr
{
    CFReadStreamRef     readStream;
    CFWriteStreamRef    writeStream;
    
    assert(hostName != nil);
    assert( (port > 0) && (port < 65536) );
    assert( (inputStreamPtr != NULL) || (outputStreamPtr != NULL) );
    
    readStream = NULL;
    writeStream = NULL;
    
    CFStreamCreatePairWithSocketToHost(
                                       NULL,
                                       (__bridge CFStringRef) hostName,
                                       port,
                                       ((inputStreamPtr  != NULL) ? &readStream : NULL),
                                       ((outputStreamPtr != NULL) ? &writeStream : NULL)
                                       );
    
    if (inputStreamPtr != NULL) {
        *inputStreamPtr  = CFBridgingRelease(readStream);
    }
    if (outputStreamPtr != NULL) {
        *outputStreamPtr = CFBridgingRelease(writeStream);
    }
}

@end


@interface JSStreamOperation ()

@property NSInputStream * inputStream;
@property NSOutputStream * outputStream;
@property NSString * hostname;
@property NSInteger port;

- (void)connect_RunLoopThread;
- (void)putCommand_RunLoopThread:(NSString *)command;
- (void)disconnect_RunLoopThread;

@end

@implementation JSStreamOperation
@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;
@synthesize delegate = _delegate;
@synthesize hostname = _hostname;
@synthesize port = _port;

- (id)initWithHost:(NSString *)hostname port:(NSInteger)port
{
    if ((self = [super init])){
        _hostname = hostname;
        _port = port;
    }
    return self;
}

- (id)init
{
    NSAssert(NO, @"Use designate initializer");
    return nil;
}


- (void)operationDidStart
{
    DLog(@"Starting operation");
    [super operationDidStart];
    
    [NSStream JSSMTPAdditions_getStreamsToHostNamed:_hostname port:_port inputStream:&_inputStream outputStream:&_outputStream];
    if (!_inputStream || !_outputStream) {
        DLog(@"Nil stream!");
        NSAssert(NO , @"Nil input stream");
    }
    _inputStream.delegate = self;
    _outputStream.delegate = self;

    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"JSStreamOperationDidStart" object:self userInfo:nil];
    [self.delegate operationDidStart];

}

- (void)operationWillFinish
{
    [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
}


- (void)startTLS
{
    NSAssert(_inputStream, @"Tryting to start TLS on a nil input stream");
    NSAssert(_outputStream, @"Trying to start TLS on a nil output stream");
    DLog(@"Starting TLS...");
//    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
//                              (__bridge id)kCFStreamSocketSecurityLevelTLSv1, kCFStreamSSLLevel,
//                              kCFBooleanFalse, kCFStreamSSLValidatesCertificateChain,
//                              kCFBooleanTrue, kCFStreamSSLAllowsAnyRoot,
//                              nil];
//    CFReadStreamSetProperty((__bridge CFReadStreamRef)_inputStream, 
//                            kCFStreamPropertySSLSettings, (__bridge CFTypeRef)settings);
//    
//    CFWriteStreamSetProperty((__bridge CFWriteStreamRef)_outputStream, 
//                             kCFStreamPropertySSLSettings, (__bridge CFTypeRef)settings);

    
    [_inputStream setProperty:NSStreamSocketSecurityLevelTLSv1 forKey:NSStreamSocketSecurityLevelKey];
    [_outputStream setProperty:NSStreamSocketSecurityLevelTLSv1 forKey:NSStreamSocketSecurityLevelKey];
    [_inputStream open];
    [_outputStream open];

}

- (BOOL)tlsIsActive
{
    if ([[_inputStream propertyForKey:NSStreamSocketSecurityLevelKey] isEqualToString:NSStreamSocketSecurityLevelTLSv1]) {
        return YES;
    }
    return NO;
}
- (void)openStreams
{
    if ( ! [[NSThread currentThread] isEqual:self.actualRunLoopThread] ) {
        [self performSelector:@selector(connect_RunLoopThread) onThread:self.actualRunLoopThread withObject:nil waitUntilDone:NO];
    } else {
        [self connect_RunLoopThread];
    }
}

- (void)connect_RunLoopThread
{
    DLog(@"Opening Connection");
    NSAssert(_inputStream, @"Tried to connect a nil input stream");
    NSAssert(_outputStream, @"Tried to connect a nil output stream");
    [_inputStream open];
    [_outputStream open];

}
- (void)closeStreams
{
    if ( ! [[NSThread currentThread] isEqual:self.actualRunLoopThread] ) {
        [self performSelector:@selector(disconnect_RunLoopThread) onThread:self.actualRunLoopThread withObject:nil waitUntilDone:NO];
    } else {
        [self disconnect_RunLoopThread];
    }

}

- (void)disconnect_RunLoopThread
{
    DLog(@"Closing streams, stopping operation");
    [_inputStream close];
    [_outputStream close];
    [self finishWithError:nil];

}

- (void)putCommand:(NSString *)command
{
    if ( ! [[NSThread currentThread] isEqual:self.actualRunLoopThread]) {
        [self performSelector:@selector(putCommand_RunLoopThread:) onThread:self.actualRunLoopThread withObject:command waitUntilDone:NO];
    } else {
        [self putCommand_RunLoopThread:command];
    }
}

- (void)putCommand_RunLoopThread:(NSString *)command
{
    DLog(@"Command: %@", command);
    if ([_outputStream hasSpaceAvailable]) {
        if ( ! [command hasSuffix:@"\r\n"] ) {
            command = [command stringByAppendingString:@"\r\n"];
        }
        const char * cmd = [command UTF8String];
        NSUInteger len = [command lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        NSInteger res = [_outputStream write:(const uint8_t *)cmd maxLength:len];
        if (res == -1) {
            DLog(@"Error writing to stream: %@", [_outputStream streamError]);
        }
    
    }
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            //DLog(@"Stream Event: Open completed");
            break;
        }
        case NSStreamEventHasBytesAvailable: {
            uint8_t buf[512];
            NSInteger len;
            len = [(NSInputStream *)aStream read:buf maxLength:512];
            //DLog(@"Stream Event: Has bytes available with length: %li", len);

            NSString *res;
            if (len) {
                res = [[NSString alloc] initWithBytes:buf length:len encoding:NSASCIIStringEncoding];
                [self.delegate streamDidReceiveResponse:res];
            }
            break;
        }
        case NSStreamEventEndEncountered: {
            DLog(@"Stream Event: Stream ended event");
            [self finishWithError:nil];
            break;
        }
            
        case NSStreamEventHasSpaceAvailable: {
            //DLog(@"Stream Event: Space Available");
            [self.delegate writeStreamSpaceAvailable];
            break;
        }
        case NSStreamEventErrorOccurred: {
            NSError *error = [aStream streamError];
            NSLog(@"Stream Event: Error: %@", error);
            [self putCommand:@"QUIT"];
            [self finishWithError:error];
            break;
        }
        default: {
            DLog(@"Stream Event: Event: %ull", eventCode);
            break;
        }

    }
    
}
@end
