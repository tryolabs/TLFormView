//
//  TLFormView.m
//  GT
//
//  Created by Bruno Berisso on 3/19/14.
//  Copyright (c) 2014 Gathered Table LLC. All rights reserved.
//

#import "TLFormView.h"



//Uncoment this to color all the subviews to chack any posible layout issues
//#define TLFormViewLayoutDebug



@interface UIView (Glow)
- (void)setShowGlow:(BOOL)showGlow;
@end

@implementation UIView (Glow)

- (void)setShowGlow:(BOOL)showGlow {
    if (showGlow) {
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowRadius = 4.0f;
        self.layer.shadowOpacity = .9;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.masksToBounds = NO;
    } else {
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowRadius = 4.0f;
        self.layer.shadowOpacity = 0.0;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.masksToBounds = NO;
    }
}

@end



//Private delegate to pass events from the fields to the form

@protocol TLFormFieldDelegate <NSObject>

- (void)didSelectField:(TLFormField *)field;
- (void)listTypeField:(TLFormField *)field didDeleteRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)listTypeField:(TLFormField *)field canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)listTypeField:(TLFormField *)field moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;
- (void)didChangeValueForField:(TLFormField *)field newValue:(id)value;

@end


//Forward declaration of some properties and methods used for the subclases

@interface TLFormField ()

@property (nonatomic, strong) id defautValue;
@property (nonatomic, weak) id <TLFormFieldDelegate> delegate;
@property (nonatomic, assign) CGFloat titleLabelFontSize;
@property (nonatomic, readonly) NSDictionary *defaultMetrics;

- (void)setupFieldWithInputType:(TLFormFieldInputType)inputType forEdit:(BOOL)editing;
- (void)setValue:(id)fieldValue;
- (id)getValue;
- (UIView *)titleView;

@end


#pragma mark - TLFormFieldImage
/************************************************************************************************************************************************/
/***********************************************************  TLFormFieldImage  *****************************************************************/
/************************************************************************************************************************************************/

@interface TLFormFieldImage : TLFormField

@end

@implementation TLFormFieldImage {
    UIImageView *imageView;
    //The reference to an image used to get the UIImage that will be loaded
    id imageRefValue;
}

- (void)setupFieldWithInputType:(TLFormFieldInputType)inputType forEdit:(BOOL)editing {
    [super setupFieldWithInputType:inputType forEdit:editing];
    
    imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:imageView];
    
    UIButton *tapRecognizer = [[UIButton alloc] init];
    tapRecognizer.translatesAutoresizingMaskIntoConstraints = NO;
    [tapRecognizer addTarget:self action:@selector(imageSelectedAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:tapRecognizer];
    
    NSDictionary *views;
    
    if (editing) {
        UIView *title = [self titleView];
        [self addSubview:title];
        
        views = NSDictionaryOfVariableBindings(imageView, tapRecognizer, title);
        
        //Size the title to the top of the field taking all the widht
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[title]|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        //Constraint the imageView to the size of the super view
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[title][imageView]|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        //Constraint the tapRecognizer to the size of the super view
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[title][tapRecognizer]|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tapRecognizer]|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
    } else {
        views = NSDictionaryOfVariableBindings(imageView, tapRecognizer);
        
        //Constraint the imageView to the size of the super view
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        
        //Constraint the tapRecognizer to the size of the super view
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tapRecognizer]|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tapRecognizer]|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
    }
    
    [self setValue:self.defautValue];
}

- (void)setValue:(id)fieldValue {
    
    imageRefValue = fieldValue;
    
    if (!fieldValue)
        imageView.image = [UIImage imageNamed:@"no_image.jpg"];
    
    //If the value is an string interpret it as an URL
    else if ([fieldValue isKindOfClass:[NSString class]]) {
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        spinner.translatesAutoresizingMaskIntoConstraints = NO;
        [imageView addSubview:spinner];
        [imageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[spinner]-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(spinner)]];
        [imageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[spinner]-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(spinner)]];
        
//        [imageView setImageWithURL:fieldValue placeholderImage:[UIImage imageNamed:@"placeholder.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//            [spinner removeFromSuperview];
//        }];
    }
    
    else if ([fieldValue isKindOfClass:[UIImage class]])
        imageView.image = fieldValue;
}

