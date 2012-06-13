JSMailSender
============

Intro
------

JSMailSender is a simple SMTP client for iOS and Mac OS X. If you need to send a quick
email or two without activating the iOS mail app, this project should help you out. If
you want to create the next great Mail client in IOS, keep looking. Or better yet,
fork and extend this project.

Rationale
------

For a while I have been maintaining a [fork](https://github.com/jetseven/skpsmtpmessage)
of the apparently abandoned [skpsmtpmessage](http://code.google.com/p/skpsmtpmessage/). 
Based on the feedback on that project, it still fills a need. I wasted to make the library work better
in the background, so I tried to integrate Quinn "The Eskimo!"'s class QRunLoopOperation,
which elegantly combines NSRunLoop-based APIs with NSOperations. But I was finding it hard
to make changes cleanly, mostly because of the complex conditional code used to manage the state
of the SMTP connection. I decided to do away with all the manual condition checking and
to use the [State Machine Compiler](http://smc.sourceforge.net/) to
generate the complex conditions of an SMTP connection. I decided the result was different
enough to merit a new project. I hope that by basing the code
on a state  machine, it will make it easier to accomodate new behaviors from mail server I haven't
been able to test against.

Current Status
------

The project will build and send mail. I am able to send mail using iCloud (me.com),
Gmail, and Yahoo! That said, there is still work to do.

**Working features**

* Start TLS
* PLAIN and LOGIN authentication
* Tested on common mail servers.

**Unimplemented or incomplete, but planned**

* No CRAM-MD5 authentication
* State Machine is incomplete.
    * Some transitions will leave a stream hanging in the open state.
    * Some transitions will throw an exception.
* Should be better integrated with the reachability APIs on iOS.
* Gracefully handle network timeouts.
* Documentation
* Better testing

**Non Features**

* MIME
* POP, IMAP
* SMTP Server

Acknowledgments
---------------

Apple DTS in general and Quinn in particular. The QRunLoopOperation class is copied
without modifications.

Colloquy project, for the Base64 code.

Ian Baird, for sksmtpmessage. Even though I created a new project, I still looked at his
code for a sanity check.