//
//  UIApplication+DTNetworkIndicatorManager.h
//  
//
//  Created by Dmitriy Tsurkan on 6/12/15.
//
//

#import <UIKit/UIKit.h>

@interface UIApplication (DTNetworkIndicatorManager)

/**
 *  Show Network Activity Indicator
 */
- (void)showIndicator;

/**
 *  Hide Network Activity Indicator
 */
- (void)hideIndicator;
@end
