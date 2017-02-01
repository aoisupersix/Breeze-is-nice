//
//  UserStatus.swift
//  Breezeisnice
//
//  Created by 田中葵 on 2017/02/01.
//  Copyright © 2017年 田中葵. All rights reserved.
//

import Foundation

/*
 *  速度計算(シングルトン)
 */
class UserStatus {
    static var sharedManager: UserStatus = {
        return UserStatus()
    }()
    
    private init(){
        
    }
    
    var road: Double = 1.0  //路面状態
    var resist: Double = 0.0036 //自転車の種類
    var dress: Double = 1.0 //服装
    var height: Double = 176 //身長
    var weight: Double = 78.0   //体重
    var bikeWeight: Double = 10.0   //自転車の重量
    var tire: Double = 2096 //タイヤ周長
    var normalVelo: Double = 30.0   //巡航速度
    var inclin: Double = 45.0   //胴傾き
    
    func calcVelocity(wind: Double, temp: Double) -> Double {
        let w = 0.0
        
        let bmi = weight / pow(0.01 * height,2)
        let bodyIndex = sqrt(bmi / 22)
        let heightIndex = height / 170
        let trunkAngle = M_PI * inclin / 180
        
        let faceW = 0.14
        let shoulderW = 0.45
        let shoulderT = 0.12
        let trunkW = 0.4
        let arm2W = 0.16
        let leg2W = 0.24
        
        let faceA = 0.12 * 0.01 * height * heightIndex * faceW
        let shoulderA = heightIndex * shoulderW * heightIndex * shoulderT
        let trunkA = 0.4 * 0.01 * height * heightIndex*trunkW
        let armA = 0.32 * 0.01 * height * heightIndex * arm2W
        let legA = 0.45 * 0.01 * height * heightIndex * leg2W
        let bodyA = faceA + trunkA * sin(trunkAngle) + shoulderA * cos(trunkAngle) + armA * sin(trunkAngle) + legA
        
        let myArea = bodyA * bodyIndex * dress
        let bicArea = tire * 0.001 * w * 0.001
        let area = myArea + bicArea
        
        let velo = 0.2778 * normalVelo
        let totalvelo = normalVelo + wind
        let totalMass = weight + bikeWeight
        let rollResist = road * resist * totalMass * 9.81
        
        let density = 1.29 * 273 / (273 + temp)
        let airResist = 0.5 * density * area * pow(totalvelo,2) / 2
        let slopeAngle = atan(0.01 * 0)
        let slopeResist = sin(slopeAngle) * totalMass * 9.81
        let totalResist = (rollResist + airResist + slopeResist) * 0.04
        
        let sResist = rollResist + airResist + slopeResist + totalResist
        let total = sResist * velo
        
         return  total / sResist
    }
    
    func calcRelative(angle: Double) -> String {
        //相対速度計算
        let angleSpeed = Location.sharedManager.relativeSpeed! / 90   //1度当たりの相対速度
        var speed = ""  //表示する相対速度
        
        if(angle <= 90){
            //向かい風 -> 左横風
            speed = String(format:"-%.2f",fabs(angleSpeed * (90 - angle)))
        }else if(angle <= 180){
            //左横風 -> 追い風
            speed = String(format:"+%.2f",fabs(angleSpeed * (90 - angle)))
        }else if(angle <= 270){
            //追い風 -> 右横風
            speed = String(format:"+%.2f",fabs(angleSpeed * fabs(270 - angle)))
        }else{
            //右横風 -> 向かい風
            speed = String(format:"-%.2f",fabs(angleSpeed * (angle - 270)))
        }
        
        return speed
    }
}
