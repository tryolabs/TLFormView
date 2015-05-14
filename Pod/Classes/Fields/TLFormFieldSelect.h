//
//  TLFormFieldSelect.h
//  TLFormView
//
//  Created by Bruno Berisso on 5/13/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "TLFormFieldSingleLine.h"

@interface TLFormFieldSelect : TLFormFieldSingleLine

//The list of values to show in the segmented control
@property (nonatomic, strong) NSArray *choicesValues;

@end
