//
//  PCFOfflineStoreTests.m
//  PCFData
//
//  Created by DX122-XL on 2014-11-20.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <PCFData/PCFData.h>

@interface PCFOfflineStoreTests : XCTestCase

@property NSString *key;
@property NSString *value;
@property NSString *token;
@property NSString *collection;
@property NSError *error;
@property BOOL force;

@end

@implementation PCFOfflineStoreTests

- (void)setUp {
    [super setUp];
    
    self.key = [NSUUID UUID].UUIDString;
    self.value = [NSUUID UUID].UUIDString;
    self.token = [NSUUID UUID].UUIDString;
    self.collection = [NSUUID UUID].UUIDString;
    
    self.error = [[NSError alloc] init];
    self.force = arc4random_uniform(1);
}

- (void)testGetInvokesRemoteAndLocalStoreWhenConnectionIsAvailable {
    PCFResponse *localResponse = [[PCFResponse alloc] initWithKey:self.key value:self.value];
    PCFResponse *remoteResponse = [[PCFResponse alloc] initWithKey:self.key value:self.value];

    PCFLocalStore *localStore = OCMClassMock([PCFLocalStore class]);
    PCFRemoteStore *remoteStore = OCMClassMock([PCFRemoteStore class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithCollection:self.collection localStore:localStore remoteStore:remoteStore]);
    
    OCMStub([dataStore isConnected]).andReturn(true);
    OCMStub([remoteStore getWithKey:[OCMArg any] accessToken:[OCMArg any] force:self.force]).andReturn(remoteResponse);
    OCMStub([localStore putWithKey:[OCMArg any] value:[OCMArg any] accessToken:[OCMArg any] force:self.force]).andReturn(localResponse);
    
    PCFResponse *response = [dataStore getWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response, localResponse);
    
    OCMVerify([remoteStore getWithKey:self.key accessToken:self.token force:self.force]);
    OCMVerify([localStore putWithKey:self.key value:remoteResponse.value accessToken:self.token force:self.force]);
}

- (void)testGetInvokesRemoteStoreWhenConnectionIsAvailableAndErrorOccurs {
    PCFResponse *remoteResponse = [[PCFResponse alloc] initWithKey:self.key error:self.error];
    
    PCFRemoteStore *remoteStore = OCMClassMock([PCFRemoteStore class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithCollection:self.collection localStore:nil remoteStore:remoteStore]);
    
    OCMStub([dataStore isConnected]).andReturn(true);
    OCMStub([remoteStore getWithKey:[OCMArg any] accessToken:[OCMArg any] force:self.force]).andReturn(remoteResponse);
    
    PCFResponse *response = [dataStore getWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response, remoteResponse);
    
    OCMVerify([remoteStore getWithKey:self.key accessToken:self.token force:self.force]);
}

- (void)testGetInvokesRemoteAndLocalStoreWhenConnectionIsAvailableAndNotModifiedErrorOccurs {
    NSError *error = [[NSError alloc] initWithDomain:@"Not Modified" code:304 userInfo:nil];
    PCFResponse *localResponse = [[PCFResponse alloc] initWithKey:self.key value:self.value];
    PCFResponse *remoteResponse = [[PCFResponse alloc] initWithKey:self.key error:error];
    
    PCFLocalStore *localStore = OCMClassMock([PCFLocalStore class]);
    PCFRemoteStore *remoteStore = OCMClassMock([PCFRemoteStore class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithCollection:self.collection localStore:localStore remoteStore:remoteStore]);
    
    OCMStub([dataStore isConnected]).andReturn(true);
    OCMStub([localStore getWithKey:[OCMArg any] accessToken:[OCMArg any] force:self.force]).andReturn(localResponse);
    OCMStub([remoteStore getWithKey:[OCMArg any] accessToken:[OCMArg any] force:self.force]).andReturn(remoteResponse);
    
    PCFResponse *response = [dataStore getWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response, localResponse);
    
    OCMVerify([remoteStore getWithKey:self.key accessToken:self.token force:self.force]);
    OCMVerify([localStore getWithKey:self.key accessToken:self.token force:self.force]);
}

- (void)testGetInvokesLocalStoreAndQueuesRequestWhenConnectionIsNotAvailableAndSyncIsSupported {
    PCFResponse *localResponse = [[PCFResponse alloc] initWithKey:self.key value:self.value];
    
    PCFLocalStore *localStore = OCMClassMock([PCFLocalStore class]);
    PCFRequestCache *requestCache = OCMClassMock([PCFRequestCache class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithCollection:self.collection localStore:localStore remoteStore:nil]);
    
    OCMStub([dataStore isConnected]).andReturn(false);
    OCMStub([dataStore isSyncSupported]).andReturn(true);
    OCMStub([dataStore requestCache]).andReturn(requestCache);
    OCMStub([localStore getWithKey:[OCMArg any] accessToken:[OCMArg any] force:self.force]).andReturn(localResponse);
    
    PCFResponse *response = [dataStore getWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response, localResponse);
    
    OCMVerify([localStore getWithKey:self.key accessToken:self.token force:self.force]);
    OCMVerify([requestCache queueGetWithToken:self.token collection:self.collection key:self.key]);
}

