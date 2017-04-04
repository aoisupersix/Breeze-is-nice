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
    var getTime: Int?   //取得時間
    var temp: Double?   //気温
    var wind_speed: Double? //風速
    var wind_deg: Double?   //風向き
    var weather_main: String?   //天気状態
    var weather_description: String?    //天気状態の説明
    var rain_value: Double? //降水量
    var sunrise: Int?    //日の出時刻
    var sunset: Int? //日の入り時刻
    
    func isWeatherEnabled() -> Bool {
        if getTime == nil || temp == nil || wind_speed == nil || wind_deg == nil || weather_main == nil || weather_description == nil || rain_value == nil || sunrise == nil || sunset == nil{
            return false
        }else{
            return true
        }
    }
        
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