- (id)getValue {
    return imageRefValue;
}

- (void)imageSelectedAction {
    [self.delegate didSelectField:self];
}

@end

/******************************************************************  END  ***********************************************************************/
/************************************************************************************************************************************************/


#pragma mark - TLFormFieldTitle
/************************************************************************************************************************************************/
/***********************************************************  TLFormFieldTitle  *****************************************************************/
/************************************************************************************************************************************************/

@interface TLFormFieldTitle : TLFormField

@end

@implementation TLFormFieldTitle {
    UILabel *titleLabel;
}

- (void)setupFieldWithInputType:(TLFormFieldInputType)inputType forEdit:(BOOL)editing {
    [super setupFieldWithInputType:inputType forEdit:editing];
    
    titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    titleLabel.numberOfLines = 0;
    
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

#pragma mark - TLFormFieldSingleLine
/************************************************************************************************************************************************/
/********************************************************  TLFormFieldSingleLine  ***************************************************************/
/************************************************************************************************************************************************/

@interface TLFormFieldSingleLine : TLFormField <UITextFieldDelegate>

@end

@implementation TLFormFieldSingleLine

- (void)setupFieldWithInputType:(TLFormFieldInputType)inputType forEdit:(BOOL)editing {
    [super setupFieldWithInputType:inputType forEdit:editing];
    
    self.titleLabelFontSize = editing ? 14 : 12;
    UIView *titleView = [self titleView];
    [self addSubview:titleView];
    
    if (editing) {
        
        //This is needed to properly adjust the title when the text has more than one line
        [titleView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        
        switch (inputType) {
                
            case TLFormFieldInputTypeCustom:
            case TLFormFieldInputTypeNumeric:
            case TLFormFieldInputTypeDefault: {
                
                UITextField *textField = [[UITextField alloc] init];
                textField.tag = 1001;
                textField.font = [UIFont systemFontOfSize:self.titleLabelFontSize];
                textField.borderStyle = UITextBorderStyleRoundedRect;
                textField.translatesAutoresizingMaskIntoConstraints = NO;
                textField.delegate = self;
                
                [self addSubview:textField];
                
                NSDictionary *views = NSDictionaryOfVariableBindings(titleView, textField);
                
                if (inputType == TLFormFieldInputTypeNumeric) {
                    textField.keyboardType = UIKeyboardTypeNumberPad;
                    
                    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-np-[titleView]-bp-[textField(==70)]-np-|"
                                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                                 metrics:self.defaultMetrics
                                                                                   views:views]];
                    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-sp-[titleView]-sp-|"
                                                                                 options:NSLayoutFormatAlignAllCenterX
                                                                                 metrics:self.defaultMetrics
                                                                                   views:views]];
                    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-sp-[textField]-sp-|"
                                                                                 options:NSLayoutFormatAlignAllCenterX
                                                                                 metrics:self.defaultMetrics
                                                                                   views:views]];
                } else {
                    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-sp-[titleView]-sp-[textField]-sp-|"
                                                                                 options:NSLayoutFormatAlignAllCenterX
                                                                                 metrics:self.defaultMetrics
                                                                                   views:views]];
                    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-np-[titleView]-np-|"
                                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                                 metrics:self.defaultMetrics
                                                                                   views:views]];
                    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-np-[textField]-np-|"
                                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                                 metrics:self.defaultMetrics
                                                                                   views:views]];
                }
                
                break;
            }
                
            case TLFormFieldInputTypeInlineSelect: {
                
                UISegmentedControl *segmented = [[UISegmentedControl alloc] init];
                segmented.tag = 1001;
                segmented.translatesAutoresizingMaskIntoConstraints = NO;
//                segmented.tintColor = [UIColor gt_greenColor];
                segmented.backgroundColor = [UIColor whiteColor];
                [segmented addTarget:self action:@selector(controlValueChange) forControlEvents:UIControlEventValueChanged];
                
                for (NSString *choice in self.choicesValues)
                    [segmented insertSegmentWithTitle:choice atIndex:[self.choicesValues indexOfObject:choice] animated:NO];
                
//                [[UISegmentedControl appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont gt_fontWithSize:12.0]} forState:UIControlStateNormal];
                
                [self addSubview:segmented];
                
                NSDictionary *views = NSDictionaryOfVariableBindings(titleView, segmented);
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleView]-3.0-[segmented]-3.0-|"
                                                                             options:NSLayoutFormatAlignAllCenterX
                                                                             metrics:self.defaultMetrics
                                                                               views:views]];
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-np-[titleView]-np-|"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:self.defaultMetrics
                                                                               views:views]];
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-np-[segmented]-np-|"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:self.defaultMetrics
                                                                               views:views]];
                break;
            }
                
            case TLFormFieldInputTypeInlineYesNo: {
                
                UISwitch *yesNoSelect = [[UISwitch alloc] init];
                yesNoSelect.tag = 1001;
                yesNoSelect.translatesAutoresizingMaskIntoConstraints = NO;
//                yesNoSelect.tintColor = [UIColor gt_greenColor];
                [yesNoSelect addTarget:self action:@selector(controlValueChange) forControlEvents:UIControlEventValueChanged];
                
                [self addSubview:yesNoSelect];
                
                NSDictionary *views = NSDictionaryOfVariableBindings(titleView, yesNoSelect);
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-np-[titleView]-bp-[yesNoSelect]-bp-|"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:self.defaultMetrics
                                                                               views:views]];
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-np-[yesNoSelect]-np-|"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:self.defaultMetrics
                                                                               views:views]];
                break;
            }
            default:
                break;
        }
        
        
    } else {
        
        UILabel *valueLabel = [[UILabel alloc] init];
        valueLabel.tag = 1001;
//        valueLabel.font = [UIFont gt_fontWithSize:12];
        valueLabel.numberOfLines = 1;
        valueLabel.textAlignment = NSTextAlignmentRight;
        valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:valueLabel];
        
        //Adjust the compression resistance for each view so the labels resize always in the same way when the size of the container change. Without this set explicitly
        //the behavior is inconsistent
        [titleView setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [valueLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(titleView, valueLabel);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-np-[titleView]-bp-[valueLabel]-np-|"
                                                                     options:NSLayoutFormatAlignAllCenterY
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-sp-[titleView]-sp-|"
                                                                     options:NSLayoutFormatAlignAllCenterY
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-sp-[valueLabel]-sp-|"
                                                                     options:NSLayoutFormatAlignAllCenterY
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
    }
    
    [self setValue:self.defautValue];
}

