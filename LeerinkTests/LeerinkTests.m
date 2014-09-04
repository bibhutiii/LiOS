//
//  LeerinkTests.m
//  LeerinkTests
//
//  Created by Ashish on 4/09/2014.
//  Copyright (c) 2014 leerink. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LRLoginViewController.h"

@interface LeerinkTests : XCTestCase
{
    LRLoginViewController *viewController;
}
@end

@implementation LeerinkTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    viewController = [storyboard instantiateViewControllerWithIdentifier:@"LRLoginViewController"];
     [viewController performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    XCTAssert(viewController.userNameTextField.text.length > 0, @"text field is not empty");
    XCTAssert(viewController.view, @"textPassword should be connected");
}


@end
