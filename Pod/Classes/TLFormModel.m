//
//  TLFormModel.m
//  TLFormView
//
//  Created by Bruno Berisso on 2/24/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "TLFormModel.h"
#import <objc/runtime.h>
#import "TLFormAllFields.h"


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
    TLFormValueTypeUnknow = 0,
    TLFormValueTypeSeparator,
    TLFormValueTypeText,
    TLFormValueTypeLongText,
    TLFormValueTypeTitle,
    TLFormValueTypeNumber,
    TLFormValueTypeBoolean,
    TLFormValueTypeEnumerated,
    TLFormValueTypeList,
    TLFormValueTypeImage
} TLFormValueType;



@interface TLPropertyInfo : NSObject 

@property (nonatomic, strong) NSString *name;
@property (nonatomic, readonly) Class fieldClass;
@property (nonatomic, readonly) TLFormFieldInputType inputType;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) TLFormValueType valueType;

+ (instancetype)withObjcProperty:(objc_property_t)property;

@end

@implementation TLPropertyInfo

+ (instancetype)withObjcProperty:(objc_property_t)property {
    
    TLPropertyInfo *pi = nil;
    //Example value: T@"PROPERTY_TYPE",&,N,V_avatar
    NSString *propertyType = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
    
    //Parse the property type string to get the class
    if (propertyType.length > 4) {
        
        propertyType = [propertyType substringFromIndex:3];
        NSUInteger rightQuoteIdx = [propertyType rangeOfString:@"\""].location;
        
        if (rightQuoteIdx != NSNotFound) {
            propertyType = [propertyType substringToIndex:rightQuoteIdx];
            
            TLFormValueType valueType = [TLPropertyInfo valueTypeFromString:propertyType];
            if (valueType != TLFormValueTypeUnknow) {
                
                pi = [[TLPropertyInfo alloc] init];
                pi.name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
                pi->_valueType = valueType;
                [pi setupFieldInfo];
            }
        }
    }
    
    return pi;
}

+ (TLFormValueType)valueTypeFromString:(NSString *)stringType {
    //A quick way to turn a class name to an enumerated type.
    
    NSUInteger idx = [@[@"TLFormSeparator",
                        @"TLFormText",
                        @"TLFormLongText",
                        @"TLFormTitle",
                        @"TLFormNumber",
                        @"TLFormBoolean",
                        @"TLFormEnumerated",
                        @"TLFormList",
                        @"TLFormImage"] indexOfObject:stringType];
    
    if (idx != NSNotFound)
        return (TLFormValueType) idx + 1;
    else
        return TLFormValueTypeUnknow;
}