- (CGSize)intrinsicContentSize {
    CGFloat width = 0.0, height = 0.0;
    
    for (UIView *subview in self.subviews) {
        width += subview.intrinsicContentSize.width;
        //Don't acumulte the height, use the maximum
        height = MAX(height, subview.intrinsicContentSize.height);
    }
    
    return CGSizeMake(width, height);
}

//Get and Set value

- (void)setValue:(id)fieldValue {
    
    if (!fieldValue)
        return;
    
    
    NSString *stringValue;
    if ([fieldValue isKindOfClass:[NSString class]] == NO)
        stringValue = [fieldValue stringValue];
    else
        stringValue = fieldValue;
    
    
    id valueView = [self viewWithTag:1001];
    
    if ([valueView respondsToSelector:@selector(setText:)])
        [valueView performSelector:@selector(setText:) withObject:stringValue];
    
    else if ([valueView isKindOfClass:[UISegmentedControl class]]) {
        UISegmentedControl *segmented = (UISegmentedControl *)valueView;
        
        for (int i = 0; i < [segmented numberOfSegments]; i++) {
            if ([stringValue isEqualToString:[segmented titleForSegmentAtIndex:i]]) {
                segmented.selectedSegmentIndex = i;
                break;
            }
        }
    }
    
    else if ([valueView isKindOfClass:[UISwitch class]]) {
        UISwitch *yesNoSelect = (UISwitch *)valueView;
        yesNoSelect.on = [fieldValue boolValue];
    }
}

- (id)getValue {
    id valueView = [self viewWithTag:1001];
    
    if ([valueView respondsToSelector:@selector(text)])
        return [valueView performSelector:@selector(text)];
    
    else if ([valueView isKindOfClass:[UISegmentedControl class]]) {
        UISegmentedControl *segmented = (UISegmentedControl *)valueView;
        return [segmented titleForSegmentAtIndex:segmented.selectedSegmentIndex];
    }
    
    else if ([valueView isKindOfClass:[UISwitch class]]) {
        UISwitch *yesNoSelect = (UISwitch *)valueView;
        return [NSNumber numberWithBool:yesNoSelect.on];
    }
    
    return nil;
}

//UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.delegate didSelectField:self];
    
    BOOL shouleEdit = self.inputType != TLFormFieldInputTypeCustom;
    [textField setShowGlow:shouleEdit];
    return shouleEdit;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField setShowGlow:NO];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *newValue = nil;
    if (string.length > 0)
        if (self.inputType == TLFormFieldInputTypeNumeric) {
            
            //The lenght constraint is allway 5 for now
            if (textField.text.length < 5) {
                
                //Check the min/max range
                if (self.minValue != self.maxValue) {
                    
                    //Get the final value
                    newValue = [textField.text stringByAppendingString:string];
                    NSInteger value = [newValue integerValue];
                    
                    //If the value is NOT in the range left it unchanged
                    if (value < self.minValue || value > self.maxValue)
                        return NO;
                } else
                    newValue = [textField.text stringByAppendingString:string];
            } else
                return NO;
            
        } else
            newValue = [textField.text stringByAppendingString:string];
    
    else
        newValue = [textField.text substringToIndex:textField.text.length - 1];
    
    [self.delegate didChangeValueForField:self newValue:newValue];
    
    return YES;
}

//UISwitch and UISegmented value change

- (void)controlValueChange {
    [self.delegate didChangeValueForField:self newValue:[self getValue]];
}

@end

/******************************************************************  END  ***********************************************************************/
/************************************************************************************************************************************************/


#pragma mark - TLFormFieldMultiLine
/************************************************************************************************************************************************/
/*********************************************************  TLFormFieldMultiLine  ***************************************************************/
/************************************************************************************************************************************************/

@interface TLFormFieldMultiLine : TLFormField <UITextViewDelegate>

@end

@implementation TLFormFieldMultiLine {
    UILabel *titleLabel;
    UITextView *textView;
}

- (void)setupFieldWithInputType:(TLFormFieldInputType)inputType forEdit:(BOOL)editing {
    [super setupFieldWithInputType:inputType forEdit:editing];
    
    titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.numberOfLines = 1;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = self.title;
    [self addSubview:titleLabel];
    
    textView = [[UITextView alloc] init];
    textView.font = [UIFont systemFontOfSize:12];
    textView.scrollEnabled = NO;
    textView.editable = editing;
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    textView.backgroundColor = [UIColor whiteColor];
    textView.delegate = self;
    [self addSubview:textView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(titleLabel, textView);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-np-[titleLabel]-np-|"
                                                                 options:0
                                                                 metrics:self.defaultMetrics
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-np-[textView]-np-|"
                                                                 options:0
                                                                 metrics:self.defaultMetrics
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-sp-[titleLabel][textView]-sp-|"
                                                                 options:0
                                                                 metrics:self.defaultMetrics
                                                                   views:views]];
    
    [self setValue:self.defautValue];
}

- (CGSize)intrinsicContentSize {
    CGFloat width = 0.0, height = 0.0;
    
    for (UIView *subview in self.subviews) {
        width += subview.intrinsicContentSize.width;
        height += subview.intrinsicContentSize.height;
    }
    
    return CGSizeMake(width, height);
}

//Get and Set value

- (void)setValue:(id)fieldValue {
    textView.text = fieldValue;
}

- (id)getValue {
    return textView.text;
}

//UITextFieldDelegate

- (void)textViewDidBeginEditing:(UITextView *)_textView {
    [_textView setShowGlow:YES];
}

- (void)textViewDidEndEditing:(UITextView *)_textView {
    [_textView setShowGlow:NO];
}

- (BOOL)textView:(UITextView *)_textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSString *newValue = nil;
    if (text.length > 0)
        newValue = [_textView.text stringByAppendingString:text];
    else
        newValue = [_textView.text substringToIndex:_textView.text.length - 1];
    
    [self.delegate didChangeValueForField:self newValue:newValue];
    return YES;
}

@end

/******************************************************************  END  ***********************************************************************/
/************************************************************************************************************************************************/


#pragma mark - TLFormFieldList
/************************************************************************************************************************************************/
/************************************************************  TLFormFieldList  *****************************************************************/
/************************************************************************************************************************************************/

