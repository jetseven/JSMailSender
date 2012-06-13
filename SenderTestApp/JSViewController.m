//
//  JSViewController.m
//  SenderTestApp
//
//  Created by Steve Brokaw on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSViewController.h"

@interface JSViewController ()
@property JSSMTPConnection *connection;
@property NSString *relayHost;
@property NSString *recipientEmail;
@property NSString *senderEmail;
@property NSString *username;
@property NSString *password;

@end

@implementation JSViewController
@synthesize relayHost;
@synthesize recipientEmail;
@synthesize senderEmail;
@synthesize username;
@synthesize password;

@synthesize messageText;
@synthesize portText;
@synthesize subjectText;
@synthesize sendButton;

@synthesize connection;

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewDidUnload
{
    [self setSendButton:nil];
    [super viewDidUnload];
    [self setMessageText:nil];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)send:(id)sender {
    connection = [[JSSMTPConnection alloc] initWithRelay:self.relayHost port:[[self.portText text] integerValue]];
    connection.senderEmail = self.senderEmail;
    connection.recipientEmail = self.recipientEmail;
    connection.username = self.username;
    connection.password = self.password;
    
    connection.message = [[NSString stringWithFormat:@"To: %@\nFrom: %@\nDate: %@\nSubject: %@\n\n%@",
                           self.recipientEmail,
                           self.senderEmail,
                           [[NSDate date] descriptionWithLocale:nil],
                           [self.subjectText text],
                           [self.messageText text]] dataUsingEncoding:NSUTF8StringEncoding];

    [self.connection begin];
}

- (IBAction)updateRelayHost:(UITextField *)sender {
    self.relayHost = [sender text];

}

- (IBAction)updateRecipientEmail:(id)sender {
    self.recipientEmail = [(UITextField *)sender text];

}

- (IBAction)updateSenderEmail:(id)sender {
    self.senderEmail = [(UITextField *)sender text];
}

- (IBAction)updateUsername:(id)sender {
    self.username = [(UITextField *)sender text];

}

- (IBAction)updatePassword:(id)sender {
    self.password = [(UITextField *)sender text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
@end
