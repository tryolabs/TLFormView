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
 
*/

@implementation TLFormSeparator : NSObject @end
TLFormSeparator * TLFormSeparatorValue () {
    return [TLFormSeparator new];
}

@implementation TLFormText : NSString @end
TLFormText * TLFormTextValue(NSString *text) {
    return (TLFormText *) [text copy];
}

@implementation TLFormLongText : NSString @end
TLFormLongText * TLFormLongTextValue(NSString *longText) {
    return (TLFormLongText *) [longText copy];
}

@implementation TLFormTitle : NSString @end
TLFormTitle * TLFormTitleValue (NSString *title) {
    return (TLFormTitle *) [title copy];
}

@implementation TLFormNumber : NSNumber @end
TLFormNumber * TLFormNumberValue (NSNumber *number) {
    return (TLFormNumber *) [number copy];
}

@implementation TLFormBoolean : NSNumber @end
TLFormBoolean * TLFormBooleanValue (BOOL boolean) {
    return (TLFormBoolean *) [TLFormBoolean numberWithBool:boolean];
}

@implementation TLFormEnumerated : NSDictionary @end
NSString * const TLFormEnumeratedSelectedValue = @"TLFormEnumeratedSelectedValue";
NSString * const TLFormEnumeratedAllValues = @"TLFormEnumeratedAllValues";

TLFormEnumerated * TLFormEnumeratedValue (id current, NSArray *all) {
    return (TLFormEnumerated *) @{TLFormEnumeratedSelectedValue: current,
                                  TLFormEnumeratedAllValues: all};
}

@implementation TLFormList : NSArray @end
TLFormList * TLFormListValue(NSArray *array) {
    return (TLFormList *) [array copy];
}

@implementation TLFormImage : NSObject @end
TLFormImage * TLFormImageValue (NSObject *urlOrImage) {
    if ([urlOrImage isKindOfClass:[UIImage class]] || [urlOrImage isKindOfClass:[NSURL class]]) {
        return (TLFormImage *) [urlOrImage copy];
    } else {
        [NSException raise:@"Invalid image type" format:@"Should be UIImage or NSURL but it is: %@", NSStringFromClass([urlOrImage class])];
        return nil;
    }
}



typedef enum {
    TLFormValueTypeSeparator = 1,
    TLFormValueTypeText,
    TLFormValueTypeLongText,
    TLFormValueTypeTitle,
    TLFormValueTypeNumber,
    TLFormValueTypeBoolean,
    TLFormValueTypeEnumerated,
    TLFormValueTypeList,
    TLFormValueTypeImage,
    TLFormValueTypeDate
} TLFormValueType;



@interface TLPropertyInfo : NSObject 

@property (nonatomic, strong) NSString *name;
@property (nonatomic, readonly) TLFormFieldType fieldType;
@property (nonatomic, readonly) TLFormFieldInputType inputType;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) TLFormValueType valueType;

+ (instancetype)withObjcProperty:(objc_property_t)property;

@end

@implementation TLPropertyInfo

+ (instancetype)withObjcProperty:(objc_property_t)property {
    
    TLPropertyInfo *pi = [[TLPropertyInfo alloc] init];
    
    pi.name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
    
    //Example value: T@"PROPERTY_TYPE",&,N,V_avatar
    NSString *propertyType = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
    propertyType = [propertyType substringFromIndex:3];
    propertyType = [propertyType substringToIndex:[propertyType rangeOfString:@"\""].location];
    
    pi->_valueType = [pi valueTypeFromString:propertyType];
    [pi setupFieldInfo];
    
    return pi;
}

- (TLFormValueType)valueTypeFromString:(NSString *)stringType {
    //A quick way to turn a class name to an enumerated type.
    return [@[@"TLFormSeparator",
              @"TLFormText",
              @"TLFormLongText",
              @"TLFormTitle",
              @"TLFormNumber",
              @"TLFormBoolean",
              @"TLFormEnumerated",
              @"TLFormList",
              @"TLFormImage"] indexOfObject:stringType] + 1;
}