@interface TLFormFieldList : TLFormField <UITableViewDataSource>

@end

@implementation TLFormFieldList {
    #define kTLFormFieldListRowHeight   44.0
    UILabel *titleLabel;
    UITableView *tableView;
    UIButton *plusButton;
    NSMutableArray *items;
}

- (void)setupFieldWithInputType:(TLFormFieldInputType)inputType forEdit:(BOOL)editing {
    [super setupFieldWithInputType:inputType forEdit:editing];
    
    titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.numberOfLines = 1;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = self.title;
    [self addSubview:titleLabel];
    
    tableView = [[UITableView alloc] init];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.scrollEnabled = NO;
    tableView.dataSource = self;
    tableView.editing = editing;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ItemCell"];
    [self addSubview:tableView];
    
    items = [self.defautValue mutableCopy];
    
    NSDictionary *views;
    
    if (editing) {
        plusButton = [[UIButton alloc] init];
        plusButton.translatesAutoresizingMaskIntoConstraints = NO;
        plusButton.titleLabel.font = [UIFont systemFontOfSize:35];
//        [plusButton setTitleColor:[UIColor gt_greenColor] forState:UIControlStateNormal];
        [plusButton setTitle:@"+" forState:UIControlStateNormal];
        [plusButton addTarget:self action:@selector(plusAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:plusButton];
        
        views = NSDictionaryOfVariableBindings(titleLabel, tableView, plusButton);
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-np-[titleLabel]-[plusButton]-bp-|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-np-[tableView]-np-|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[plusButton][tableView]-sp-|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleLabel][tableView]-sp-|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        
        //Set the compresson and hugging priorities for the title and the button so it behave correctly with long text
        [titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [plusButton setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        
    } else {
        views = NSDictionaryOfVariableBindings(titleLabel, tableView);
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-np-[titleLabel]-np-|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-np-[tableView]-np-|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleLabel][tableView]-np-|"
                                                                     options:0
                                                                     metrics:self.defaultMetrics
                                                                       views:views]];
    }
}

- (void)setValue:(id)fieldValue {
    if (items.count != [fieldValue count])
        [self invalidateIntrinsicContentSize];
    
    items = [fieldValue mutableCopy];
    [tableView reloadData];
}

- (id)getValue {
    return items;
}

- (CGSize)intrinsicContentSize {
    CGFloat width = 0.0, height = 0.0;
    
    width = titleLabel.intrinsicContentSize.width + plusButton.intrinsicContentSize.width;
    height = MAX(titleLabel.intrinsicContentSize.height, plusButton.intrinsicContentSize.height) + (items.count * kTLFormFieldListRowHeight);
    
    return CGSizeMake(width, height);
}

- (void)plusAction:(id)sender {
    [self.delegate didSelectField:self];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kTLFormFieldListRowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"ItemCell"];
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = items[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)_tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [items removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    //Invalidate the intrinsic content size so the layout is recalculated. The delay is used to let the animation end before update the layout
    [self performSelector:@selector(invalidateIntrinsicContentSize) withObject:nil afterDelay:0.3];
    
    [self.delegate listTypeField:self didDeleteRowAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)_tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.editing;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.delegate listTypeField:self canMoveRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [self.delegate listTypeField:self moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
}

@end

/******************************************************************  END  ***********************************************************************/
/************************************************************************************************************************************************/


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
//    textView.backgroundColor = [UIColor gt_greenColor];
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
//        [showHelpButton setTitleColor:[UIColor gt_greenColor] forState:UIControlStateNormal];
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
//    popover.backgroundColor = [UIColor gt_greenColor];
    [popover presentPopoverFromRect:sender.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

@end

/******************************************************************  END  ***********************************************************************/
/************************************************************************************************************************************************/


#pragma mark - TLFormView
/************************************************************************************************************************************************/
/***************************************************************  TLFormView  *******************************************************************/
/************************************************************************************************************************************************/

@interface TLFormView () <TLFormFieldDelegate>
@end


@implementation TLFormView {
    NSMutableDictionary *viewFieldMap;
    UIView *containerView;
    NSMutableArray *fieldsWithVisibilityPredicate;
    BOOL needsReload;
}

#pragma mark Initialization

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self)
        [self privateInit];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self privateInit];
}

