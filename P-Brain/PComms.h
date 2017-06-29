//
//  PComms.h
//  P-Brain
//
//  Created by Patrick Quinn on 09/02/2017.
//  Copyright © 2017 GRAMMA Music. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PComms : NSObject

+(PComms*) getComms;

- (void)makeGetReq:(NSString *)query withBlock:(void (^) (id response, id error))handler;
- (void)makeLoginRequestWithUser: (NSString*) name andPass:(NSString*)pass withBlock:(void (^) (id response, id error))handler;

@end
