//
//  TestModel.h
//  VBSoapFrameworkExample
//
//  Created by Dmitriy Tsurkan on 5/26/15.
//  Copyright (c) 2015 DmitriyTsurkan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestModel : NSObject

@property (copy, nonatomic) NSString *address;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *workTime;
@property (strong, nonatomic) NSNumber *locationId;
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longitude;

@end
