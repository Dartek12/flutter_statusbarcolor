#import "FlutterStatusbarcolorPlugin.h"

#define ANDROID_COLOR(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:((c)&0xFF)/255.0  alpha:((c>>24)&0xFF)/255.0]

@implementation FlutterStatusbarcolorPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"plugins.fuyumi.com/statusbar"
            binaryMessenger:[registrar messenger]];
  FlutterStatusbarcolorPlugin* instance = [[FlutterStatusbarcolorPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
    
  [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
}

+ (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

static NSInteger statusBarViewTag = 38482458385;

+ (void)orientationChanged:(NSNotification *)notification{
    [self updateStatusBarViewConstraints];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getstatusbarcolor" isEqualToString:call.method]) {
    UIColor *uicolor;
    UIView * statusBar = [FlutterStatusbarcolorPlugin getStatusBarView];
    uicolor = statusBar.backgroundColor;
    if(uicolor == nil) {
       // since it's nil default to transparent
       uicolor = UIColor.clearColor;
    }

    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;
    if (![uicolor getRed:&red green:&green blue:&blue alpha:&alpha]) {
        CGFloat white;
        if ([uicolor getWhite:&white alpha:&alpha]) {
            red = green = blue = white;
        }
    }
    NSNumber *color = @(((int)(red * 255.0) << 16) | ((int)(green * 255.0) << 8) | (int)(blue * 255.0) | ((int)(alpha * 255.0) << 24));
    result(color);
  } else if ([@"setstatusbarcolor" isEqualToString:call.method]) {
    NSNumber *color = call.arguments[@"color"];
    UIView * statusBar = [FlutterStatusbarcolorPlugin getStatusBarView];
    int colors = [color intValue];
    statusBar.backgroundColor = ANDROID_COLOR(colors);
    result(nil);
  } else if ([@"setstatusbarwhiteforeground" isEqualToString:call.method]) {
    NSNumber *usewhiteforeground = call.arguments[@"whiteForeground"];
    if ([usewhiteforeground boolValue]) {
      [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    } else {
        if (@available(iOS 13, *)) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDarkContent animated:YES];
        }else{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        }
    }
    result(nil);
  } else if ([@"getnavigationbarcolor" isEqualToString:call.method]) {
    result(nil);
  } else if ([@"setnavigationbarcolor" isEqualToString:call.method]) {
    result(nil);
  } else if ([@"setnavigationbarwhiteforeground" isEqualToString:call.method]) {
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

+ (UIView*) getStatusBarView {
   if (@available(iOS 13, *)) {
       if([UIApplication sharedApplication].keyWindow != nil &&
           [[UIApplication sharedApplication].keyWindow viewWithTag:statusBarViewTag] != nil) {
           return [[UIApplication sharedApplication].keyWindow viewWithTag:statusBarViewTag];
       }
       else {
           UIApplication* app = [UIApplication sharedApplication];
           UIView* view = app.keyWindow;
           
           UIView* statusBar = [[UIView alloc] init];
           [view addSubview:statusBar];
           statusBar.tag = statusBarViewTag;
           statusBar.translatesAutoresizingMaskIntoConstraints = NO;
           
           [self updateStatusBarViewConstraints];
           return statusBar;
       }
   }
   else {
       return [[UIApplication sharedApplication] valueForKey:@"statusBar"];
   }
}

+ (void) updateStatusBarViewConstraints {
    UIView* statusBar = [self getStatusBarView];
    if(statusBar) {
        if(@available(iOS 13.0, *)) {
            UIApplication* app = [UIApplication sharedApplication];
            CGRect frame = app.keyWindow.windowScene.statusBarManager.statusBarFrame;
            UIView* view = app.keyWindow;
            
            [statusBar removeConstraints:statusBar.constraints];
            
            [statusBar.heightAnchor constraintEqualToConstant:frame.size.height].active = YES;
            [statusBar.widthAnchor constraintEqualToAnchor:view.widthAnchor multiplier:1.0].active = YES;
            [statusBar.topAnchor constraintEqualToAnchor:view.topAnchor].active = YES;
            [statusBar.centerXAnchor constraintEqualToAnchor:view.centerXAnchor].active = YES;
        }
    }
}

@end
