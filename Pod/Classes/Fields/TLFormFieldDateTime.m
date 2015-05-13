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
    NSDateFormatter *_formatter;
}

- (NSDateFormatter *)formatter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _formatter = [[NSDateFormatter alloc] init];
        
    });
    return _formatter;
}

- (void)setupField:(BOOL)editing {
    [super setupField:editing];
    
    NSDictionary *metrics = [self defaultMetrics];
    UIView *titleView = [self titleView];
    [self addSubview:titleView];
    
    if (editing) {
        
        UILabel *titleLabel = (UILabel *) [titleView viewWithTag:TLFormFieldTitleLabelTag];
        titleLabel.textColor = [UIColor grayColor];
        
        UIDatePicker *picker = [[UIDatePicker alloc] init];
        picker.datePickerMode = UIDatePickerModeDateAndTime;
        picker.translatesAutoresizingMaskIntoConstraints = NO;
        picker.date = [self getValue];
        [self addSubview:picker];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(picker, titleView);
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-np-[titleView][picker]-np-|"
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-bp-[titleView]-bp-|"
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:views]];
    } else {
        
        UILabel *dateLabel = [[UILabel alloc] init];
        dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        dateLabel.text = [[self formatter] stringFromDate:[self getValue]];
        
        
    }
}

@end
