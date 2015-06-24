//
//  VBRequest.h
//  VBSoapFrameworkExample
//
//  Created by Dmitriy Tsurkan on 5/27/15.
//  Copyright (c) 2015 DmitriyTsurkan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UNIRest.h"

typedef NS_ENUM(NSInteger, DTRequestType) {
    DTPost = 0,
    DTGet = 1,
    DTPut = 2,
    DTDelete = 3
};

@interface DTRequest : NSObject

@property (nonatomic) DTRequestType                     requestType;

+ (DTRequest *)createRequestByType:(DTRequestType)requestType withUrl:(NSString *)url;
- (instancetype)copyWithZone:(NSZone *)zone;

- (void)createRequestWithHeaderParams:(NSDictionary *)headerParams
                            withParams:(NSDictionary *)params;

- (NSString *)requestByType:(DTRequestType)requestType error:(NSError **)error;


@end