- (void)testGetInvokesLocalStoreWhenConnectionIsNotAvailableAndSyncIsNotSupported {
    PCFResponse *localResponse = [[PCFResponse alloc] initWithKey:self.key value:self.value];
    
    PCFLocalStore *localStore = OCMClassMock([PCFLocalStore class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithCollection:self.collection localStore:localStore remoteStore:nil]);
    
    OCMStub([dataStore isConnected]).andReturn(false);
    OCMStub([dataStore isSyncSupported]).andReturn(false);
    OCMStub([localStore getWithKey:[OCMArg any] accessToken:[OCMArg any] force:self.force]).andReturn(localResponse);
    
    PCFResponse *response = [dataStore getWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response, localResponse);
    
    OCMVerify([localStore getWithKey:self.key accessToken:self.token force:self.force]);
}

- (void)testPutInvokesRemoteAndLocalStoreWhenConnectionIsAvailable {
    PCFResponse *localResponse = [[PCFResponse alloc] initWithKey:self.key value:self.value];
    PCFResponse *remoteResponse = [[PCFResponse alloc] initWithKey:self.key value:self.value];
    
    PCFLocalStore *localStore = OCMClassMock([PCFLocalStore class]);
    PCFRemoteStore *remoteStore = OCMClassMock([PCFRemoteStore class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithCollection:self.collection localStore:localStore remoteStore:remoteStore]);
    
    OCMStub([dataStore isConnected]).andReturn(true);
    OCMStub([remoteStore putWithKey:[OCMArg any] value:[OCMArg any] accessToken:[OCMArg any] force:self.force]).andReturn(remoteResponse);
    OCMStub([localStore putWithKey:[OCMArg any] value:[OCMArg any] accessToken:[OCMArg any] force:self.force]).andReturn(localResponse);
    
    PCFResponse *response = [dataStore putWithKey:self.key value:self.value accessToken:self.token];
    
    XCTAssertEqual(response, localResponse);
    
    OCMVerify([remoteStore putWithKey:self.key value:self.value accessToken:self.token force:self.force]);
    OCMVerify([localStore putWithKey:self.key value:remoteResponse.value accessToken:self.token force:self.force]);
}

- (void)testPutInvokesRemoteStoreWhenConnectionIsAvailableAndErrorOccurs {
    PCFResponse *remoteResponse = [[PCFResponse alloc] initWithKey:self.key error:self.error];
    
    PCFRemoteStore *remoteStore = OCMClassMock([PCFRemoteStore class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithCollection:self.collection localStore:nil remoteStore:remoteStore]);
    
    OCMStub([dataStore isConnected]).andReturn(true);
    OCMStub([remoteStore putWithKey:[OCMArg any] value:[OCMArg any] accessToken:[OCMArg any] force:self.force]).andReturn(remoteResponse);
    
    PCFResponse *response = [dataStore putWithKey:self.key value:self.value accessToken:self.token];
    
    XCTAssertEqual(response, remoteResponse);
    
    OCMVerify([remoteStore putWithKey:self.key value:self.value accessToken:self.token force:self.force]);
}

- (void)testPutInvokesLocalStoreAndQueuesRequestWhenConnectionIsNotAvailableAndSyncIsSupported {
    PCFResponse *localGetResponse = [[PCFResponse alloc] initWithKey:self.key value:self.value];
    PCFResponse *localPutResponse = [[PCFResponse alloc] initWithKey:self.key value:self.value];
    
    PCFLocalStore *localStore = OCMClassMock([PCFLocalStore class]);
    PCFRequestCache *requestCache = OCMClassMock([PCFRequestCache class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithCollection:self.collection localStore:localStore remoteStore:nil]);
    
    OCMStub([dataStore isConnected]).andReturn(false);
    OCMStub([dataStore isSyncSupported]).andReturn(true);
    OCMStub([dataStore requestCache]).andReturn(requestCache);
    OCMStub([localStore getWithKey:[OCMArg any] accessToken:[OCMArg any] force:self.force]).andReturn(localGetResponse);
    OCMStub([localStore putWithKey:[OCMArg any] value:[OCMArg any] accessToken:[OCMArg any] force:self.force]).andReturn(localPutResponse);
    
    PCFResponse *response = [dataStore putWithKey:self.key value:self.value accessToken:self.token];
    
    XCTAssertEqual(response, localPutResponse);
    
    OCMVerify([localStore getWithKey:self.key accessToken:self.token force:self.force]);
    OCMVerify([localStore putWithKey:self.key value:self.value accessToken:self.token force:self.force]);
    OCMVerify([requestCache queuePutWithToken:self.token collection:self.collection key:self.key value:self.value fallback:localGetResponse.value]);
}

