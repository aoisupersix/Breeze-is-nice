//
//  OpenWeatherMap.swift
//  Breezeisnice
//
//  Created by 田中葵 on 2017/02/01.
//  Copyright © 2017年 田中葵. All rights reserved.
//

/*
 *  OpenWeatherMap関連のクラス
 */

import SwiftyJSON
import SwiftSpinner

protocol OpenWeatherMapDelegate {
    func openWeather_CompleteSession()
    func openWeather_ErrorSession(error: Error)
}

class OpenWeatherMap{
    
    var delegate: OpenWeatherMapDelegate
    
    init(delegate: OpenWeatherMapDelegate){
        self.delegate = delegate
    }
    
    func get(lat: Double, lon: Double) {
        let urlString = "http://api.openweathermap.org/data/2.5/weather?units=metric&lat=\(lat)&lon=\(lon)&APPID=\(OpenWeatherMapConst.API_KEY)"
        print("URL:\(urlString)")
        let url = URL(string: urlString)
        let task = URLSession.shared.dataTask(with: url!, completionHandler: {data, response, error in
            if error == nil {
                //エラーなし
                print("OpenWeatherMap: getSecceed")
                self.parse(data: data! as NSData)
                self.delegate.openWeather_CompleteSession()
            } else {
                //エラー
                print("OpenWeatherMap: getError")
                self.delegate.openWeather_ErrorSession(error: error!)
            }
        })
        task.resume()
    }
    
    /*
     * 取得したJSONパース
     */
    func parse(data: NSData){
        let json = JSON(data: data as Data)
        print(json["wind"]["speed"])
        Location.sharedManager.temp = json["main"]["temp"].double
        Location.sharedManager.wind_speed = json["wind"]["speed"].double
        Location.sharedManager.wind_deg = json["wind"]["deg"].double
    }
}