- (void)setupFieldInfo {
    
    //Map the value types to field and input types to define de behaviour of each type of value
    
    switch (self.valueType) {
            
        case TLFormValueTypeSeparator:
            _inputType = TLFormFieldInputTypeDefault;
            _fieldType = TLFormFieldTypeTitle;
            break;
            
        case TLFormValueTypeLongText:
            _inputType = TLFormFieldInputTypeDefault;
            _fieldType = TLFormFieldTypeMultiLine;
            break;
        
        case TLFormValueTypeTitle:
            _inputType = TLFormFieldInputTypeDefault;
            _fieldType = TLFormFieldTypeTitle;
            break;
        
        case TLFormValueTypeText:
            _inputType = TLFormFieldInputTypeDefault;
            _fieldType = TLFormFieldTypeSingleLine;
            break;
            
        case TLFormValueTypeNumber:
            _inputType = TLFormFieldInputTypeNumeric;
            _fieldType = TLFormFieldTypeSingleLine;
            break;
        
        case TLFormValueTypeBoolean:
            _inputType = TLFormFieldInputTypeInlineYesNo;
            _fieldType = TLFormFieldTypeSingleLine;
            break;
        
        case TLFormValueTypeEnumerated:
            _fieldType = TLFormFieldTypeSingleLine;
            _inputType = TLFormFieldInputTypeInlineSelect;
            break;
        
        case TLFormValueTypeList:
            _fieldType = TLFormFieldTypeList;
            _inputType = TLFormFieldInputTypeDefault;
            break;
        
        case TLFormValueTypeImage:
            _fieldType = TLFormFieldTypeImage;
            _inputType = TLFormFieldInputTypeDefault;
            break;
        
        case TLFormValueTypeDate:
            _fieldType = TLFormFieldTypeSingleLine;
            _inputType = TLFormFieldInputTypeInlineSelect;
            break;
        
        default:
            [NSException raise:@"Invalid form value type" format:@"Raw value: %d", self.valueType];
            break;
    }
    
    
    //The separator are a TLFormTitle with an empty title
    if (self.valueType == TLFormValueTypeSeparator)
        _title = @" ";
    else {
        //For the rest of te fields the title is calculated from the property name converting the "_" in spaces and
        //capitalising all the words (ex: "some_property_name" -> "Some Property Name")
        for (NSString *titleComp in [self.name componentsSeparatedByString:@"_"]) {
            if (_title.length > 0)
                _title = [_title stringByAppendingFormat:@" %@", [titleComp capitalizedString]];
            else
                _title = [titleComp capitalizedString];
        }
    }
}

@end



@implementation TLFormModel {
    NSMutableArray *propertiesInfo;
    NSArray *propertiesIndex;
}

- (TLPropertyInfo *)infoFormFieldWithName:(NSString *)fieldName {
    return propertiesInfo[[propertiesIndex indexOfObject:fieldName]];
}

#pragma mark - TLFormViewDataSource

- (NSArray *)fieldNamesToShowInFormView:(TLFormView *)form {
    
    //This is the first method called to setup the form so we parse our properties and fill the 'propertiesInfo' list with objects PropertyInfo
    
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    propertiesInfo = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count; i++ ) {
        objc_property_t property = properties[i];
        [propertiesInfo addObject:[TLPropertyInfo withObjcProperty:property]];
    }
    
    free(properties);
    
    //The 'name' in PropertyInfo is the 'fieldName' in the TLFormField
    propertiesIndex = [propertiesInfo valueForKey:@"name"];
    return propertiesIndex;
}

- (TLFormField *)formView:(TLFormView *)form fieldForName:(NSString *)fieldName {
    
    TLPropertyInfo *fieldInfo = [self infoFormFieldWithName:fieldName];
    id value = nil;
    NSArray *choices;
    
    if (fieldInfo.fieldType == TLFormFieldTypeTitle)
        value = fieldInfo.title;
    else {
        value = [self valueForKey:fieldName];
        
        //Get the choices for the enumerated type
        if (fieldInfo.valueType == TLFormValueTypeEnumerated) {
            choices = value[TLFormEnumeratedAllValues];
            value = value[TLFormEnumeratedSelectedValue];
        }
    }
    
    TLFormField *field = [TLFormField formFieldWithType:fieldInfo.fieldType name:fieldName title:fieldInfo.title andDefaultValue:value];
    
    if (choices)
        field.choicesValues = choices;
    
    return field;
}

