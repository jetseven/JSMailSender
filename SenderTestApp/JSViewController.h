//
//  JSViewController.h
//  SenderTestApp
//
//  Created by Steve Brokaw on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSSMTPConnection.h"

@interface JSViewController : UIViewController <UITextFieldDelegate>
- (IBAction)send:(id)sender;
- (IBAction)updateRelayHost:(UITextField *)sender;
- (IBAction)updatetRecipientEmail:(id)sender;
- (IBAction)updateSenderEmail:(id)sender;
- (IBAction)updateUsername:(id)sender;
- (IBAction)updatePassword:(id)sender;
- (IBAction)updateSubject:(id)sender;

@property (weak, nonatomic) IBOutlet UITextView *messageText;
@property (weak, nonatomic) IBOutlet UITextField *portText;
@property (weak, nonatomic) IBOutlet UITextField *subjectText;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@end
