//
//  ViewController.m
//  TLFormView
//
//  Created by Bruno Berisso on 2/23/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "ViewController.h"
#import "TLFormView.h"
#import <objc/runtime.h>



@interface TLFormModelAdapter : NSObject <TLFormViewDataSource>

@end

@implementation TLFormModelAdapter

#pragma mark - TLFormViewDataSource

- (NSArray *)fieldNamesToShowInFormView:(TLFormView *)form {
    
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList( [self class], &count );
    NSMutableArray *properies = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count; i++ ) {
        objc_property_t property = properties[i];
        const char* propertyName = property_getName(property);
        
        [properies addObject:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
    }
    
    free(properties);
    
    return properies;
}

- (TLFormField *)formView:(TLFormView *)form fieldForName:(NSString *)fieldName {
    
}

@end



@interface ViewController () <TLFormViewDelegate, TLFormViewDataSource>

@end

@implementation ViewController


- (NSArray *)fieldNamesToShowInFormView:(TLFormView *)form {
    return @[@"field0", @"field1", @"field2", @"field3", @"field4"];
}

- (NSArray *)constraintsFormatForFieldsInForm:(TLFormView *)form {
    return @[@"V:|-[field0]",
             @"|-[field0]-|",
             
             @"V:[field0]-[field1]",
             @"|-[field1]-|",
             
             @"V:[field1]-[field2]",
             @"|-[field2]-|",
             
             @"V:[field2]-[field3]",
             @"|-[field3]-|",
             
             @"V:[field3]-[field4]-|",
             @"|-[field4]-|"];
}

- (TLFormField *)formView:(TLFormView *)form fieldForName:(NSString *)fieldName {
    
    TLFormFieldType fieldType;
    id defaultValue;
    NSString *title;
    
    if ([fieldName isEqualToString:@"field0"]) {
        fieldType = TLFormFieldTypeSingleLine;
        defaultValue = @"first value";
        title = @"First";
        
    } else if ([fieldName isEqualToString:@"field1"]) {
        fieldType = TLFormFieldTypeMultiLine;
        defaultValue = @"second value second valuesecond valuesecond valuesecond valuesecond value";
        title = @"Second";
        
    } else if ([fieldName isEqualToString:@"field2"]) {
        fieldType = TLFormFieldTypeList;
        defaultValue = @[@"value 1", @"value 2", @"value 3", @"value 4", @"value 5", @"value 6"];
        title = @"Third";
        
    } else if ([fieldName isEqualToString:@"field3"]) {
        fieldType = TLFormFieldTypeTitle;
        defaultValue = @"four value";
        title = @"Fourth";
        
    } else {
        fieldType = TLFormFieldTypeList;
        defaultValue = @[@"value 1", @"value 2", @"value 3", @"value 4", @"value 5", @"value 6"];
        title = @"Fifth";
    }
    
    return [TLFormField formFieldWithType:fieldType name:fieldName title:title andDefaultValue:defaultValue];
}


- (void)formView:(TLFormView *)form didSelecteField:(TLFormField *)field {
    
}

- (void)formView:(TLFormView *)form didChangeValueForField:(TLFormField *)field newValue:(id)value {
    
}

@end
