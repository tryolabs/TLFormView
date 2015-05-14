//
//  NSNumber+NumberType.m
//  TLFormView
//
//  Created by Bruno Berisso on 5/13/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "NSNumber+NumberType.h"


//Add two specil values that will live side by side to the CFNumberType enum values
const short kTLNumberBooleanType    = -1;
const short kTLNumberNanType        = -2;

@implementation NSNumber (NumberType)

- (CFNumberType)numberType {
    //Get if a number is NSNumber-bool value (see: http://stackoverflow.com/questions/2518761/get-type-of-nsnumber )
    if (self == (id) kCFBooleanFalse || self == (id) kCFBooleanTrue)
        return kTLNumberBooleanType;
    else
        return CFNumberGetType((CFNumberRef)self);
}

//Given a type and a value return the corresponding NSNumber. This is like use NSNumberFormatter but much better.
+ (instancetype)numberOfType:(CFNumberType)type withValue:(id)value {
    
    const void *numberValue = NULL;
    
    switch (type) {
        case kCFNumberCharType:
        case kCFNumberSInt8Type: {
            char tmp = [value charValue];
            numberValue = &tmp;
            break;
        }
        case kCFNumberShortType:
        case kCFNumberSInt16Type: {
            short tmp = [value shortValue];
            numberValue = &tmp;
            break;
        }
        case kCFNumberIntType:
        case kCFNumberSInt32Type: {
            int tmp = [value intValue];
            numberValue = &tmp;
            break;
        }
        case kCFNumberLongType: {
            long tmp = [value longValue];
            numberValue = &tmp;
            break;
        }
        case kCFNumberLongLongType:
        case kCFNumberSInt64Type: {
            long long tmp = [value longLongValue];
            numberValue = &tmp;
            break;
        }
        case kCFNumberCGFloatType:
        case kCFNumberFloatType:
        case kCFNumberFloat32Type: {
            float tmp = [value floatValue];
            numberValue = &tmp;
            break;
        }
        case kCFNumberDoubleType:
        case kCFNumberFloat64Type: {
            double tmp = [value doubleValue];
            numberValue = &tmp;
            break;
        }
        case kCFNumberNSIntegerType: {
            NSInteger tmp = [value integerValue];
            numberValue = &tmp;
            break;
        }
        default:
            numberValue = NULL;
            break;
    }
    
    return CFBridgingRelease(CFNumberCreate(kCFAllocatorDefault, type, numberValue));
}

@end

