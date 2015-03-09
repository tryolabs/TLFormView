//
//  TLFormFieldTitle.m
//  TLFormView
//
//  Created by Bruno Berisso on 2/24/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "TLFormFieldTitle.h"
#import "TLFormField+Protected.h"



@implementation TLFormFieldTitle {
    UILabel *titleLabel;
}

- (void)setupField:(BOOL)editing {
    [super setupField:editing];
    
    titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    titleLabel.numberOfLines = 0;
    
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:titleLabel];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(titleLabel);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleLabel]|"
                                                                 options:0
                                                                 metrics:self.defaultMetrics
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-np-[titleLabel]-np-|"
                                                                 options:0
                                                                 metrics:self.defaultMetrics
                                                                   views:views]];
    
    [self setValue:self.defautValue];
}

- (TLFormBorderStyleMask)borderStyle {
    return TLFormFieldBorderNone;
}

- (CGSize)intrinsicContentSize {
    return titleLabel.intrinsicContentSize;
}

- (id)getValue {
    return titleLabel.text;
}

- (void)setValue:(id)fieldValue {
    titleLabel.text = fieldValue;
}

@end

