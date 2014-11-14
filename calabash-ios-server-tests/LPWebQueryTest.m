#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "LPWebQuery.h"

@interface LPWebQueryTest : XCTestCase <UIWebViewDelegate>

@property (nonatomic,strong) UIWebView *webView;
@property (atomic,strong) XCTestExpectation *webViewLoadedExpectation;

@end

@implementation LPWebQueryTest

- (void)setUp {
  [super setUp];

  self.webViewLoadedExpectation = [self expectationWithDescription:@"Loaded webview"];

  CGRect frame = CGRectMake(10.0, 20.0, 100.0, 200.0);
  UIWebView *_webView = [[UIWebView alloc] initWithFrame:frame];
  _webView.delegate = self;

  NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"webview-scaffold" ofType:@"html"];
  NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];

  htmlString ='<html> \
  <head> \
  <meta charset="utf-8"></meta> \
  <style type="text/css"> \
  .hidden { \
  display: none;\
  }\
  .revealed {\
  background: yellow;\
    text-align: center;\
    text-size: 2em;\
  }\
  </style>\
  <script type="application/javascript">\
  function displaySecretMessage() {\
    secretMessage = document.getElementById("secret-message");\
    secretMessage.setAttribute("class", "revealed");\
  }\
  </script>\
  </head>\
  <body>\
  <p>\
  <a id="show-message-link" href="#" onclick="displaySecretMessage();">\
  Click me to show a secret message.\
  </a>\
  </p>\
  <p>\
  <a id="second-link" href="#">Second Link</a>\
  <a id="third-link" href="#">Third Link</a>\
  </p>\
  <p id="secret-message" class="hidden">\
  You found me!\
  </p>\
  <p>\
  Thanks for coming by!\
    </p>\
    </body>\
    </html>';

  [_webView loadHTMLString:htmlString baseURL:nil];
  self.webView = _webView;

}

- (void)tearDown {
  [super tearDown];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  [self.webViewLoadedExpectation fulfill];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
  NSLog(@"webview errored");
}

- (void)testCenterComputation {
  [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
    if (error) {
      XCTFail(@"Expectation Failed with error: %@", error);
    } else {
      NSArray *result = [LPWebQuery evaluateQuery:@"a#first-link"
                                           ofType:LPWebQueryTypeCSS
                                        inWebView:self.webView
                                 includeInvisible:NO];

      CGPoint actualCenter = CGPointMake(0.0, 0.0);
      CGPoint expectedCenter = CGPointMake(30.0, 25.0);
      XCTAssertEqual(actualCenter.x, expectedCenter.x);
      XCTAssertEqual(actualCenter.y, expectedCenter.y);
    }
  }];
}

- (void)testPerformanceExample {
  // This is an example of a performance test case.
  [self measureBlock:^{
    // Put the code you want to measure the time of here.
  }];
}

@end
