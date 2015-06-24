//
//  UIApplication+DTNetworkIndicatorManager.m
//  
//
//  Created by Dmitriy Tsurkan on 6/12/15.
//
//

#import "UIApplication+DTNetworkIndicatorManager.h"

@implementation UIApplication (DTNetworkIndicatorManager)

static int32_t requestsCount = 0;

- (void)showIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (requestsCount == 0) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        }
        
        requestsCount++;
    });
}

- (void)hideIndicator {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (requestsCount == 0) {
            return;
        }
        
        requestsCount--;
        
        if (requestsCount == 0) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    });
}


@end
