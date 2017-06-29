//
//  PComms.m
//  P-Brain
//
//  Created by Patrick Quinn on 09/02/2017.
//  Copyright © 2017 GRAMMA Music. All rights reserved.
//

#define ASK_URL @"ask?"
#define LOGIN_URL @"login"
#define VERIFY_URL @"veryify?"

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
    NSString * token = [[NSUserDefaults standardUserDefaults]
                  stringForKey:@"token"];
    
    NSLog(@"SERVER URL %@", _serverUrl);
    
    NSString * base_url = [NSString stringWithFormat:@"%@%@q=%@&token=%@",_serverUrl,ASK_URL,query,token];
    
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

- (void)makeLoginRequestWithUser: (NSString*) name andPass:(NSString*)pass withBlock:(void (^) (id response, id error))handler {
    _serverUrl = [[NSUserDefaults standardUserDefaults]
                  stringForKey:@"pburl"];
    
    NSLog(@"SERVER URL %@", _serverUrl);
    
    NSString * base_url = [NSString stringWithFormat:@"%@%@",_serverUrl,LOGIN_URL];
    
    base_url = [base_url stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:base_url]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", name, pass];
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    
    NSURLSession *sharedSessionMainQueue = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask *dataTask =
    [sharedSessionMainQueue dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                                                               NSURLResponse *response,
                                                                                               NSError *error){
        NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        NSMutableArray * temp_resp = [resp mutableCopy];
        handler(temp_resp, error);
    }];
    [dataTask resume];
}

@end
