//
//  Location.swift
//  Breezeisnice
//
//  Created by 田中葵 on 2017/02/01.
//  Copyright © 2017年 田中葵. All rights reserved.
//

/*
 *  地点情報(シングルトン)
 */

class Location{
    
    static var sharedManager: Location = {
        return Location()
    }()
    
    private init() {
        
    }
    /*
     *  緯度経度情報
     */
    var latitude: Double?
    var longitude: Double?
    
    func isLocationEnabled() -> Bool {
        if latitude == nil{
            return false
        }else{
            return true
        }
    }
    
    /*
     * 天気情報
     */
    var temp: Double?
    var wind_speed: Double?
    var wind_deg: Double?
    
    func isWeatherEnabled() -> Bool {
        if temp == nil{
            return false
        }else{
            return true
        }
    }
    
    /*
     * 相対速度
     */
    var relativeSpeed: Double?
    
    /*
     *  風向きを16方位で返す
     */
    func getWindDegString() -> String{
        var wind = ""
        if isWeatherEnabled() {
            if(wind_deg! < 11.125 || wind_deg! > 348.875){
                wind = "北"
            }else if(wind_deg! < 33.625){
                wind = "北北東"
            }else if(wind_deg! < 56.125){
                wind = "北東"
            }else if(wind_deg! < 78.625){
                wind = "東北東"
            }else if(wind_deg! < 101.125){
                wind = "東"
            }else if(wind_deg! < 123.625){
                wind = "東南東"
            }else if(wind_deg! < 146.125){
                wind = "南東"
            }else if(wind_deg! < 168.625){
                wind = "南南東"
            }else if(wind_deg! < 191.125){
                wind = "南"
            }else if(wind_deg! < 213.625){
                wind = "南南西"
            }else if(wind_deg! < 236.125){
                wind = "南西"
            }else if(wind_deg! < 258.625){
                wind = "西南西"
            }else if(wind_deg! < 281.125){
                wind = "西"
            }else if(wind_deg! < 303.625){
                wind = "西北西"
            }else if(wind_deg! < 326.125){
                wind = "北西"
            }else{
                wind = "北北西"
            }
        }
        return wind
    }
}