- (id)formView:(TLFormView *)form valueForFieldWithName:(NSString *)fieldName {
    TLPropertyInfo *fieldInfo = [self infoFormFieldWithName:fieldName];
    id value = [self valueForKey:fieldName];
    
    switch (fieldInfo.valueType) {
        case TLFormValueTypeBoolean:
            return [value boolValue] ? @"Yes" : @"No";
        
        case TLFormValueTypeEnumerated:
            return value[TLFormEnumeratedSelectedValue];
        
        case TLFormValueTypeTitle:
            return fieldInfo.title;
            
        default:
            return value;
    }
}

- (TLFormFieldInputType)formView:(TLFormView *)form inputTypeForFieldWithName:(NSString *)fieldName {
    TLPropertyInfo *fieldInfo = [self infoFormFieldWithName:fieldName];
    return fieldInfo.inputType;
}

- (NSArray *)constraintsFormatForFieldsInForm:(TLFormView *)form {
    
    //The default layout is present the fields in a column in the same order that the property declaration has.
    
    NSMutableArray *constraints = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < propertiesIndex.count; i++) {
        
        NSString *propertyName = propertiesIndex[i];
        NSString *verticalConsFormat;
        
        if ([propertiesIndex firstObject] == propertyName)
            verticalConsFormat = @"V:|-margin-[%@(>=44)]";
        
        else {
            
            NSString *previousProperty = propertiesIndex[i - 1];
            
            if ([propertiesIndex lastObject] == propertyName)
                verticalConsFormat = [NSString stringWithFormat:@"V:[%@(>=44)]-(==0.0)-[%%@(>=44)]-margin-|", previousProperty];
            else
                verticalConsFormat = [NSString stringWithFormat:@"V:[%@(>=44)]-(==0.0)-[%%@(>=44)]", previousProperty];
        }
        
        [constraints addObject:[NSString stringWithFormat:verticalConsFormat, propertyName]];
        [constraints addObject:[NSString stringWithFormat:@"|-margin-[%@]-margin-|", propertyName]];
    }
    
    return constraints;
}

#pragma mark - TLFormViewDelegate

- (void)formView:(TLFormView *)form didSelecteField:(TLFormField *)field {
    //Do nothing.
}

- (void)formView:(TLFormView *)form didChangeValueForField:(TLFormField *)field newValue:(id)value {
    NSString *fieldName = field.fieldName;
    TLPropertyInfo *fieldInfo = [self infoFormFieldWithName:fieldName];
    
    switch (fieldInfo.valueType) {
        case TLFormValueTypeBoolean:
            [self setValue:@([value boolValue]) forKey:fieldName];
            break;
        
        case TLFormValueTypeEnumerated: {
            NSMutableDictionary *enumValue = [[self valueForKey:fieldName] mutableCopy];
            [enumValue setObject:value forKey:TLFormEnumeratedSelectedValue];
            [self setValue:enumValue forKey:fieldName];
            break;
        }
        
        default:
            [self setValue:value forKey:fieldName];
    }
}

- (void)formView:(TLFormView *)form listTypeField:(TLFormField *)field didDeleteRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *listValue = [[self valueForKey:field.fieldName] mutableCopy];
    [listValue removeObjectAtIndex:indexPath.row];
    [self setValue:listValue forKey:field.fieldName];
}

- (BOOL)formView:(TLFormView *)form listTypeField:(TLFormField *)field canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)formView:(TLFormView *)form listTypeField:(TLFormField *)field moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSMutableArray *listValue = [[self valueForKey:field.fieldName] mutableCopy];
    
    id sourceObj = listValue[sourceIndexPath.row];
    id destObj = listValue[destinationIndexPath.row];
    
    [listValue replaceObjectAtIndex:sourceIndexPath.row withObject:destObj];
    [listValue replaceObjectAtIndex:destinationIndexPath.row withObject:sourceObj];
    
    [self setValue:listValue forKey:field.fieldName];
}

@end