- (void)setupFieldInfo {
    
    //Map the value types to field and input types to define de behaviour of each type of value
    
    _inputType = TLFormFieldInputTypeDefault;
    
    switch (self.valueType) {
            
        case TLFormValueTypeSeparator:
            _fieldClass = [TLFormFieldTitle class];
            break;
            
        case TLFormValueTypeLongText:
            _fieldClass = [TLFormFieldMultiLine class];
            break;
        
        case TLFormValueTypeTitle:
            _fieldClass = [TLFormFieldTitle class];
            break;
        
        case TLFormValueTypeText:
            _fieldClass = [TLFormFieldSingleLine class];
            break;
            
        case TLFormValueTypeNumber:
            _inputType = TLFormFieldInputTypeNumeric;
            _fieldClass = [TLFormFieldSingleLine class];
            break;
        
        case TLFormValueTypeBoolean:
            _inputType = TLFormFieldInputTypeInlineYesNo;
            _fieldClass = [TLFormFieldSingleLine class];
            break;
        
        case TLFormValueTypeEnumerated:
            _inputType = TLFormFieldInputTypeInlineSelect;
            _fieldClass = [TLFormFieldSingleLine class];
            break;
        
        case TLFormValueTypeList:
            _fieldClass = [TLFormFieldList class];
            break;
        
        case TLFormValueTypeImage:
            _fieldClass = [TLFormFieldImage class];
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



@interface TLFormModel () <TLFormFieldListDelegate>

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
        TLPropertyInfo *propertyInfo = [TLPropertyInfo withObjcProperty:property];
        
        if (propertyInfo)
            [propertiesInfo addObject:propertyInfo];
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
    
    if (fieldInfo.valueType == TLFormValueTypeTitle)
        value = fieldInfo.title;
    else {
        value = [self valueForKey:fieldName];
        
        //Get the choices for the enumerated type
        if (fieldInfo.valueType == TLFormValueTypeEnumerated) {
            choices = value[TLFormEnumeratedAllValues];
            value = value[TLFormEnumeratedSelectedValue];
        }
    }
    
    TLFormField *field = [fieldInfo.fieldClass formFieldWithName:fieldName title:fieldInfo.title andDefaultValue:value];
    
    //Set the properties specific for the single line field class
    if ([fieldInfo.fieldClass isSubclassOfClass:[TLFormFieldSingleLine class]]) {
        
        TLFormFieldSingleLine *singleLineField = (TLFormFieldSingleLine *) field;
        
        singleLineField.inputType = fieldInfo.inputType;
        singleLineField.choicesValues = choices;
        
    } else if ([fieldInfo.fieldClass isSubclassOfClass:[TLFormFieldList class]]) {
        
        TLFormFieldList *listField = (TLFormFieldList *) field;
        listField.delegate = self;
    }
    
    //Set the top and bottom borders
    field.borderStyle = TLFormFieldBorderTop | TLFormFieldBorderBottom;
    
    return field;
}

- (id)formView:(TLFormView *)form valueForFieldWithName:(NSString *)fieldName {
    TLPropertyInfo *fieldInfo = [self infoFormFieldWithName:fieldName];
    id value = [self valueForKey:fieldName];
    
    switch (fieldInfo.valueType) {
        case TLFormValueTypeEnumerated:
            return value[TLFormEnumeratedSelectedValue];
        
        case TLFormValueTypeTitle:
            return fieldInfo.title;
            
        default:
            return value;
    }
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
            verticalConsFormat = [NSString stringWithFormat:@"V:[%@(>=44)]-(==0)-[%%@(>=44)]", previousProperty];
            
            if ([propertiesIndex lastObject] == propertyName)
                verticalConsFormat = [verticalConsFormat stringByAppendingString:@"-margin-|"];
        }
        
        [constraints addObject:[NSString stringWithFormat:verticalConsFormat, propertyName]];
        [constraints addObject:[NSString stringWithFormat:@"|-margin-[%@]-margin-|", propertyName]];
    }
    
    return constraints;
}

#pragma mark - TLFormViewDelegate

- (void)formView:(TLFormView *)form didSelectField:(TLFormField *)field {
    //Do nothing.
}

- (void)formView:(TLFormView *)form didChangeValueForField:(TLFormField *)field newValue:(id)value {
    NSString *fieldName = field.fieldName;
    TLPropertyInfo *fieldInfo = [self infoFormFieldWithName:fieldName];
    
    if (fieldInfo.valueType == TLFormValueTypeEnumerated) {
        NSMutableDictionary *enumValue = [[self valueForKey:fieldName] mutableCopy];
        [enumValue setObject:value forKey:TLFormEnumeratedSelectedValue];
        [self setValue:enumValue forKey:fieldName];
    } else
        [self setValue:value forKey:fieldName];
}

#pragma mark - TLFormFieldListDelegate

- (void)listFormField:(TLFormField *)field didDeleteRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *listValue = [[self valueForKey:field.fieldName] mutableCopy];
    [listValue removeObjectAtIndex:indexPath.row];
    [self setValue:listValue forKey:field.fieldName];
}

- (BOOL)listFormField:(TLFormField *)field canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)listFormField:(TLFormField *)field moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSMutableArray *listValue = [[self valueForKey:field.fieldName] mutableCopy];
    
    id sourceObj = listValue[sourceIndexPath.row];
    id destObj = listValue[destinationIndexPath.row];
    
    [listValue replaceObjectAtIndex:sourceIndexPath.row withObject:destObj];
    [listValue replaceObjectAtIndex:destinationIndexPath.row withObject:sourceObj];
    
    [self setValue:listValue forKey:field.fieldName];
}

@end