- (void)privateInit {
    //Map the field names with the corresponding views. Used to resolv the autolayout format strings
    viewFieldMap = [NSMutableDictionary dictionary];
    
    //Fire an automaric reload on the view first display.
    needsReload = YES;
    
    //NOTE: this is commented because it breaks some layouts. It seams to be working fine because it not affect the subviews.
    //Avoid translate the posible autoresizing mask values to constraints
//    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    //This view is used to control how the fields are layed out inside the form. We need to do it this way because of how the scroll view
    //manage their content and how the scroll is implemented. (See: http://developer.apple.com/library/ios/#releasenotes/General/RN-iOSSDK-6_0/index.html
    //and http://www.g8production.com/post/57513133020/auto-layout-with-uiscrollview-how-to-use )
    
    containerView = [[UIView alloc] init];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:containerView];

    //The default padding is 20.0 this value looks better on iPhone
    self.padding = 8.0;
    
#ifdef TLFormViewLayoutDebug
    self.backgroundColor = [UIColor redColor];
    containerView.backgroundColor = [UIColor blueColor];
#endif
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (needsReload) {
        needsReload = NO;
        [self performSelectorOnMainThread:@selector(setupFields) withObject:nil waitUntilDone:NO];
    }
}

- (void)setEditingNew:(BOOL)editingNew {
    self.editing = editingNew;
    _editingNew = editingNew;
}

#pragma mark - TLFormFieldDelegate

- (void)didSelectField:(TLFormField *)field {
    if (self.formDelegate)
        [self.formDelegate formView:self didSelecteField:field];
}

- (void)listTypeField:(TLFormField *)field didDeleteRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.formDelegate)
        [self.formDelegate formView:self listTypeField:field didDeleteRowAtIndexPath:indexPath];
}

- (BOOL)listTypeField:(TLFormField *)field canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.formDataSource respondsToSelector:@selector(formView:listTypeField:canMoveRowAtIndexPath:)])
        return [self.formDelegate formView:self listTypeField:field canMoveRowAtIndexPath:indexPath];
    else
        return NO;
}

- (void)listTypeField:(TLFormField *)field moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [self.formDelegate formView:self listTypeField:field moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
}

- (void)didChangeValueForField:(TLFormField *)field newValue:(id)value {
    if (self.formDelegate)
        [self.formDelegate formView:self didChangeValueForField:field newValue:value];
    
    [self updateFieldsVisibility];
}

#pragma mark - Form fields setup

- (void)setupFields {
    
    //Remove any previous layout definition
    [containerView removeConstraints:containerView.constraints];
    //and remove all subviews
    [[containerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //Reset the list of fields with variable visibility
    fieldsWithVisibilityPredicate = [NSMutableArray array];
    
    //Ask the data source for the field names
    for (NSString *fieldName in [self.formDataSource fieldNamesToShowInFormView:self]) {
        
        //for every field name ask for the TLFormField
        TLFormField *field = [self.formDataSource formView:self fieldForName:fieldName];
        
        //Ask the data source for an input type only if we are editing
        TLFormFieldInputType inputType = TLFormFieldInputTypeDefault;
        
        if (self.editing && [self.formDataSource respondsToSelector:@selector(formView:inputTypeForFieldWithName:)])
            inputType = [self.formDataSource formView:self inputTypeForFieldWithName:fieldName];
        
        //Setup the field internal state
        [field setupFieldWithInputType:inputType forEdit:self.editing];
        
        [self addField:field];
    }
    
    //Once all fields are added ask for the layout rules and apply it to the container view
    NSArray *layout = [self.formDataSource constraintsFormatForFieldsInForm:self];
    [self setupLayoutWithConstraints:layout];
    
    //This is the main function of the 'editingNew' flag. Avoiding this call force the fields to show their default values
    if (!self.editingNew) {
        //Ask the datasource for the actual values to show
        [self reloadValues];
    }
}

- (void)addField:(TLFormField *)field {
    //Set ourself as the field delegate
    field.delegate = self;
    //update the view-fieldName map
    [viewFieldMap setValue:field forKey:field.fieldName];
    //add the field to the view tree
    [containerView addSubview:field];
    
    //Register the field if has variable visibility
    if (field.visibilityPredicate)
        [fieldsWithVisibilityPredicate addObject:field];
}

#pragma mark - Layout Setup

- (void)adjustAuxiliarViewInternalLayout:(UIView *)auxView {
    
    auxView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSMutableDictionary *views = [NSMutableDictionary dictionary];
    NSMutableString *vConstraints = [NSMutableString stringWithString:@"V:|-"];
    NSMutableArray *hConstraints = [NSMutableArray array];
    
    //Setup a set of default constraints, arrange the subviews centered in a column. This ensure that the height of the scroll can be calculated
    
    for (int i = 0; i < auxView.subviews.count; i++) {
        NSString *key = [NSString stringWithFormat:@"subView%d", i];
        UIView *subView = auxView.subviews[i];
        
        subView.translatesAutoresizingMaskIntoConstraints = NO;
        [views setObject:subView forKey:key];
        
        [vConstraints appendFormat:@"padding-[%@]-", key];
        [hConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subView(==auxView)]|"
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:NSDictionaryOfVariableBindings(subView, auxView)]];
    }
    
    [vConstraints appendString:@"padding-|"];
    
    //Add the vertical and horizontal constraints
    [auxView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vConstraints
                                                                    options:0
                                                                    metrics:@{@"padding": @(self.padding)}
                                                                      views:views]];
    [auxView addConstraints:hConstraints];
}

