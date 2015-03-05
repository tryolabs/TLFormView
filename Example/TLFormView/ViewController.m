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
        field.helpText = @"A user is active when this value is true. Otherwise the user is not active (inactive) and this value shall be false. Only active users can have hobbies.";
    
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
    
    //Create and setup the object that describe the form.
    user = [[UserModel alloc] init];
    user.name = TLFormTextValue(@"John Doe");
    user.age = TLFormNumberValue(@42);
    user.is_active = TLFormBooleanValue(YES);
    user.friends = TLFormListValue(@[@"friend 0", @"friend 1", @"friend 2", @"friend 3", @"friend 4"]);
    user.hobbies = TLFormEnumeratedValue(@"3D printing", @[@"3D printing", @"Amateur radio", @"Acting"]);
    
    user._description = TLFormLongTextValue(@"Michael O. Church about OOP: \"OOP tries to make software look like \"the real world\" as can be understood by an average person. (CheckingAccount extends Account extends HasBalance extends Object). The problem is that it encourages people to program before they think, and it allows software to be created that mostly works but no one knows why it does.\"");
    //Check about this passage here: http://www.quora.com/Was-object-oriented-programming-a-failure
    
    NSURL *url = [NSURL URLWithString:@"https://s-media-cache-ak0.pinimg.com/custom_covers/216x146/413557246971119139_1385652535.jpg"];
    user.avatar = TLFormImageValue(url);
    
    //Set the model as data source and delegate of the form.
    self.form.formDataSource = user;
    self.form.formDelegate = user;
    
    //Make some visual tweaks
    self.form.margin = 0.0;
    self.form.backgroundColor = [UIColor lightGrayColor];
    
    [[TLFormField appearance] setBackgroundColor:[UIColor whiteColor]];
    [[TLFormField appearance] setHightlightColor:[UIColor blueColor]];
    [[TLFormField textFieldAppearance] setBorderStyle:UITextBorderStyleRoundedRect];
    [[TLFormField segmentedAppearance] setTintColor:[UIColor blueColor]];
    
    //Hide the plus button on the list of friends when the form is in edit mode.
    [[TLFormField addButtonAppearance] setHidden:YES];
}

- (IBAction)toggleEditionAction:(id)sender {
    self.form.editing = !self.form.editing;
    [self.form setupFields];
}

@end
