//
//  ISPPinnedNSURLSessionDelegate.h
//  Leerink
//
//  Created by Bibhuti on 29/06/17.
//  Copyright © 2017 leerink. All rights reserved.
//

/** Convenience class to automatically perform certificate pinning for NSURLSession.
 
 ISPPinnedNSURLSessionDelegate is designed to be subclassed in order to
 implement an NSURLSession class. The
 URLSession:didReceiveChallenge:completionHandler: method it implements
 will automatically validate that at least one the certificates pinned to the domain the
 connection is accessing is part of the server's certificate chain.
 
 */
@interface ISPPinnedNSURLSessionDelegate : NSObject

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler;

@end
