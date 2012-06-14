/*
 * ex: set ro:
 * DO NOT EDIT.
 * generated by smc (http://smc.sourceforge.net/)
 * from file : SMTP.sm
 */


#import "statemap.h"

// Forward declarations.
@class JSSMTPMap;
@class JSSMTPMap_Connecting;
@class JSSMTPMap_WaitingEHLOReply;
@class JSSMTPMap_WaitingMAILReply;
@class JSSMTPMap_WaitingRCPTReply;
@class JSSMTPMap_WaitingSTARTTLSReply;
@class JSSMTPMap_TLSStarting;
@class JSSMTPMap_WaitingDATAReply;
@class JSSMTPMap_SendingData;
@class JSSMTPMap_ReadyToQuit;
@class JSSMTPMap_Disconnected;
@class JSSMTPMap_Default;
@class JSSMTPAuthMap;
@class JSSMTPAuthMap_StartingAuth;
@class JSSMTPAuthMap_WaitingLOGINReply;
@class JSSMTPAuthMap_WaitingCRAMMD5Reply;
@class JSSMTPAuthMap_WaitingPLAINReply;
@class JSSMTPAuthMap_WaitingAuthenticationResult;
@class JSSMTPAuthMap_Default;
@class JSSMTPConnectionState;
@class SMTPContext;
@class JSSMTPConnection;

@interface JSSMTPConnectionState : SMCState
{
}
- (void)Entry:(SMTPContext*)context;
- (void)Exit:(SMTPContext*)context;

- (void)authenticated:(SMTPContext*)context;
- (void)error:(SMTPContext*)context;
- (void)failure:(SMTPContext*)context;
- (void)success:(SMTPContext*)context;

- (void)Default:(SMTPContext*)context;
@end

@interface JSSMTPMap : NSObject
{
}
+ (JSSMTPMap_Connecting*)Connecting;
+ (JSSMTPMap_WaitingEHLOReply*)WaitingEHLOReply;
+ (JSSMTPMap_WaitingMAILReply*)WaitingMAILReply;
+ (JSSMTPMap_WaitingRCPTReply*)WaitingRCPTReply;
+ (JSSMTPMap_WaitingSTARTTLSReply*)WaitingSTARTTLSReply;
+ (JSSMTPMap_TLSStarting*)TLSStarting;
+ (JSSMTPMap_WaitingDATAReply*)WaitingDATAReply;
+ (JSSMTPMap_SendingData*)SendingData;
+ (JSSMTPMap_ReadyToQuit*)ReadyToQuit;
+ (JSSMTPMap_Disconnected*)Disconnected;
@end

@interface JSSMTPMap_Default : JSSMTPConnectionState
{
}
@end

@interface JSSMTPMap_Connecting : JSSMTPMap_Default
{
}
 -(void)Entry:(SMTPContext*)context;
- (void)error:(SMTPContext*)context;
- (void)failure:(SMTPContext*)context;
- (void)success:(SMTPContext*)context;
@end

@interface JSSMTPMap_WaitingEHLOReply : JSSMTPMap_Default
{
}
 -(void)Entry:(SMTPContext*)context;
- (void)authenticated:(SMTPContext*)context;
- (void)failure:(SMTPContext*)context;
- (void)success:(SMTPContext*)context;
@end

@interface JSSMTPMap_WaitingMAILReply : JSSMTPMap_Default
{
}
 -(void)Entry:(SMTPContext*)context;
- (void)error:(SMTPContext*)context;
- (void)failure:(SMTPContext*)context;
- (void)success:(SMTPContext*)context;
@end

@interface JSSMTPMap_WaitingRCPTReply : JSSMTPMap_Default
{
}
 -(void)Entry:(SMTPContext*)context;
- (void)error:(SMTPContext*)context;
- (void)failure:(SMTPContext*)context;
- (void)success:(SMTPContext*)context;
@end

@interface JSSMTPMap_WaitingSTARTTLSReply : JSSMTPMap_Default
{
}
 -(void)Entry:(SMTPContext*)context;
- (void)success:(SMTPContext*)context;
@end

@interface JSSMTPMap_TLSStarting : JSSMTPMap_Default
{
}
 -(void)Entry:(SMTPContext*)context;
- (void)success:(SMTPContext*)context;
@end

@interface JSSMTPMap_WaitingDATAReply : JSSMTPMap_Default
{
}
 -(void)Entry:(SMTPContext*)context;
- (void)success:(SMTPContext*)context;
@end

@interface JSSMTPMap_SendingData : JSSMTPMap_Default
{
}
- (void)error:(SMTPContext*)context;
- (void)failure:(SMTPContext*)context;
- (void)success:(SMTPContext*)context;
@end

@interface JSSMTPMap_ReadyToQuit : JSSMTPMap_Default
{
}
 -(void)Entry:(SMTPContext*)context;
- (void)success:(SMTPContext*)context;
@end

@interface JSSMTPMap_Disconnected : JSSMTPMap_Default
{
}
 -(void)Entry:(SMTPContext*)context;
- (void)Default:(SMTPContext*)context;
@end

@interface JSSMTPAuthMap : NSObject
{
}
+ (JSSMTPAuthMap_StartingAuth*)StartingAuth;
+ (JSSMTPAuthMap_WaitingLOGINReply*)WaitingLOGINReply;
+ (JSSMTPAuthMap_WaitingCRAMMD5Reply*)WaitingCRAMMD5Reply;
+ (JSSMTPAuthMap_WaitingPLAINReply*)WaitingPLAINReply;
+ (JSSMTPAuthMap_WaitingAuthenticationResult*)WaitingAuthenticationResult;
@end

@interface JSSMTPAuthMap_Default : JSSMTPConnectionState
{
}
@end

@interface JSSMTPAuthMap_StartingAuth : JSSMTPAuthMap_Default
{
}
 -(void)Entry:(SMTPContext*)context;
- (void)success:(SMTPContext*)context;
@end

@interface JSSMTPAuthMap_WaitingLOGINReply : JSSMTPAuthMap_Default
{
}
- (void)success:(SMTPContext*)context;
@end

@interface JSSMTPAuthMap_WaitingCRAMMD5Reply : JSSMTPAuthMap_Default
{
}
@end

@interface JSSMTPAuthMap_WaitingPLAINReply : JSSMTPAuthMap_Default
{
}
- (void)failure:(SMTPContext*)context;
- (void)success:(SMTPContext*)context;
@end

@interface JSSMTPAuthMap_WaitingAuthenticationResult : JSSMTPAuthMap_Default
{
}
- (void)failure:(SMTPContext*)context;
- (void)success:(SMTPContext*)context;
@end

@interface SMTPContext : SMCFSMContext
{
    JSSMTPConnection *_owner;
}
- (id)initWithOwner:(JSSMTPConnection*)owner;
- (id)initWithOwner:(JSSMTPConnection*)owner state:(SMCState*)aState;
- (JSSMTPConnection*)owner;
- (JSSMTPConnectionState*)state;

- (void)enterStartState;

- (void)authenticated;
- (void)error;
- (void)failure;
- (void)success;
@end


/*
 * Local variables:
 *  buffer-read-only: t
 * End:
 */
