//
//  TLFormModel.m
//  TLFormView
//
//  Created by Bruno Berisso on 2/24/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "TLFormModel.h"
#import <objc/runtime.h>
#import "TLFormField.h"


/*
 String -> String:
 TLFormText
 TLFormLongText
 TLFormTitle
 
 Number -> Number:
 TLFormNumber
 TLFormBoolean
 
 Dictionary -> Value:
 TLFormEnumerated
 
 Array -> Array:
 TLFormList
 
 (Image or URL) -> File URL:
 TLFormImage
 
 Date -> Date:
 TLFormDate
*/


@implementation TLFormText : NSString @end
@implementation TLFormLongText : NSString @end
@implementation TLFormTitle : NSString @end

@implementation TLFormNumber : NSNumber @end
@implementation TLFormBoolean : NSNumber @end

@implementation TLFormEnumerated : NSDictionary @end
NSString * const TLFormEnumeratedSelectedValue = @"TLFormEnumeratedSelectedValue";
NSString * const TLFormEnumeratedAllValues = @"TLFormEnumeratedAllValues";

@implementation TLFormList : NSArray @end

@implementation TLFormImage : NSObject @end

@implementation TLFormDate : NSDate @end



@interface TLPropertyInfo : NSObject 

@property (nonatomic, strong) NSString *name;
@property (nonatomic, readonly) TLFormFieldType fieldType;
@property (nonatomic, readonly) TLFormFieldInputType inputType;
@property (nonatomic, readonly) NSString *title;

+ (instancetype)withObjcProperty:(objc_property_t)property;

@end

@implementation TLPropertyInfo {
    Class type;
}

+ (instancetype)withObjcProperty:(objc_property_t)property {
    
    TLPropertyInfo *pi = [[TLPropertyInfo alloc] init];
    
    pi.name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
    
    //Example value: T@"PROPERTY_TYPE",&,N,V_avatar
    NSString *propertyType = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
    propertyType = [propertyType substringFromIndex:3];
    propertyType = [propertyType substringToIndex:[propertyType rangeOfString:@"\""].location];
    
    pi->type = NSClassFromString(propertyType);
    [pi setupFieldInfo];
    
    return pi;
}

- (void)setupFieldInfo {
    
    if ([type isSubclassOfClass:[NSString class]]) {
        
        _inputType = TLFormFieldInputTypeDefault;
        
        if ([type isSubclassOfClass:[TLFormLongText class]])
            _fieldType = TLFormFieldTypeMultiLine;
        else if ([type isSubclassOfClass:[TLFormTitle class]])
            _fieldType = TLFormFieldTypeTitle;
        else
            _fieldType = TLFormFieldTypeSingleLine;
    } else
    
    if ([type isSubclassOfClass:[NSNumber class]]) {
        
        _fieldType = TLFormFieldTypeSingleLine;
        
        if ([type isSubclassOfClass:[TLFormNumber class]])
            _inputType = TLFormFieldInputTypeNumeric;
        else
            _inputType = TLFormFieldInputTypeInlineYesNo;
    } else
    
    if ([type isSubclassOfClass:[TLFormEnumerated class]]) {
        _fieldType = TLFormFieldTypeSingleLine;
        _inputType = TLFormFieldInputTypeInlineSelect;
    } else
    
    if ([type isSubclassOfClass:[TLFormList class]]) {
        _fieldType = TLFormFieldTypeList;
        _inputType = TLFormFieldInputTypeDefault;
    } else
    
    if ([type isSubclassOfClass:[TLFormImage class]]) {
        _fieldType = TLFormFieldTypeImage;
        _inputType = TLFormFieldInputTypeDefault;
    } else
    
    if ([type isSubclassOfClass:[TLFormDate class]]) {
        _fieldType = TLFormFieldTypeSingleLine;
        _inputType = TLFormFieldInputTypeInlineSelect;
    }
    
    for (NSString *titleComp in [self.name componentsSeparatedByString:@"_"]) {
        if (_title.length > 0)
            _title = [_title stringByAppendingFormat:@" %@", [titleComp capitalizedString]];
        else
            _title = [titleComp capitalizedString];
    }
}

@end



@implementation TLFormModel {
    NSMutableArray *propertiesInfo;
    NSArray *propertiesIndex;
}

#pragma mark - TLFormViewDataSource

- (NSArray *)fieldNamesToShowInFormView:(TLFormView *)form {
    
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    propertiesInfo = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count; i++ ) {
        objc_property_t property = properties[i];
        [propertiesInfo addObject:[TLPropertyInfo withObjcProperty:property]];
    }
    
    free(properties);
    
    propertiesIndex = [propertiesInfo valueForKey:@"name"];
    return propertiesIndex;
}

- (TLFormField *)formView:(TLFormView *)form fieldForName:(NSString *)fieldName {
    
    TLPropertyInfo *info = propertiesInfo[[propertiesIndex indexOfObject:fieldName]];
    id value = nil;
    
    if (info.fieldType == TLFormFieldTypeTitle)
        value = info.title;
    else {
        value = [self valueForKey:fieldName];
        
        if ([value isKindOfClass:[NSDictionary class]])
            value = (NSDictionary *) value[TLFormEnumeratedSelectedValue];
    }
    
    return [TLFormField formFieldWithType:info.fieldType name:fieldName title:info.title andDefaultValue:value];
}

- (NSArray *)constraintsFormatForFieldsInForm:(TLFormView *)form {
    
    NSMutableArray *constraints = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < propertiesIndex.count; i++) {
        
        NSString *propertyName = propertiesIndex[i];
        NSString *verticalConsFormat;
        
        if ([propertiesIndex firstObject] == propertyName)
            verticalConsFormat = @"V:|-[%@]";
        
        else {
            
            NSString *previousProperty = propertiesIndex[i - 1];
            
            if ([propertiesIndex lastObject] == propertyName)
                verticalConsFormat = [NSString stringWithFormat:@"V:[%@]-[%%@]-|", previousProperty];
            else
                verticalConsFormat = [NSString stringWithFormat:@"V:[%@]-[%%@]", previousProperty];
        }
        
        [constraints addObject:[NSString stringWithFormat:verticalConsFormat, propertyName]];
        [constraints addObject:[NSString stringWithFormat:@"|-[%@]-|", propertyName]];
    }
    
    return constraints;
}

@end

