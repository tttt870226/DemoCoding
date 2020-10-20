//
//  BlueToothCapacity.m
//  CordovaApp
//  参考:https://www.jianshu.com/p/0c31487bb7c5
//  Created by skynj on 2020/10/20.
//
/* 配置info.plist
 <config-file parent="NSBluetoothAlwaysUsageDescription" target="*-Info.plist">
     <string>需要使用蓝牙，请开启蓝牙能力</string>
 </config-file>
 <config-file parent="NSBluetoothPeripheralUsageDescription" target="*-Info.plist">
     <string>需要您的同意, APP才能访问蓝牙</string>
 </config-file>
 */

#import "BlueToothCapacity.h"

@implementation BlueToothCapacity

-(void)initBule{
    CBCentralManager* g_centralManager =  [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.centralManager = g_centralManager;
}

/**
 *  --  初始化成功自动调用
 *  --  必须实现的代理，用来返回创建的centralManager的状态。
 *  --  注意：必须确认当前是CBCentralManagerStatePoweredOn状态才可以调用扫描外设的方法：
 scanForPeripheralsWithServices
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBManagerStateUnknown:
            NSLog(@">>>CBCentralManagerStateUnknown");
            break;
        case CBManagerStateResetting:
            NSLog(@">>>CBCentralManagerStateResetting");
            break;
        case CBManagerStateUnsupported:
            NSLog(@">>>CBCentralManagerStateUnsupported");
            break;
        case CBManagerStateUnauthorized:
            NSLog(@">>>CBCentralManagerStateUnauthorized");
            break;
        case CBManagerStatePoweredOff:
            NSLog(@">>>CBCentralManagerStatePoweredOff");
            break;
        case CBManagerStatePoweredOn:
        {
            NSLog(@">>>CBCentralManagerStatePoweredOn");
            // 开始扫描周围的外设。
            /*
             -- 两个参数为Nil表示默认扫描所有可见蓝牙设备。
             -- 注意：第一个参数是用来扫描有指定服务的外设。然后有些外设的服务是相同的，比如都有FFF5服务，那么都会发现；而有些外设的服务是不可见的，就会扫描不到设备。
             -- 成功扫描到外设后调用didDiscoverPeripheral
             */
            [self.centralManager scanForPeripheralsWithServices:nil options:nil];
        }
            break;
        default:
            break;
    }
}

#pragma mark 发现外设
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"Find device:%@", [peripheral name]);
//    if (![_deviceDic objectForKey:[peripheral name]]) {
//        NSLog(@"Find device:%@", [peripheral name]);
//        if (peripheral!=nil) {
//            if ([peripheral name]!=nil) {
//                if ([[peripheral name] hasPrefix:@"根据设备名过滤"]) {
//                    [_deviceDic setObject:peripheral forKey:[peripheral name]];
//                     // 停止扫描, 看需求决定要不要加
////                    [_centralManager stopScan];
//                    // 将设备信息传到外面的页面(VC), 构成扫描到的设备列表
//                    if ([self.delegate respondsToSelector:@selector(dataWithBluetoothDic:)]) {
//                        [self.delegate dataWithBluetoothDic:_deviceDic];
//                    }
//                }
//            }
//        }
//    }
}

// 连接设备(.h中声明出去的接口, 一般在点击设备列表连接时调用)
- (void)connectDeviceWithPeripheral:(CBPeripheral *)peripheral
{
    [self.centralManager connectPeripheral:peripheral options:nil];
}

#pragma mark 连接外设--成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    //连接成功后停止扫描，节省内存
    [central stopScan];
//    peripheral.delegate = self;
//    self.peripheral = peripheral;
    //4.扫描外设的服务
    /**
     --     外设的服务、特征、描述等方法是CBPeripheralDelegate的内容，所以要先设置代理peripheral.delegate = self
     --     参数表示你关心的服务的UUID，比如我关心的是"FFE0",参数就可以为@[[CBUUID UUIDWithString:@"FFE0"]].那么didDiscoverServices方法回调内容就只有这两个UUID的服务，不会有其他多余的内容，提高效率。nil表示扫描所有服务
     --     成功发现服务，回调didDiscoverServices
     */
    [peripheral discoverServices:@[[CBUUID UUIDWithString:@"你要用的服务UUID"]]];
