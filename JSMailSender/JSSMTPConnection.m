//
//  JSSMTPConnection.m
//  JSSimpleSender
//
//  Created by Steve Brokaw on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSSMTPConnection.h"
#import "JSStreamOperation.h"
#import "JSUtilities.h"
#import "SMTP_sm.h"
#import "ITBase64Additions.h"

#pragma mark -

@interface JSSMTPConnection()

@property JSStreamOperation *op;
@property NSThread *runLoopThread;
@property SMTPContext *fsm;
@property BOOL beginWhenAvailable;
@property NSSet *ehloReply;

@property BOOL TLSActive;
@property BOOL TLSAvailable;
@property (readwrite) BOOL auth;
@property (readwrite) NSString *authMethod;
@property (readwrite) BOOL eightBitMime;

- (void)runLoopThreadEntry;

@end

#pragma mark -

@implementation JSSMTPConnection
@synthesize relayHost = _relay;
@synthesize port = _port;
@synthesize senderEmail = _from;
@synthesize recipientEmail = _to;
@synthesize message = _message;
@synthesize username = _username;
@synthesize password = _password;

@synthesize op = _op;
@synthesize runLoopThread = _runLoopThread;
@synthesize lastReponse = _lastReponse;
@synthesize fsm = _fsm;
@synthesize beginWhenAvailable = _beginWhenAvailable;
@synthesize ehloReply = _ehloReply;

@synthesize TLSActive = _TLSActive;
@synthesize TLSAvailable = _TLSAvailable;

@synthesize auth = _auth;
@synthesize authMethod = _authMethod;
@synthesize eightBitMime = _eightBitMime;

- (id)initWithRelay:(NSString *)fqdn port:(NSInteger)port recipient:(NSString *)to sender:(NSString *)from message:(NSData *)message
{
    if ((self = [super init])) {
        _op = [[JSStreamOperation alloc] initWithHost:fqdn port:port];
        _op.delegate = self;
        _runLoopThread = [[NSThread alloc] initWithTarget:self selector:@selector(runLoopThreadEntry) object:nil];
        _runLoopThread.name = @"org.jetseven.smtpconnection.runloopthread";
        [_runLoopThread start];
        _op.runLoopThread = _runLoopThread;
        [[NSOperationQueue mainQueue] addOperation:_op];
        _fsm = [[SMTPContext alloc] initWithOwner:self];
        _fsm.debugFlag = YES;
        _relay = fqdn;
        _port = port;
        _to = to;
        _from = from;
        _message = message;
        _TLSActive = NO;
        _TLSAvailable = NO;
        _beginWhenAvailable = NO;
    }
    return self;

}

- (id)initWithRelay:(NSString *)fqdn port:(NSInteger)port;
{
    return [self initWithRelay:fqdn port:port recipient:nil sender:nil message:nil];
}

- (id)init
{
    return [self initWithRelay:nil port:0 recipient:nil sender:nil message:nil];
}

- (BOOL) tls
{
    if (_op.tlsIsActive) {
        DLog(@"TLS Active in Operation");
    } else {
        DLog(@"no TLS in operation");
    }
    return _TLSAvailable && !_TLSActive;
}

- (void)begin
{
    @synchronized(self) {
        if (_op.state == kQRunLoopOperationStateExecuting) {
            [_fsm enterStartState];
        } else {
            DLog(@"Not ready to begin");
            self.beginWhenAvailable = YES;
        }
    }
}

- (void)connect
{
    DLog(@"connect");
    NSAssert(self.relayHost, @"Tried to connect to nil host name");
    [_op openStreams];
}

- (void)sendEHLO
{
    NSAssert(self.relayHost, @"Tried to connect to nil host name");
    long maxLen = sysconf(_SC_HOST_NAME_MAX) + 1;
    char *hostname = calloc(maxLen, sizeof(char));
    if (gethostname(hostname, 256))
        strlcpy(hostname, "localhost", sizeof(char) * maxLen);
    [_op putCommand:[NSString stringWithFormat:@"EHLO %s", hostname]];
    free(hostname);
}
- (void)sendMAIL
{
    [_op putCommand:[NSString stringWithFormat:@"MAIL FROM: <%@>", self.senderEmail]];
}
- (void)sendRCPT

{
    [_op putCommand:[NSString stringWithFormat:@"RCPT TO: <%@>", self.recipientEmail]];
}

- (void)sendQUIT
{
    [_op putCommand:@"QUIT"];
}

