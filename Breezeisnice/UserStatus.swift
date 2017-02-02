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
    
    /*
     *  動力計算
     */
    func calcPower(wind: Double, temp: Double, speed: Double) -> Double {
        let w = 1.0
        
        let BMI = weight / pow(0.01 * height,2)
        let bodyIndex = sqrt(BMI/22)
        let heightIndex = height/170
        let trunkAngle = M_PI * inclin/180
        
        let faceW = 0.14
        let shoulderW = 0.45
        let shoulderT = 0.12
        let trunkW = 0.4
        let arm2W = 0.16
        let leg2W = 0.24
        
        let faceA = 0.12 * 0.01 * height * heightIndex * faceW
        let shoulderA = heightIndex * shoulderW * heightIndex * shoulderT
        let trunkA = 0.4 * 0.01 * height * heightIndex * trunkW
        let armA = 0.32 * 0.01 * height * heightIndex * arm2W
        let legA = 0.45 * 0.01 * height * heightIndex * leg2W
        let bodyA = 1 * faceA + trunkA * sin(trunkAngle) + shoulderA * cos(trunkAngle) + armA * sin(trunkAngle) + 1 * legA
        let myArea = bodyA * bodyIndex * dress
        let bicArea = tire * 0.001 * w * 0.001
        let area = 1 * myArea + 1 * bicArea
        let velo = 0.2778 * speed
        let totalvelo = 1 * velo + 1 * wind
        let totalMass = 1 * weight + 1 * bikeWeight
        let rollResist = road * resist * totalMass * 9.81
        let Cd = 0.5
        let density = 1.29 * 273/(273 + 1 * temp)
        let AirResist = Cd * density * area * pow(totalvelo,2)/2
        let slopeAngle = 0.0
        let slopeResist = sin(slopeAngle) * totalMass * 9.81
        
        let totalResist = 1*rollResist + 1*AirResist + 1*slopeResist;
        
        let driveLossP = 0.04 * totalResist * velo
        let rollResistP = rollResist * velo
        let airResistP = AirResist * velo
        let slopeResistP = slopeResist * velo
        
        return 1*rollResistP + 1*airResistP + 1*slopeResistP + 1*driveLossP
    }
    
    func calcRelative(wind: Double, temp: Double,angle: Double) -> String {
        //真向かい風の際の速度減少を求める
        let normalP = calcPower(wind: 0, temp: temp, speed: self.normalVelo)    //無風時の動力
        
        //動力が大体同じになるまでループ
        var speed = normalVelo
        var power = calcPower(wind: wind, temp: temp, speed: speed)
        var beforepower = 0.0
        repeat{
            beforepower = power
            speed -= 0.2
            power = calcPower(wind: wind, temp: temp, speed: speed)
            
        }while(fabs(power - normalP) <= fabs(beforepower - normalP))
        print("windSpeed:\(speed)")
        
        let facingSpeed = self.normalVelo - speed   //向かい風時の相対速度
        let chaseSpeed = facingSpeed / 2    //追い風時の相対速度。向かい風の半分とする
        
        //相対速度計算
        let facingAngleSpeed = facingSpeed / 90   //1度当たりの相対速度(向かい)
        let chaseAngleSpeed = chaseSpeed / 90   //1度当たりの相対速度(追い)
        var relativeSpeed = ""  //表示する相対速度
        
        if(angle <= 90){
            //向かい風 -> 左横風
            relativeSpeed = String(format:"-%.2f",fabs(facingAngleSpeed * (90 - angle)))
        }else if(angle <= 180){
            //左横風 -> 追い風
            relativeSpeed = String(format:"+%.2f",fabs(chaseAngleSpeed * (90 - angle)))
        }else if(angle <= 270){
            //追い風 -> 右横風
            relativeSpeed = String(format:"+%.2f",fabs(chaseAngleSpeed * fabs(270 - angle)))
        }else{
            //右横風 -> 向かい風
            relativeSpeed = String(format:"-%.2f",fabs(facingAngleSpeed * (angle - 270)))
        }
        
        return relativeSpeed
    }
}