//    if ([self.delegate respondsToSelector:@selector(didConnectBle)]) {
//       // 已经连接
//        [self.delegate didConnectBle];
//    }
}

#pragma mark 连接外设——失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"%@", error);
}

#pragma mark 取消与外设的连接回调
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"%@", peripheral);
}

#pragma mark 发现服务回调
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    
    //NSLog(@"didDiscoverServices,Error:%@",error);
    CBService * __nullable findService = nil;
    // 遍历服务
    for (CBService *service in peripheral.services)
    {
        //NSLog(@"UUID:%@",service.UUID);
        if ([[service UUID] isEqual:[CBUUID UUIDWithString:@"你要用的服务UUID"]])
        {
            findService = service;
        }
    }
    NSLog(@"Find Service:%@",findService);
    if (findService)
        [peripheral discoverCharacteristics:NULL forService:findService];
}

#pragma mark 发现特征回调
/**
 --  发现特征后，可以根据特征的properties进行：读readValueForCharacteristic、写writeValue、订阅通知setNotifyValue、扫描特征的描述discoverDescriptorsForCharacteristic。
 **/
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"你要用的特征UUID"]]) {
            
            /**
             -- 读取成功回调didUpdateValueForCharacteristic
             */
//            self.characteristic = characteristic;
            // 接收一次(是读一次信息还是数据经常变实时接收视情况而定, 再决定使用哪个)
//            [peripheral readValueForCharacteristic:characteristic];
            // 订阅, 实时接收
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            
            // 发送下行指令(发送一条)
            NSData *data = [@"硬件工程师给我的指令, 发送给蓝牙该指令, 蓝牙会给我返回一条数据" dataUsingEncoding:NSUTF8StringEncoding];
            // 将指令写入蓝牙
//                [self.peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        }

        /**
         -- 当发现characteristic有descriptor,回调didDiscoverDescriptorsForCharacteristic
         */
        [peripheral discoverDescriptorsForCharacteristic:characteristic];
    }
}

#pragma mark - 获取值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    // characteristic.value就是蓝牙给我们的值(我这里是json格式字符串)
//    NSData *jsonData = [characteristic.value dataUsingEncoding:NSUTF8StringEncoding];
//        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    // 将字典传出去就可以使用了
}

#pragma mark - 中心读取外设实时数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (characteristic.isNotifying) {
        [peripheral readValueForCharacteristic:characteristic];
    } else {
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        NSLog(@"%@", characteristic);
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}

// 上文中发现特征之后, 发送下行指令的时候其实就是向蓝牙中写入数据
// 例:
// 发送检查蓝牙命令
- (void)writeCheckBleWithBle
{
//    _style = 1;
//    // 发送下行指令(发送一条)
//    NSData *data = [@"硬件工程师提供给你的指令, 类似于5E16010203...这种很长一串" dataUsingEncoding:NSUTF8StringEncoding];
//    [self.peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
}

#pragma mark 数据写入成功回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"写入成功");
//    if ([self.delegate respondsToSelector:@selector(didWriteSucessWithStyle:)]) {
//        [self.delegate didWriteSucessWithStyle:_style];
//    }
}

- (void)scanDevice
{
    if (_centralManager == nil) {
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
//    [_deviceDic removeAllObjects];
     }
}
#pragma mark 断开连接
- (void)disConnectPeripheral{
    /**
     -- 断开连接后回调didDisconnectPeripheral
     -- 注意断开后如果要重新扫描这个外设，需要重新调用[self.centralManager scanForPeripheralsWithServices:nil options:nil];
     */
//    [self.centralManager cancelPeripheralConnection:self.peripheral];
}
#pragma mark 停止扫描外设
- (void)stopScanPeripheral{
    [self.centralManager stopScan];
}

@end
