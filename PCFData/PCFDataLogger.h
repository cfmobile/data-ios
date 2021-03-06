//
//  PCFDataLogger.h
//  PCFData
//
//  Created by DX122-XL on 2014-12-10.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCFData.h"

#define DEFAULT_LOGGER [PCFDataLogger sharedInstance]

#define LogDebug(FMT, ...) \
    [DEFAULT_LOGGER logWithLevel:PCFDataLogLevelDebug format:FMT, ##__VA_ARGS__]

#define LogInfo(FMT, ...) \
    [DEFAULT_LOGGER logWithLevel:PCFDataLogLevelInfo format:FMT, ##__VA_ARGS__]

#define LogWarning(FMT, ...) \
    [DEFAULT_LOGGER logWithLevel:PCFDataLogLevelWarning format:FMT, ##__VA_ARGS__]

#define LogError(FMT, ...) \
    [DEFAULT_LOGGER logWithLevel:PCFDataLogLevelError format:FMT, ##__VA_ARGS__]

#define LogCritical(FMT, ...) \
    [DEFAULT_LOGGER logWithLevel:PCFDataLogLevelCritical format:FMT, ##__VA_ARGS__]

@interface PCFDataLogger : NSObject

@property PCFDataLogLevel level;

+ (instancetype)sharedInstance;

- (void)logWithLevel:(PCFDataLogLevel)level format:(NSString*)format, ...;

@end
