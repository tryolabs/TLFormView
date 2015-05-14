//
//  TLFormFieldDateTime.h
//  TLFormView
//
//  Created by Bruno Berisso on 5/12/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "TLFormFieldSingleLine.h"

@interface TLFormFieldDateTime : TLFormFieldSingleLine

@property (nonatomic, strong) NSString *dateFormat;
@property (nonatomic, assign) UIDatePickerMode pickerMode;

@end
