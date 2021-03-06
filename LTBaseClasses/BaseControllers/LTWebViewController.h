//
//  LTWebViewController.h
//  LTBaseClass
//
//  Created by 洪峰 on 2018/3/5.
//  Copyright © 2018年 洪峰. All rights reserved.
//

#import "LTBaseViewController.h"
#import <WebKit/WebKit.h>

@class LTWebViewController;
@protocol LTWebViewControllerDelegate <NSObject>

@optional
// 左上边的返回按钮点击
- (void)backBtnClick:(UIButton *)backBtn webView:(WKWebView *)webView ;

//左上边的关闭按钮的点击
- (void)closeBtnClick:(UIButton *)closeBtn webView:(WKWebView *)webView;

// 监听 self.webView.scrollView 的 contentSize 属性改变，从而对底部添加的自定义 View 进行位置调整
- (void)webView:(WKWebView *)webView scrollView:(UIScrollView *)scrollView contentSize:(CGSize)contentSize;

@end


@protocol LTWebViewControllerDataSource <NSObject>

@optional
// 默认需要, 是否需要进度条
- (BOOL)webViewController:(LTWebViewController *)webViewController webViewIsNeedProgressIndicator:(WKWebView *)webView;

// 默认需要自动改变标题
- (BOOL)webViewController:(LTWebViewController *)webViewController webViewIsNeedAutoTitle:(WKWebView *)webView;

@end

@interface LTWebViewController : LTBaseViewController <WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate, LTWebViewControllerDelegate, LTWebViewControllerDataSource>


/** webView */
@property (nonatomic, strong) WKWebView *webView;

/** <#digest#> */
@property (nonatomic, copy) NSString *gotoURL;

/** <#digest#> */
@property (strong, nonatomic) UIButton *backBtn;

/** <#digest#> */
@property (strong, nonatomic) UIButton *closeBtn;

/** <#digest#> */
@property (weak, nonatomic) UIProgressView *progressView;



// 7页面加载完调用, 必须调用super
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation NS_REQUIRES_SUPER;


// 8页面加载失败时调用, 必须调用super
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error;

@end
