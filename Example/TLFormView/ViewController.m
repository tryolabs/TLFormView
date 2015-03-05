//
//  ViewController.m
//  TLFormView
//
//  Created by Bruno Berisso on 2/23/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

#import "ViewController.h"
#import "TLFormView.h"
#import "TLFormModel.h"
#import "TLFormField+UIAppearance.h"


@interface UserModel : TLFormModel

@property (nonatomic, strong) TLFormTitle *user_info;
@property (nonatomic, strong) TLFormImage *avatar;
@property (nonatomic, strong) TLFormText *name;
@property (nonatomic, strong) TLFormNumber *age;
@property (nonatomic, strong) TLFormBoolean *is_active;
@property (nonatomic, strong) TLFormEnumerated *hobbies;
@property (nonatomic, strong) TLFormSeparator *separator;
@property (nonatomic, strong) TLFormLongText *_description;
@property (nonatomic, strong) TLFormList *friends;

@end

@implementation UserModel

- (TLFormField *)formView:(TLFormView *)form fieldForName:(NSString *)fieldName {
    
    TLFormField *field = [super formView:form fieldForName:fieldName];
    
    //Add an explanation of the field. If this property has a value a quetion mark icon is display next to the field title.
    if ([fieldName isEqualToString:@"is_active"])
        field.helpText = @"A user is active when this value is true. Otherwise the user is not active (inactive) and this value shall be false. Only avtive users can have hobbies.";
    
    //The "hobbies" field will be visible only when the user "is active"
    else if ([fieldName isEqualToString:@"hobbies"])
        field.visibilityPredicate = [NSPredicate predicateWithFormat:@"$is_active.value == YES"];
    
    return field;
}

- (NSArray *)constraintsFormatForFieldsInForm:(TLFormView *)form {
    
    //For iPhone use the default implementation on TLFormModel (UITableView-like layout)
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        return [super constraintsFormatForFieldsInForm:form];
    
    //For iPad we are going to place the personal info next to the avatar image and the description and list of friends below
    else {
        
        return @[
             //Put the title at the top
             @"V:|-[user_info]",
             @"H:|-[user_info]-|",
             
             //Place the avatar on the top left
             @"V:[user_info]-[avatar(==230)]",
             @"H:|-[avatar]",
             
             //Now place all the first section fields to the right
             @"V:[user_info]-[name(>=44)]",
             @"H:|-[avatar]-[name]-|",
             
             @"V:[name]-[age(==name)]",
             @"H:|-[avatar(==420)]-[age]-|",
             
             @"V:[age]-[is_active(==name)]",
             @"H:|-[avatar]-[is_active]-|",
             
             @"V:[is_active]-[hobbies(==name@50)]", //Set a low priority to the height constraint so this is the one that the system will break when the field is hidden
             @"H:|-[avatar]-[hobbies]-|",
             
             //Add the separator
             @"V:[avatar]-[separator]",
             @"V:[hobbies]-[separator]",
             @"H:|-[separator]-|",
             
             //And the "description" and "firends" below
             @"V:[separator]-[_description]",
             @"H:|-[_description]-|",
             
             @"V:[_description]-[friends]-|",
             @"H:|-[friends]-|",
        ];
    }
}

@end






@interface ViewController () <TLFormViewDelegate>
@property (weak, nonatomic) IBOutlet TLFormView *form;
@end

@implementation ViewController {
    UserModel *user;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    user = [[UserModel alloc] init];
    user.name = TLFormTextValue(@"Some Long Name");
    user.age = TLFormNumberValue(@42);
    user.is_active = TLFormBooleanValue(YES);
    user._description = TLFormLongTextValue(@"It is possible to subclass NSString (and NSMutableString), but doing so requires providing storage facilities for the string (which is not inherited by subclasses) and implementing two primitive methods. The abstract NSString and NSMutableString classes are the public interface of a class cluster consisting mostly of private, concrete classes that create and return a string object appropriate for a given situation. Making your own concrete subclass of this cluster imposes certain requirements (discussed in “Methods to Override”).");
    user.friends = TLFormListValue(@[@"friend 0", @"friend 1", @"friend 2", @"friend 3", @"friend 4"]);
    user.hobbies = TLFormEnumeratedValue(@"other 1", @[@"other 1", @"other 2"]);
    
    NSURL *url = [NSURL URLWithString:@"https://s-media-cache-ak0.pinimg.com/custom_covers/216x146/413557246971119139_1385652535.jpg"];
    user.avatar = TLFormImageValue(url);
    
    self.form.formDataSource = user;
    self.form.formDelegate = user;
    self.form.margin = 0.0;
    
    self.form.backgroundColor = [UIColor lightGrayColor];
    [[TLFormField appearance] setBackgroundColor:[UIColor whiteColor]];
    [[TLFormField appearance] setHightlightColor:[UIColor blueColor]];
    [[TLFormField textFieldAppearance] setBorderStyle:UITextBorderStyleRoundedRect];
    [[TLFormField segmentedAppearance] setTintColor:[UIColor blueColor]];
    [[TLFormField addButtonAppearance] setHidden:YES];
}

- (IBAction)toggleEditionAction:(id)sender {
    self.form.editing = !self.form.editing;
    [self.form setupFields];
}

@end