- (void)testPutFailsWhenConnectionIsNotAvailableAndSyncIsNotSupported {
    PCFResponse *failureResponse = [[PCFResponse alloc] initWithKey:self.key error:self.error];
    
    PCFLocalStore *localStore = OCMClassMock([PCFLocalStore class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithCollection:self.collection localStore:localStore remoteStore:nil]);
    
    OCMStub([dataStore isConnected]).andReturn(false);
    OCMStub([dataStore isSyncSupported]).andReturn(false);
    OCMStub([dataStore errorNoConnectionWithKey:[OCMArg any]]).andReturn(failureResponse);
    
    PCFResponse *response = [dataStore putWithKey:self.key value:self.value accessToken:self.token];
    
    XCTAssertEqual(response, failureResponse);
    
    OCMVerify([dataStore errorNoConnectionWithKey:self.key]);
}

- (void)testDeleteInvokesRemoteAndLocalStoreWhenConnectionIsAvailable {
    PCFResponse *localResponse = [[PCFResponse alloc] initWithKey:self.key value:self.value];
    PCFResponse *remoteResponse = [[PCFResponse alloc] initWithKey:self.key value:self.value];
    
    PCFLocalStore *localStore = OCMClassMock([PCFLocalStore class]);
    PCFRemoteStore *remoteStore = OCMClassMock([PCFRemoteStore class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithCollection:self.collection localStore:localStore remoteStore:remoteStore]);
    
    OCMStub([dataStore isConnected]).andReturn(true);
    OCMStub([remoteStore deleteWithKey:[OCMArg any] accessToken:[OCMArg any] force:self.force]).andReturn(remoteResponse);
    OCMStub([localStore deleteWithKey:[OCMArg any] accessToken:[OCMArg any] force:self.force]).andReturn(localResponse);
    
    PCFResponse *response = [dataStore deleteWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response, localResponse);
    
    OCMVerify([remoteStore deleteWithKey:self.key accessToken:self.token force:self.force]);
    OCMVerify([localStore deleteWithKey:self.key accessToken:self.token force:self.force]);
}

- (void)testDeleteInvokesRemoteStoreWhenConnectionIsAvailableAndErrorOccurs {
    PCFResponse *remoteResponse = [[PCFResponse alloc] initWithKey:self.key error:self.error];
    
    PCFRemoteStore *remoteStore = OCMClassMock([PCFRemoteStore class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithCollection:self.collection localStore:nil remoteStore:remoteStore]);
    
    OCMStub([dataStore isConnected]).andReturn(true);
    OCMStub([remoteStore deleteWithKey:[OCMArg any] accessToken:[OCMArg any] force:self.force]).andReturn(remoteResponse);
    
    PCFResponse *response = [dataStore deleteWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response, remoteResponse);
    
    OCMVerify([remoteStore deleteWithKey:self.key accessToken:self.token force:self.force]);
}

- (void)testDeleteInvokesLocalStoreAndQueuesRequestWhenConnectionIsNotAvailableAndSyncIsSupported {
    PCFResponse *localGetResponse = [[PCFResponse alloc] initWithKey:self.key value:self.value];
    PCFResponse *localDeleteResponse = [[PCFResponse alloc] initWithKey:self.key value:self.value];
    
    PCFLocalStore *localStore = OCMClassMock([PCFLocalStore class]);
    PCFRequestCache *requestCache = OCMClassMock([PCFRequestCache class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithCollection:self.collection localStore:localStore remoteStore:nil]);
    
    OCMStub([dataStore isConnected]).andReturn(false);
    OCMStub([dataStore isSyncSupported]).andReturn(true);
    OCMStub([dataStore requestCache]).andReturn(requestCache);
    OCMStub([localStore getWithKey:[OCMArg any] accessToken:[OCMArg any] force:self.force]).andReturn(localGetResponse);
    OCMStub([localStore deleteWithKey:[OCMArg any] accessToken:[OCMArg any] force:self.force]).andReturn(localDeleteResponse);
    
    PCFResponse *response = [dataStore deleteWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response, localDeleteResponse);
    
    OCMVerify([localStore getWithKey:self.key accessToken:self.token force:self.force]);
    OCMVerify([localStore deleteWithKey:self.key accessToken:self.token force:self.force]);
    OCMVerify([requestCache queueDeleteWithToken:self.token collection:self.collection key:self.key fallback:localGetResponse.value]);
}

- (void)testDeleteFailsWhenConnectionIsNotAvailableAndSyncIsNotSupported {
    PCFResponse *failureResponse = [[PCFResponse alloc] initWithKey:self.key error:self.error];
    
    PCFLocalStore *localStore = OCMClassMock([PCFLocalStore class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithCollection:self.collection localStore:localStore remoteStore:nil]);
    
    OCMStub([dataStore isConnected]).andReturn(false);
    OCMStub([dataStore isSyncSupported]).andReturn(false);
    OCMStub([dataStore errorNoConnectionWithKey:[OCMArg any]]).andReturn(failureResponse);
    
    PCFResponse *response = [dataStore deleteWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response, failureResponse);
    
    OCMVerify([dataStore errorNoConnectionWithKey:self.key]);
}

@end
