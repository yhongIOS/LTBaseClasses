//
//  LTTextViewController.m
//  LTBaseClass
//
//  Created by 洪峰 on 2018/3/5.
//  Copyright © 2018年 洪峰. All rights reserved.
//

#import "LTTextViewController.h"
#import "IQUIView+Hierarchy.h"
#import "IQKeyboardManager.h"
#import "IQKeyboardReturnKeyHandler.h"
#import "NSObject+YYAdd.h"
#import "NSString+YYAdd.h"
#import "LTBaseClassMacro.h"

@interface LTTextViewController ()


@property (nonatomic, strong) NSArray<UITextField *> *requiredTextFields;


@property (nonatomic, strong) IQKeyboardReturnKeyHandler *returnKeyHandler;

@end

@implementation LTTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initKeyboard];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (_returnKeyHandler) {
        [_returnKeyHandler setDelegate:nil];
        _returnKeyHandler = nil;
    }
}

#pragma mark - UITextViewDelegate, UITextFieldDelegate

#pragma mark - 处理 returnKey
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (![IQKeyboardManager sharedManager].canGoNext) {
        [self textViewController:self inputViewDone:textField];
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (![IQKeyboardManager sharedManager].canGoNext && [text isEqualToString:@"\n"]) {
        [self textViewController:self inputViewDone:textView];
    }
    return YES;
}

#pragma mark - LTTextViewControllerDelegate
- (void)textViewController:(LTTextViewController *)textViewController inputViewDone:(id)inputView {
    NSLog(@"%@, %@", self.requiredTextFields, inputView);
}

#pragma mark - autoEmpty

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // 九宫格 bug fix
    if ([@"➋➌➍➎➏➐➑➒" rangeOfString:string].location != NSNotFound) {
        return YES;
    }
    NSString *current = [textField.text stringByReplacingCharactersInRange:range withString:string.stringByTrim].stringByTrim;
    
    if (textField.isEmptyAutoEnable && (LTIsEmpty(textField.text.stringByTrim) || LTIsEmpty(current))) {
        if (LTIsEmpty(current)) {
            [self checkIsEmpty:YES textField:textField];
        }else
        {
            [self checkIsEmpty:NO textField:textField];
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField.isEmptyAutoEnable) {
        [self checkIsEmpty:YES textField:textField];
    }
    return YES;
}


#pragma mark - 设置 btn的 enable
- (void)checkIsEmpty:(BOOL)isEmpty textField:(UITextField *)textField {
    if (LTIsEmpty(self.requiredTextFields)) {
        return;
    }
    
    if ([self respondsToSelector:@selector(textViewControllerRelationButtons:)]) {
        if (LTIsEmpty([self textViewControllerRelationButtons:self])) {
            return;
        }
    }else
    {
        return;
    }
    
    __block BOOL isButtonEnabled = !isEmpty;
    
    if (!isEmpty) {
        [self.requiredTextFields enumerateObjectsUsingBlock:^(UITextField *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj != textField && LTIsEmpty(obj.text.stringByTrim)) {
                isButtonEnabled = NO;
                *stop = YES;
            }
        }];
    }
    
    [[self textViewControllerRelationButtons:self] enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.enabled = isButtonEnabled;
    }];
}



#pragma mark - 初始化
- (void)initKeyboard {
    // 键盘
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
    manager.shouldResignOnTouchOutside = YES;
    manager.shouldToolbarUsesTextFieldTintColor = YES;
    manager.enableAutoToolbar = [self textViewControllerEnableAutoToolbar:self];
    manager.shouldPlayInputClicks = YES;
    manager.shouldShowToolbarPlaceholder = YES;
    
    [self requiredTextFields];
    [self initReturnKeyHandler];;
}



#pragma mark - LTTextViewControllerDataSource

- (BOOL)textViewControllerEnableAutoToolbar:(LTTextViewController *)textViewController
{
    return YES;
}

- (UIReturnKeyType)textViewControllerLastReturnKeyType:(LTTextViewController *)textViewController
{
    return UIReturnKeyDone;
}


- (NSArray<UITextField *> *)requiredTextFields {
    if(_requiredTextFields == nil)
    {
        NSArray *responsedInputViews = [self.view deepResponderViews];
        NSMutableArray<UITextField *> *array = [NSMutableArray array];
        [responsedInputViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj isKindOfClass:[UITextField class]]) {
                
                UITextField *field = (UITextField *)obj;
                field.delegate = self;
                
                if (field.isEmptyAutoEnable) {
                    [array addObject:field];
                }
            }
            
            if ([obj isKindOfClass:[UITextView class]]) {
                UITextView *textView = (UITextView *)obj;
                textView.delegate = self;
            }
        }];
        
        _requiredTextFields = array;
    }
    return _requiredTextFields;
}


- (void)initReturnKeyHandler {
    if(_returnKeyHandler == nil) {
        _returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
        _returnKeyHandler.delegate = self;
        _returnKeyHandler.lastTextFieldReturnKeyType = [self textViewControllerLastReturnKeyType:self];
    }
}


- (void)dealloc
{
    _returnKeyHandler = nil;
}

@end



#pragma mark - LTTextViewControllerTextField

static void *isEmptyAutoEnableKey = &isEmptyAutoEnableKey;
@implementation UITextField (LTTextViewController)

- (void)setIsEmptyAutoEnable:(BOOL)isEmptyAutoEnable
{
    [self setAssociateValue:@(isEmptyAutoEnable) withKey:isEmptyAutoEnableKey];
}

- (BOOL)isEmptyAutoEnable
{
    return [(NSNumber *)[self getAssociatedValueForKey:isEmptyAutoEnableKey] boolValue];
}
@end

@implementation LTTextViewControllerTextField
- (NSString *)text {
    return ([[super text] stringByTrim]);
}
@end

