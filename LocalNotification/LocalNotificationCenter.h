//
//  LocalNotificationCenter.h
//  LocalNotification
//
//  Created by zhangzhenyun on 2018/7/30.
//  Copyright © 2018年 Beijing Youjiu Network. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
#import <UIKit/UIKit.h>

@interface LocalNotificationCenter : NSObject<UNUserNotificationCenterDelegate,UIApplicationDelegate>

/**系统通知的开关是否打开*/
@property (nonatomic, assign) BOOL isGranted;

/**单例*/
+ (instancetype)sharedCenter;
/** ios10 及以上系统注册通知 */
- (void)laterIos10RegisterNoti;
/** ios10 以下系统注册通知 */
- (void)beforerIos10RegisterNoti;

@end
