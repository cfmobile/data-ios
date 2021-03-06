//
//  PCFRemoteStore.h
//  PCFData
//
//  Created by DX122-XL on 2014-10-29.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCFDataStore.h"

@class PCFRemoteClient;

@interface PCFKeyValueRemoteStore : NSObject <PCFDataStore>

- (instancetype)initWithClient:(PCFRemoteClient *)client;

@end
