//
//  PComms.m
//  P-Brain
//
//  Created by Patrick Quinn on 09/02/2017.
//  Copyright © 2017 GRAMMA Music. All rights reserved.
//

#import "PComms.h"

@implementation PComms {
    NSString* _serverUrl;
}

static PComms *comms = nil;

+(PComms*) getComms {
    @synchronized(self)
    {
        if(comms == nil)
        {
            comms = [[PComms alloc] init];
        }
    }
    return comms;
}

- (void)makeGetReq:(NSString *)query withBlock:(void (^) (id response, id error))handler {
    _serverUrl = [[NSUserDefaults standardUserDefaults]
                           stringForKey:@"pburl"];
    
    NSLog(@"SERVER URL %@", _serverUrl);
    
    NSString * base_url = [_serverUrl stringByAppendingString:query];
    
    base_url = [base_url stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    
    static NSURLSession* sharedSessionMainQueue = nil;
    if(!sharedSessionMainQueue){
        sharedSessionMainQueue = [NSURLSession sessionWithConfiguration:nil delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    }
    
    NSURLSessionDataTask *dataTask =
    [sharedSessionMainQueue dataTaskWithURL:[NSURL URLWithString:base_url] completionHandler:^(NSData *data,
                                                                                               NSURLResponse *response,
                                                                                               NSError *error){
        NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        NSMutableArray * temp_resp = [resp mutableCopy];
        handler(temp_resp, error);
    }];
    [dataTask resume];
}

@end
