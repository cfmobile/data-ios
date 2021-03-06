//
//  PCFDataLogger.m
//  PCFData
//
//  Created by DX122-XL on 2014-12-10.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFDataLogger.h"

@implementation PCFDataLogger

+ (instancetype)sharedInstance {
    static PCFDataLogger *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PCFDataLogger alloc] init];
        sharedInstance.level = PCFDataLogLevelWarning;
    });
    return sharedInstance;
}

- (void)logWithLevel:(PCFDataLogLevel)level format:(NSString*)format, ... NS_FORMAT_FUNCTION(2,3) {

    va_list args;
    va_start(args, format);

    if (level >= self.level) {
        NSLogv(format, args);
    }
    
    va_end(args);
}

@end
