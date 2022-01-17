//
//  UMGameAnalyticsSwift.swift
//  swiftDemo
//
//  Created by wangkai on 2019/8/30.
//  Copyright © 2019 wangkai. All rights reserved.
//

import Foundation

class UMGameAnalyticsSwift: NSObject {

    /** active user sign-in.
     使用sign-In函数后，如果结束该PUID的统计，需要调用sign-Off函数
     @param puid : user's ID
     @param provider : 不能以下划线"_"开头，使用大写字母和数字标识; 如果是上市公司，建议使用股票代码。
     @return void.
     */
    static func profileSignInWithPUID(puid:String){
        MobClickGameAnalytics.profileSignIn(withPUID: puid);
    }
    static func profileSignInWithPUID(puid:String,provider:String){
        MobClickGameAnalytics.profileSignIn(withPUID:puid, provider: provider);
    }
    
    /** active user sign-off.
     停止sign-in PUID的统计
     @return void.
     */
    
    static func profileSignOff(){
        MobClickGameAnalytics.profileSignOff();
    }
    
    ///---------------------------------------------------------------------------------------
    /// @name  set game level
    ///---------------------------------------------------------------------------------------
    
    /** 设置玩家的等级.
     */
    
    /** 设置玩家等级属性.
     @param level 玩家等级
     @return void
     */
    
    static func setUserLevelId(level:Int){
        MobClickGameAnalytics.setUserLevelId(Int32(level));
    }
    
    ///---------------------------------------------------------------------------------------
    /// @name  关卡统计
    ///---------------------------------------------------------------------------------------
    
    /** 记录玩家进入关卡，通过关卡及失败的情况.
     */
    
    
    /** 进入关卡.
     @param level 关卡
     @return void
     */
    
    static func startLevel(level:String){
        MobClickGameAnalytics.startLevel(level);
    }
    
    /** 通过关卡.
     @param level 关卡,如果level == nil 则为当前关卡
     @return void
     */
    
    static func finishLevel(level:String){
        MobClickGameAnalytics.finishLevel(level);
    }
    
    /** 未通过关卡.
     @param level 关卡,如果level == nil 则为当前关卡
     @return void
     */
    
    static func failLevel(level:String){
        MobClickGameAnalytics.failLevel(level);
    }
    
    
    ///---------------------------------------------------------------------------------------
    /// @name  支付统计
    ///---------------------------------------------------------------------------------------
    
    /** 记录玩家交易兑换货币的情况
     @param currencyAmount 现金或等价物总额
     @param currencyType 为ISO4217定义的3位字母代码，如CNY,USD等（如使用其它自定义等价物作为现金，可使￼用ISO4217中未定义的3位字母组合传入货币类型）￼
     @param virtualAmount 虚拟币数量
     @param channel 支付渠道
     @param orderId 交易订单ID
     @return void
     */
    
    static func exchange(orderId:String,currencyAmount:Double,currencyType:String,virtualCurrencyAmount:Double,paychannel:Int){
        MobClickGameAnalytics.exchange(orderId, currencyAmount: currencyAmount, currencyType: currencyType, virtualCurrencyAmount: virtualCurrencyAmount, paychannel: Int32(paychannel))
    }
    
    /** 玩家支付货币兑换虚拟币.
     @param cash 真实货币数量
     @param source 支付渠道
     @param coin 虚拟币数量
     @return void
     */
    
    static func pay(cash:Double,source:Int,coin:Double){
        MobClickGameAnalytics.pay(cash, source: Int32(source), coin: coin)
    }
    
    /** 玩家支付货币购买道具.
     @param cash 真实货币数量
     @param source 支付渠道
     @param item 道具名称
     @param amount 道具数量
     @param price 道具单价
     @return void
     */
    
    static func pay(cash:Double,source:Int,item:String,amount:Int,price:Double){
        MobClickGameAnalytics.pay(cash, source: Int32(source), item: item, amount: Int32(amount), price: price)
    }
    

    
    ///---------------------------------------------------------------------------------------
    /// @name  虚拟币购买统计
    ///---------------------------------------------------------------------------------------
    
    /** 记录玩家使用虚拟币的消费情况
     */
    
    
    /** 玩家使用虚拟币购买道具
     @param item 道具名称
     @param amount 道具数量
     @param price 道具单价
     @return void
     */
    
    static func buy(item:String,amount:Int,price:Double){
        MobClickGameAnalytics.buy(item, amount: Int32(amount), price: price)
    }
    

    
    
    ///---------------------------------------------------------------------------------------
    /// @name  道具消耗统计
    ///---------------------------------------------------------------------------------------
    
    /** 记录玩家道具消费情况
     */
    
    
    /** 玩家使用虚拟币购买道具
     @param item 道具名称
     @param amount 道具数量
     @param price 道具单价
     @return void
     */
    
    static func use(item:String,amount:Int,price:Double){
        MobClickGameAnalytics.use(item, amount: Int32(amount), price: price)
    }
    
    

    
    
    ///---------------------------------------------------------------------------------------
    /// @name  虚拟币及道具奖励统计
    ///---------------------------------------------------------------------------------------
    
    /** 记录玩家获赠虚拟币及道具的情况
     */
    
    
    /** 玩家获虚拟币奖励
     @param coin 虚拟币数量
     @param source 奖励方式
     @return void
     */
    
    static func bonus(coin:Double,source:Int){
        MobClickGameAnalytics.bonus(coin, source: Int32(source))
    }
    
    /** 玩家获道具奖励
     @param item 道具名称
     @param amount 道具数量
     @param price 道具单价
     @param source 奖励方式
     @return void
     */
    
    static func bonus(item:String,amount:Int,price:Double,source:Int){
        MobClickGameAnalytics.bonus(item, amount: Int32(amount), price: price, source: Int32(source))
    }
    
    
    
}
