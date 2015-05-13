//
//  NSNumber+NumberType.h
//  TLFormView
//
//  Created by Bruno Berisso on 5/13/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import <Foundation/Foundation.h>


extern const short kTLNumberBooleanType;
extern const short kTLNumberNanType;

//This category is used for handling the mapping between NSNumber types (numberWithBool:, numberWithFloat:, etc) and his string values. Ex: you give a "numberWithBool" as value
//then the value is show as "Yes"/"No" and when the value is read you get a "numberWithBool" back. The same works for any type of number thanks to this category.
@interface NSNumber (NumberType)

- (CFNumberType)numberType;
+ (instancetype)numberOfType:(CFNumberType)type withValue:(id)value;

@end