- (void)setupLayoutWithConstraints:(NSArray *)constraintFomats {
    
    //This make the padding available in the rules
    NSDictionary *defaultMetrics = @{@"padding": @(self.padding)};
    
    for (NSString *formatString in constraintFomats) {
        
        //Remove all the spaces
        NSString *constraintFormat = [formatString stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (constraintFormat.length > 0) {
            
            NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:constraintFormat
                                                                           options:0
                                                                           metrics:defaultMetrics
                                                                             views:viewFieldMap];
            [containerView addConstraints:constraints];
        }
    }
    
    //Add constraints for the content view to adjust the size to the form
    NSMutableDictionary *views = [NSMutableDictionary dictionaryWithObjects:@[containerView, self] forKeys:@[@"containerView", @"self"]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[containerView(==self)]|"
                                                                 options:0
                                                                 metrics:0
                                                                   views:views]];
    
    //Add the header and footer
    if (self.header) {
        [self adjustAuxiliarViewInternalLayout:self.footer];
        [self addSubview:self.header];
        
        [views setObject:self.header forKey:@"header"];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[header(==self)]|"
                                                                     options:0
                                                                     metrics:0
                                                                       views:views]];
    }
    
    if (self.footer) {
        [self adjustAuxiliarViewInternalLayout:self.footer];
        [self addSubview:self.footer];
        
        [views setObject:self.footer forKey:@"footer"];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[footer(==self)]|"
                                                                     options:0
                                                                     metrics:0
                                                                       views:views]];
    }
    
    NSString *verticalConstraintFormat = [NSString stringWithFormat:@"V:|%@[containerView]%@|",
                                          self.header ? @"[header]" : @"",
                                          self.footer ? @"[footer]" : @""];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalConstraintFormat
                                                                 options:0
                                                                 metrics:0
                                                                   views:views]];
}

#pragma mark - Field Values Management

- (NSDictionary *)valuesForFields {
    NSMutableDictionary *values = [NSMutableDictionary dictionary];
    
    for (TLFormField *field in [viewFieldMap allValues]) {
        id value = [field getValue];
        if (value)
            [values setObject:[field getValue] forKey:field.fieldName];
    }
    
    return values;
}

- (void)updateFieldsVisibility {
    for (TLFormField *field in fieldsWithVisibilityPredicate) {
        BOOL isVisible = [field.visibilityPredicate evaluateWithObject:field substitutionVariables:viewFieldMap];
        field.hidden = !isVisible;
    }
}

- (void)reloadValues {
    
    if ([self.formDataSource respondsToSelector:@selector(formView:valueForFieldWithName:)]) {
        for (TLFormField *field in [viewFieldMap allValues]) {
            id value = [self.formDataSource formView:self valueForFieldWithName:field.fieldName];
            [field setValue:value];
        }
        
        [self updateFieldsVisibility];
    }
}

@end