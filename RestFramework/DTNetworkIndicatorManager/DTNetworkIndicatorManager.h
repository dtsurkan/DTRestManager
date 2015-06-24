//
//  NetworkIndicatorManager.h
//  
//
//  Created by Dmitriy Tsurkan on 6/12/15.
//
//

#import <Foundation/Foundation.h>

@interface DTNetworkIndicatorManager : NSObject

/**
 *  DTNetworkIndicatorManager
 *
 *  @return DTNetworkIndicatorManager
 */
+ (instancetype)defaultManager;

/**
 *  Show Network Activity Indicator
 */
- (void)showIndicator;

/**
 *  Hide Network Activity Indicator
 */
- (void)hideIndicator;

@end
