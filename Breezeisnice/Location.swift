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
}
