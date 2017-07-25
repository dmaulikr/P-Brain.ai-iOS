//
//  PData.m
//  P-Brain
//
//  Created by Patrick Quinn on 09/02/2017.
//  Copyright © 2017 GRAMMA Music. All rights reserved.
//

#import "PData.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

@implementation PData

static PData *comms = nil;

+(PData*) getData {
    @synchronized(self) {
        if(comms == nil) {
            comms = [[PData alloc] init];
        }
    }
    return comms;
}

- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return address;
}

@end
