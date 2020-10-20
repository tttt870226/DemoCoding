//
//  BlueToothCapacity.h
//  CordovaApp
//
//  Created by skynj on 2020/10/20.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
NS_ASSUME_NONNULL_BEGIN


@interface BlueToothCapacity : NSObject<CBCentralManagerDelegate>


@property(nonatomic,retain)CBCentralManager* centralManager;
-(void)initBule;
@end

NS_ASSUME_NONNULL_END