- (void)sendSTARTTLS
{
    [_op putCommand:@"STARTTLS"];
}

- (void)sendAUTH
{
    [_op putCommand:[NSString stringWithFormat:@"AUTH %@", self.authMethod]];
}

- (void)startPLAIN
{
    NSString *authStr = [NSString stringWithFormat:@"%@\0%@\0%@", self.username, self.username, self.password];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    [_op putCommand:[authData base64EncodedString]];
}

- (void)startLOGIN
{

    NSData *data = [self.username dataUsingEncoding:NSUTF8StringEncoding];
    [_op putCommand:[data base64EncodedString]];
    
}

- (void)sendLOGINPassword
{
    NSData *data = [self.password dataUsingEncoding:NSUTF8StringEncoding];
    [_op putCommand:[data base64EncodedString]];
}

- (void)startCRAMMD5
{
    NSAssert(NO, @"Auth method unimplimented");
}

- (void)sendDATA
{
    [_op putCommand:@"DATA"];
}

- (void)sendMessage
{
    NSString *eom = @"\r\n.\r\n";
    NSString *messageStr;
    if (self.eightBitMime) {
        messageStr = [[NSString alloc] initWithData:self.message encoding:NSUTF8StringEncoding];
    } else {
        messageStr = [[NSString alloc] initWithData:self.message encoding:NSASCIIStringEncoding];
    }
    [_op putCommand:[NSString stringWithFormat:@"%@%@", messageStr, eom]];
}


- (void)startTLS
{
    [_op startTLS];
}

- (void)disconnect
{
    [_op closeStreams];
}


- (void)runLoopThreadEntry
// This thread runs all of our network operation run loop callbacks.
{
    assert( ! [NSThread isMainThread] );
    DLog(@"Starting RunLoop thread");
    while (YES) {
        @autoreleasepool {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:30.]];
        }
    }
    assert(NO);
}


- (void)streamDidReceiveResponse:(NSString *)result
{
    DLog(@"Response: %@", result);
    self.lastReponse = result;
    NSScanner *resultScanner = [NSScanner scannerWithString:result];
    int code;
    BOOL scanSuccess = [resultScanner scanInt:&code];
    if (scanSuccess) {
        if (code > 199 && code < 300) {
            if ([_fsm.state isMemberOfClass:[JSSMTPMap_WaitingEHLOReply class]]) {
                _ehloReply = [NSSet setWithArray:[result componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
                DLog(@"Captured EHLO reply:%@", _ehloReply);
                [_ehloReply enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                    NSRange range = [(NSString *)obj rangeOfString:@"STARTTLS"];
                    if (range.location != NSNotFound) {
                        _TLSAvailable = YES;
                        DLog(@"TLS Supported")
                    }
                    range = [(NSString *)obj rangeOfString:@"AUTH"];
                    if (range.location != NSNotFound) {
                        self.auth = YES;
                        DLog(@"AUTH supported");
                        if /*( [(NSString *)obj rangeOfString:@"CRAM-MD5"].location != NSNotFound) {
                            self.authMethod = @"CRAMMD5";
                        } else if*/ ([(NSString *)obj rangeOfString:@"PLAIN"].location != NSNotFound) {
                            self.authMethod = @"PLAIN";
                        } else if ([(NSString *)obj rangeOfString:@"LOGIN"].location != NSNotFound) {
                            self.authMethod = @"LOGIN";
                        }
                        DLog(@"Selected AUTH method: %@", self.authMethod);
                    }
                    range = [(NSString *)obj rangeOfString:@"8BITMIME"];
                    if (range.location != NSNotFound) {
                        self.eightBitMime = YES;
                    }
                }];
            }
            [_fsm success];
        } else if (code > 99 && code < 200) {
            [_fsm error];
        } else if (code > 299 && code < 400) {
            [_fsm success];
        } else if ((code > 300 && code < 600)) {
            [_fsm failure];
        }
    }
}

- (void)writeStreamSpaceAvailable
{
    if ([_fsm.state isMemberOfClass:[JSSMTPMap_TLSStarting class]]) {
        _TLSActive = YES;
        [_fsm success];
    }
}

- (void)operationDidStart
{
    //[_fsm enterStartState];

    @synchronized(self){
        DLog(@"OperationDidStart");
        if (self.beginWhenAvailable) {
            DLog(@"Entering Start State");
            [_fsm enterStartState];
        }
    }
}

- (void)dealloc {
    DLog(@"Dealloc");
}

@end
