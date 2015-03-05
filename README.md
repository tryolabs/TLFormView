# TLFormView

[![CI Status](http://img.shields.io/travis/BrunoBerisso/TLFormView.svg?style=flat)](https://travis-ci.org/BrunoBerisso/TLFormView)
[![Version](https://img.shields.io/cocoapods/v/TLFormView.svg?style=flat)](http://cocoadocs.org/docsets/TLFormView)
[![License](https://img.shields.io/cocoapods/l/TLFormView.svg?style=flat)](http://cocoadocs.org/docsets/TLFormView)
[![Platform](https://img.shields.io/cocoapods/p/TLFormView.svg?style=flat)](http://cocoadocs.org/docsets/TLFormView)

TLFormView is _yet another_ form view with the differential that it's trully universal. This means that the same component provide support for both iPhone and iPad using the [Auto Layout Visual Format](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage/VisualFormatLanguage.html#//apple_ref/doc/uid/TP40010853-CH3-SW11) to adjust the layout to the runing device. You can also opt to use a default implementation, through TLFormModel class, that will show all the filds in a UITableView like layout.

It also has some nice fetures like: conditional visibility using ``NSPredicate``, in-place help for each field and edit/read only modes to name a few.

## How it works

TLFormView inherit from UIScrollView and add a data source, a delegate and a method ``setupFields`` that start the process of building the form.

When that method is call the process start by calling the ``fieldNamesToShowInFormView:`` method of the data source to get an array of strings. Each string will identify a field in the form and will be used in subsecuent operations.

```objective-c
- (NSArray *)fieldNamesToShowInFormView:(TLFormView *)form {
    return @[
        @"user_info",
        @"avatar",
        @"name",
        @"age",
        @"is_active",
        @"hobbies",
        @"description",
        @"friends"
    ];
}
```

Then the datasource is ask to return a ``TLFormField`` for each of this field names. The ``TLFormField`` class represent one field to be show in the form. It contains all the information for display a value in the form, among other things.

```objective-c
- (TLFormField *)formView:(TLFormView *)form fieldForName:(NSString *)fieldName {
    ...
    TLFormField *field = [TLFormField formFieldWithType:TLFormFieldTypeSingleLine
                                                   name:fieldName 
                                                  title:@"Some really cool title" 
                                        andDefaultValue:@42];
    ...
    return field;
}
```

When you create a ``TLFormField`` with the default constructor you need to specify: a field type, the field name used to identify the field, a title and a default value. The field type is one of the values enumerated in the ``TLFormFieldType`` enum type, check the definition for a list of all supported values. The name is usually (or allways) the same value passed in to the ``fieldForName:`` method. The Title is the field title that will be shown to the user in a label and the default value is a value to use when there is no value. It's useful when the form is in edit mode and you want to provide the user with a preset for certain value. You can omite the default value here and add an implementation for ``formView:valueForFieldWithName:`` and return the values for all the fields.

Once all the fields are created one last call is made, ``constraintsFormatForFieldsInForm:``. This method return an array of constraint definitions using the auto layout visual format that will position all the fields on the screen. The fields are referenced using their field names. You can check for the runing device here and change the layout depending on the device.

```objective-c
- (NSArray *)constraintsFormatForFieldsInForm:(TLFormView *)form {
    ...
    if (isIPhone) {
        ...
    } else {
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
        
            @"V:[is_active]-[hobbies(==name)]",
            @"H:|-[avatar]-[hobbies]-|",
        
            //And the "description" and "firends" below
            @"V:[avatar]-[description]",
            @"V:[hobbies]-[description]",
            @"H:|-[description]-|",
        
            @"V:[description]-[friends]-|",
            @"H:|-[friends]-|",
        ];
    }
}
```

Once you have this methods implemented the form will be functional for read only and edit mode.

## Usage

To use the form you have two options: implement the ``TLFormViewDelegate`` and ``TLFormViewDataSource`` protocols yourself or use the ``TLFormModel`` helper class.

The ``TLFormModel`` class implement both protocols and provide an alternative way to define the form. You must create a class that extend the ``TLFormModel`` class and add the form fields as properties. For example, this is a class that define a "user" update form:

```objective-c
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
```

The implementation of the ``TLFormViewDataSource`` use reflexion to read the property defined and infere the form fields from there. Here the types of the properties are empty extensions to the fundation classes (``TLFormText`` extend ``NSString``, etc).

The implementation of the ``TLFormViewDelegate`` keep the values in the ``User``object updated so it work like a one directional binding in edit mode. Check the example project for more details.

To run the example project run `pod try TLFormView` on the terminal or clone the repo and open the project on the `Example/` folder.

## Requirements

iOS >= 8.0

## Installation

TLFormView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "TLFormView"

Or clone the repo and check the code under `Pod/Classes`.

## Todo

There are many things that need improvement, here are some:

- [ ] Better docs
- [ ] TLFormDate support
- [ ] Centralized style using the methods on ``TLFormField+UIAppearance.h``
- [ ] Expose the ‘defaultMetrics’ as part of the style
- [ ] Review TLFormField naming (fielName -> name, etc)
- [ ] TLFormModel: look a better way to make objects mutations more efficient
- [ ] Add keyboard next/prev buttons
- [ ] Add selection support for list types
- [ ] Add image picker support (take a photo / choose from album)
- [ ] Validate with predicate
- [ ] Addaptative enum values: when the options are more than some ’n’ use a UIPicker instead of a UISegmented
- [ ] Add support for enum of any type (right now only strings are supported)
- [ ] Refactor the TLFormView to TLFormViewController so we can automatically handle: choose fotos, add a string to a list, layout for orientation, etc (?)

If you want to contribut to the project please consider pick one of this items.

## Author

BrunoBerisso, bruno@tryolabs.com

## License

TLFormView is available under the MIT license. See the LICENSE file for more info.

