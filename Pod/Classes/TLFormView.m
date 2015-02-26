//
//  TLFormView.m
//  GT
//
//  Created by Bruno Berisso on 3/19/14.
//  Copyright (c) 2014 Gathered Table LLC. All rights reserved.
//

#import "TLFormView.h"
#import "TLFormField+Protected.h"


//Uncoment this to color all the subviews to chack any posible layout issues
//#define TLFormViewLayoutDebug


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

    //The default margin is 20.0 this value looks better on iPhone
    self.margin = 8.0;
    
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
    if ([self.formDelegate respondsToSelector:@selector(formView:didSelecteField:)])
        [self.formDelegate formView:self didSelecteField:field];
}

- (void)listTypeField:(TLFormField *)field didDeleteRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.formDelegate respondsToSelector:@selector(formView:listTypeField:didDeleteRowAtIndexPath:)])
        [self.formDelegate formView:self listTypeField:field didDeleteRowAtIndexPath:indexPath];
}

- (BOOL)listTypeField:(TLFormField *)field canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.formDelegate respondsToSelector:@selector(formView:listTypeField:canMoveRowAtIndexPath:)])
        return [self.formDelegate formView:self listTypeField:field canMoveRowAtIndexPath:indexPath];
    else
        return NO;
}

- (void)listTypeField:(TLFormField *)field moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if ([self.formDelegate respondsToSelector:@selector(formView:listTypeField:moveRowAtIndexPath:toIndexPath:)])
        [self.formDelegate formView:self listTypeField:field moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
}

- (void)didChangeValueForField:(TLFormField *)field newValue:(id)value {
    if ([self.formDelegate respondsToSelector:@selector(formView:didChangeValueForField:newValue:)])
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
        
        [vConstraints appendFormat:@"margin-[%@]-", key];
        [hConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subView(==auxView)]|"
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:NSDictionaryOfVariableBindings(subView, auxView)]];
    }
    
    [vConstraints appendString:@"margin-|"];
    
    //Add the vertical and horizontal constraints
    [auxView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vConstraints
                                                                    options:0
                                                                    metrics:@{@"margin": @(self.margin)}
                                                                      views:views]];
    [auxView addConstraints:hConstraints];
}

- (void)setupLayoutWithConstraints:(NSArray *)constraintFomats {
    
    //This make the margin available in the rules
    NSDictionary *defaultMetrics = @{@"margin": @(self.margin)};
    
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
            [values setObject:value forKey:field.fieldName];
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