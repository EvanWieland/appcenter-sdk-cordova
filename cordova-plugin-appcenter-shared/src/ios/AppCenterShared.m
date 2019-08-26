// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <Cordova/NSDictionary+CordovaPreferences.h>
#import "AppCenterShared.h"

@implementation AppCenterShared

static NSString *appSecret;
static NSString *logUrl;
static MSWrapperSdk * wrapperSdk;

+ (void) setAppSecret: (NSString *)secret
{
    appSecret = secret;
    [MSAppCenter configureWithAppSecret:secret];
}

+ (void) setUserId: (NSString *)userId
{
    [MSAppCenter setUserId:userId];
}

+ (NSString *) getAppSecretWithSettings: (NSDictionary*) settings
{
    if (appSecret == nil) {
        appSecret = [settings cordovaSettingForKey:@"APP_SECRET"];
        // If the AppSecret is not set, we will pass nil to MSAppCenter which will error out, as expected
    }

    return appSecret;
}

+ (void) configureWithSettings: (NSDictionary* ) settings
{
    if ([MSAppCenter isConfigured]) {
        return;
    }

    MSWrapperSdk* wrapperSdk =
    [[MSWrapperSdk alloc]
     initWithWrapperSdkVersion:@"0.4.0"
     wrapperSdkName:@"appcenter.cordova"
     wrapperRuntimeVersion:nil
     liveUpdateReleaseLabel:nil
     liveUpdateDeploymentKey:nil
     liveUpdatePackageHash:nil];

    [self setWrapperSdk:wrapperSdk];
    [MSAppCenter configureWithAppSecret:[AppCenterShared getAppSecretWithSettings: settings]];


    CGFloat logLevel = [settings cordovaFloatSettingForKey:@"LOG_LEVEL" defaultValue: CGFLOAT_MIN];
    if (logLevel > 1 && logLevel < 8) {
        [MSAppCenter setLogLevel: floor(logLevel)];
        MSLogError([MSAppCenter logTag], @"We log %d", floor(logLevel));
    } else if (logLevel != CGFLOAT_MIN) {
        MSLogError([MSAppCenter logTag], @"The provided value of the log level is invalid. Log level should be between 2 and 8.");
    }

    logUrl = [settings cordovaSettingForKey:@"LOG_URL"];
    if (logUrl != nil) {
        [MSAppCenter setLogUrl:logUrl];
    }
}

+ (MSWrapperSdk *) getWrapperSdk
{
    return wrapperSdk;
}

+ (void) setWrapperSdk:(MSWrapperSdk *)sdk
{
    wrapperSdk = sdk;
    [MSAppCenter setWrapperSdk:sdk];
}

@end
