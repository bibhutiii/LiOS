//
//  ISPPinnedNSURLConnectionDelegate.h
//  Leerink
//
//  Created by Bibhuti on 29/06/17.
//  Copyright © 2017 leerink. All rights reserved.
//



/** Convenience class to automatically perform certificate pinning for NSURLConnection.
 
 ISPPinnedNSURLConnectionDelegate is designed to be subclassed in order to
 implement an NSURLConnectionDelegate class. The
 connection:willSendRequestForAuthenticationChallenge: method it implements
 will automatically validate that at least one the certificates pinned to the domain the
 connection is accessing is part of the server's certificate chain.
 
 */
@interface ISPPinnedNSURLConnectionDelegate : NSObject

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

@end
