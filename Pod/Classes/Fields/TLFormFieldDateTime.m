//
//  TLFormFieldDateTime.m
//  TLFormView
//
//  Created by Bruno Berisso on 5/12/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "TLFormFieldDateTime.h"
#import "TLFormField+Protected.h"



@implementation TLFormFieldDateTime {
    dispatch_once_t _onceTokenFormatter;
    NSDateFormatter *_formatter;
    UIDatePicker *picker;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.dateFormat = @"MMM dd, yyyy HH:mm";
        self.pickerMode = UIDatePickerModeDateAndTime;
    }
    return self;
}

- (NSDateFormatter *)formatter {
    dispatch_once(&_onceTokenFormatter, ^{
        _formatter = [[NSDateFormatter alloc] init];
        _formatter.dateFormat = self.dateFormat;
    });
    return _formatter;
}

- (void)setupFieldForEditing {
    picker = [[UIDatePicker alloc] init];
    picker.datePickerMode = self.pickerMode;
    picker.translatesAutoresizingMaskIntoConstraints = NO;
    [picker addTarget:self action:@selector(controlValueChange) forControlEvents:UIControlEventValueChanged];
    [self addSubview:picker];
    self.clipsToBounds = YES;
    
    UIView *titleView = [self titleView];
    NSDictionary *views = NSDictionaryOfVariableBindings(picker, titleView);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-np-[titleView][picker]-np-|"
                                                                 options:0
                                                                 metrics:self.defaultMetrics
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-bp-[titleView]-bp-|"
                                                                 options:0
                                                                 metrics:self.defaultMetrics
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-np-[picker]-np-|"
                                                                 options:0
                                                                 metrics:self.defaultMetrics
                                                                   views:views]];
}

//Get and Set value

- (void)setValue:(id)fieldValue {
    
    if (!fieldValue)
        return;
    
    if ([fieldValue isKindOfClass:[NSDate class]]) {
        
        if (picker)
            picker.date = fieldValue;
        else
            self.valueViewText = [[self formatter] stringFromDate:fieldValue];
        
    } else
        [NSException raise:@"Invalid field value" format:@"TLFormFieldNumeric only accept fields of type NSNumber. Suplied value: %@", fieldValue];
}

- (id)getValue {
    if (picker) 
        return picker.date;
    else
        return [[self formatter] dateFromString:self.valueViewText];
}

//UIDatePicker value change

- (void)controlValueChange {
    [self.formDelegate didChangeValueForField:self newValue:[self getValue]];
}

@end
