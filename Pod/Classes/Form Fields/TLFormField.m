//
//  TLFormField.m
//  TLFormView
//
//  Created by Bruno Berisso on 2/24/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "TLFormField.h"
#import "TLFormField+Protected.h"
#import "TLFormFieldList.h"
#import "TLFormFieldMultiLine.h"
#import "TLFormFieldSingleLine.h"
#import "TLFormFieldImage.h"
#import "TLFormFieldTitle.h"



#pragma mark - TLFormField
/************************************************************************************************************************************************/
/**************************************************************  TLFormField  *******************************************************************/
/************************************************************************************************************************************************/

#pragma mark - HelpTooltipPopoverControler
/**************************************************  HelpTooltipPopoverControler  ***************************************************************/
//This class is the content of the help tooltip. It's only a UITextView that display the value of 'helpText' property

@interface HelpTooltipPopoverControler : UIViewController
+ (id)helpTooltipControllerWithText:(NSString *)helpText;
@end

@implementation HelpTooltipPopoverControler {
    NSString *text;
    UITextView *textView;
}

+ (id)helpTooltipControllerWithText:(NSString *)helpText {
    HelpTooltipPopoverControler *controller = [[HelpTooltipPopoverControler alloc] init];
    controller->text = helpText;
    return controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    textView = [[UITextView alloc] init];
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    textView.font = [UIFont systemFontOfSize:13];
    textView.backgroundColor = [UIColor greenColor];
    textView.textColor = [UIColor whiteColor];
    textView.scrollEnabled = NO;
    textView.editable = NO;
    textView.selectable = NO;
    textView.text = text;
    [self.view addSubview:textView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[textView]|"
                                                                      options:NSLayoutFormatAlignAllCenterY
                                                                      metrics:0
                                                                        views:NSDictionaryOfVariableBindings(textView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textView]|"
                                                                      options:NSLayoutFormatAlignAllCenterX
                                                                      metrics:0
                                                                        views:NSDictionaryOfVariableBindings(textView)]];
}

- (CGSize)preferredContentSize {
    BOOL is_iPhone = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
    return [textView sizeThatFits:CGSizeMake(is_iPhone ? 200 : 300, INFINITY)];
}

@end


/**************************************************************  TLFormField  ************************************************************************/
//The base class for the form fields

@implementation TLFormField {
    NSLayoutConstraint *hiddenConstraint;
    UIPopoverController *popover;
}

#pragma mark - Field Setup

+ (Class)classForFieldType:(TLFormFieldType)fieldType {
    switch (fieldType) {
        case TLFormFieldTypeImage:
            return [TLFormFieldImage class];
        case TLFormFieldTypeTitle:
            return [TLFormFieldTitle class];
        case TLFormFieldTypeSingleLine:
            return [TLFormFieldSingleLine class];
        case TLFormFieldTypeMultiLine:
            return [TLFormFieldMultiLine class];
        case TLFormFieldTypeList:
            return [TLFormFieldList class];
        default:
            return nil;
    }
}

+ (id)formFieldWithType:(TLFormFieldType)fieldType name:(NSString *)fieldName title:(NSString *)title andDefaultValue:(id)defaultValue {
    Class fieldClass = [self classForFieldType:fieldType];
    return [[fieldClass alloc] initWithType:fieldType name:fieldName title:title andDefaultValue:defaultValue];
}

- (id)initWithType:(TLFormFieldType)fieldType name:(NSString *)fieldName title:(NSString *)title andDefaultValue:(id)defaultValue {
    self = [super init];
    
    if (self) {
        self.fieldName = fieldName;
        self.defautValue = defaultValue;
        self.title = title;
        self.fieldType = fieldType;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
#ifdef TLFormViewLayoutDebug
        self.backgroundColor = [UIColor colorWithRed:(rand() % 255)/255.0 green:(rand() % 255)/255.0 blue:(rand() % 255)/255.0 alpha:1.0];
#endif
    }
    
    return self;
}

- (NSDictionary *)defaultMetrics {
    return @{@"sp": @1.0,   //small padding
             @"np": @2.0,   //normal padding
             @"bp": @4.0};  //big padding
}

- (void)setupFieldWithInputType:(TLFormFieldInputType)inputType forEdit:(BOOL)editing {
    self.inputType = inputType;
    
    if (editing) {
        //Set the border of the field
        self.layer.cornerRadius = 5.0;
        self.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        self.layer.borderWidth = 0.5;
    }
}

#pragma mark - Hidden

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    
    if (hidden) {
        hiddenConstraint = [NSLayoutConstraint constraintWithItem:self
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:0
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0
                                                         constant:0.0];
        [self.superview addConstraint:hiddenConstraint];
    } else {
        [self.superview removeConstraint:hiddenConstraint];
        hiddenConstraint = nil;
    }
}

#pragma mark - Value

- (void)setValue:(id)fieldValue {
    
}

- (id)getValue {
    return self.defautValue;
}

#pragma mark - Title View

- (UIView *)titleView {
    
    UILabel *title = [[UILabel alloc] init];
    title.numberOfLines = 2;
    title.lineBreakMode = NSLineBreakByWordWrapping;
    title.font = [UIFont systemFontOfSize:self.titleLabelFontSize];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.text = self.title;
    
    if (self.helpText) {
        UIButton *showHelpButton = [[UIButton alloc] init];
        showHelpButton.translatesAutoresizingMaskIntoConstraints = NO;
        showHelpButton.titleLabel.font = [UIFont systemFontOfSize:25];
        [showHelpButton setTitle:@"?" forState:UIControlStateNormal];
        [showHelpButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [showHelpButton addTarget:self action:@selector(showHelpAction:) forControlEvents:UIControlEventTouchUpInside];
        showHelpButton.contentEdgeInsets = UIEdgeInsetsMake(1, 1, 1, 1);
        
        UIView *titleContainer = [[UIView alloc] init];
        titleContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [titleContainer addSubview:title];
        [titleContainer addSubview:showHelpButton];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(title, showHelpButton);
        [titleContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[title]-[showHelpButton]|"
                                                                               options:NSLayoutFormatAlignAllCenterY
                                                                               metrics:nil
                                                                                 views:views]];
        [titleContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[showHelpButton]|"
                                                                               options:NSLayoutFormatAlignAllCenterX
                                                                               metrics:nil
                                                                                 views:views]];
        return titleContainer;
    } else
        return title;
}

- (void)showHelpAction:(UIButton *)sender {
    popover = [[UIPopoverController alloc] initWithContentViewController:[HelpTooltipPopoverControler helpTooltipControllerWithText:self.helpText]];
    popover.backgroundColor = [UIColor greenColor];
    [popover presentPopoverFromRect:sender.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

@end
