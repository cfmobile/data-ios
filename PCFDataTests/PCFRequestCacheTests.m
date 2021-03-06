//
//  PCFRequestCacheTests.m
//  PCFData
//
//  Created by DX122-XL on 2014-11-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <PCFData/PCFData.h>
#import "PCFRequestCache.h"
#import "PCFRequestCacheExecutor.h"
#import "PCFRequestCacheQueue.h"
#import "PCFPendingRequest.h"

@interface PCFRequestCache ()

- (void)executePendingRequests:(NSArray *)requests;

@end

@interface PCFRequestCacheTests : XCTestCase

@property NSString *key;
@property NSString *value;
@property NSString *token;
@property NSString *collection;
@property NSString *fallback;
@property int method;
@property BOOL force;

@end

@implementation PCFRequestCacheTests

- (void)setUp {
    [super setUp];
    
    self.key = [NSUUID UUID].UUIDString;
    self.value = [NSUUID UUID].UUIDString;
    self.token = [NSUUID UUID].UUIDString;
    self.collection = [NSUUID UUID].UUIDString;
    self.fallback = [NSUUID UUID].UUIDString;
    self.method = arc4random_uniform(3) + 1;
    self.force = arc4random_uniform(2);
}

- (PCFDataRequest *)createRequest {
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:self.value];
    return [[PCFDataRequest alloc] initWithMethod:self.method object:keyValue fallback:nil force:self.force];
}

- (void)testQueueRequest {
    PCFDataRequest *request = [self createRequest];
    id pending = OCMClassMock([PCFPendingRequest class]);
    PCFRequestCacheQueue *queue = OCMClassMock([PCFRequestCacheQueue class]);
    
    OCMStub([pending alloc]).andReturn(pending);
    OCMStub([pending initWithRequest:[OCMArg any]]).andReturn(pending);
    
    PCFRequestCache *cache = [[PCFRequestCache alloc] initWithRequestQueue:queue executor:nil];
    
    [cache queueRequest:request];
    
    OCMVerify([pending initWithRequest:request]);
    OCMVerify([queue addRequest:pending]);
    
    [pending stopMocking];
}


- (void)testExecutePendingRequestsWithTokenAndHandlerNewData {
    NSArray *requestArray = OCMClassMock([NSArray class]);
    OCMStub([requestArray count]).andReturn(1);
    
    PCFRequestCacheQueue *queue = OCMClassMock([PCFRequestCacheQueue class]);
    OCMStub([queue empty]).andReturn(requestArray);
    
    PCFRequestCache *cache = [[PCFRequestCache alloc] initWithRequestQueue:queue executor:nil];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [cache executePendingRequestsWithCompletionHandler:^(UIBackgroundFetchResult arg){
        XCTAssertEqual(arg, UIBackgroundFetchResultNewData);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testExecutePendingRequestsWithTokenAndHandlerNoData {
    NSArray *requestArray = OCMClassMock([NSArray class]);
    OCMStub([requestArray count]).andReturn(0);
    
    PCFRequestCacheQueue *queue = OCMClassMock([PCFRequestCacheQueue class]);
    OCMStub([queue empty]).andReturn(requestArray);
    
    PCFRequestCache *cache = [[PCFRequestCache alloc] initWithRequestQueue:queue executor:nil];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [cache executePendingRequestsWithCompletionHandler:^(UIBackgroundFetchResult arg){
        XCTAssertEqual(arg, UIBackgroundFetchResultNoData);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testExecutePendingRequests {
    PCFPendingRequest *pending = OCMClassMock([PCFPendingRequest class]);
    NSArray *requestArray = [[NSArray alloc] initWithObjects:pending, nil];
    
    PCFRequestCacheExecutor *executor = OCMClassMock([PCFRequestCacheExecutor class]);
    
    PCFRequestCache *cache = [[PCFRequestCache alloc] initWithRequestQueue:nil executor:executor];
    
    [cache executePendingRequests:requestArray];
    
    OCMVerify([executor executeRequest:pending]);
}

@end
