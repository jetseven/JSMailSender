//
//  JSSMTPConnection.h
//  JSSimpleSender
//
//  Created by Steve Brokaw on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSStreamOperation.h"

typedef void (^JSSMTPResponseCallback)(id response, NSError *error);

/** JSSMTPConnection objects are meant to be one-use objects used to send mail. The basic use of this class is
 to populate all the propertes with the necessary values and then send the using the methods mapped to the basic
 SMTP commands.*/

@interface JSSMTPConnection : NSObject <JSStreamOperationDelegate>
/** @name Properties */

/** The full text of the previous response */
@property (copy) NSString *lastReponse;

/** The host name of the SMTP relay */
@property (copy) NSString *relayHost;

/** The TCP port to connect to */
@property NSInteger port;

/** The email sender address */
@property (copy) NSString *senderEmail;

/** The recipients email address */
@property (copy) NSString *recipientEmail;
@property NSArray *recipientList;

/** The contets of the message to send */
@property (strong) NSData *message;

/** The username for SMTP authentication */
@property (copy) NSString *username;

/** The password for SMTP authentication */
@property (copy) NSString *password;

@property (readonly) BOOL tls;
@property (readonly) BOOL shouldStartTLS;

@property (readonly) BOOL auth;
@property (readonly) NSString *authMethod;
@property (readonly) BOOL eightBitMime;

@property (strong) void (^completionHandler)(NSError **error);

/** @name Creating and Initializing Connections */

/**
 @param fqdn The fully qualified domain name of the SMTP service.
 @param port The port for the server.
 */
- (id)initWithRelay:(NSString *)fqdn port:(NSInteger)port;

/**
 @param fqdn The fully qualified domain name of the SMTP service.
 @param port The port for the server.
 @param to The mail to.
 @param from The sender.
 @param message The message body.
 */

- (id)initWithRelay:(NSString *)fqdn port:(NSInteger)port recipient:(NSString *)to sender:(NSString *)from message:(NSData *)message;

/** @name Managing the connection */

/** Begin the finite state machine. If all the necessary properties are set, the connection will open the connection, take
 all appropriate action to send the mail, and close the connection.*/
- (void)beginWithCompletion:(void(^)(NSError *error))completionHandler;

/** Begin the connection. This will attempt to open the streams to the registered server and port */
- (void)connect;
/** Close the connection and shut down the streams. Once the streams are shut down, you need to create a new object to start again. */
- (void)disconnect;
/** Switches the state of the streams to support TLSv1. This can be done during an active connection, such as during a STARTTLS connection */
- (void)startTLS;

/**
 @name SMTP commnds
 */

/** Sends an EHLO command using the local name*/
- (void)sendEHLO;
/** Sends a MAIL FROM:<sender> command */
- (void)sendMAIL;
/** Sends a RCPT TO:<recipient> command */
- (void)sendRCPT;
/** Sends a STARTTLS to the server. */
- (void)sendSTARTTLS;
/** Sends a QUIT command to the server. Note that the stream must be disconnected separately. */
- (void)sendQUIT;
/** Sends an AUTH command, with the parameter based on the value stored in authMethod */
- (void)sendAUTH;
/** Send the Data */
- (void)sendDATA;
/** send the contents of the message. This method automatically appends a CRLF.CRLF string at the end to 
 mark the end of the message to the server*/
- (void)sendMessage;

/** @name Authentication*/

/** Starts a CRAM-MD5 authentication process. Currently unimplimented. */
- (void)startCRAMMD5;
/** Starts PLAIN login proces. The PLAIN login process is single-step, sending both username and password in a single transaction. */
- (void)startPLAIN;
/** Starts a LOGIN process. The LOGIN method is a two-step process. This step sends the username. sendLOGINPassword sends the password once the username has been accepted.*/
- (void)startLOGIN;
/** Sends the LOGIN  password, completing the login process */
- (void)sendLOGINPassword;


@end
