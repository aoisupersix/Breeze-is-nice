//
//  ViewController.swift
//  Breezeisnice
//
//  Created by 田中葵 on 2017/01/31.
//  Copyright © 2017年 田中葵. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import SwiftSpinner

class ViewController: UIViewController, CLLocationManagerDelegate, OpenWeatherMapDelegate {
    
    /*
     *  OpenWeatherMap
     */
    var openWeatherMap: OpenWeatherMap?
    
    /*
     *  各種計算
     */
    //let calc: Calc?
    
    //AppDelegate
    let app: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //位置情報
    var locationManager: CLLocationManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //スピナー表示
        //SwiftSpinner.show("位置情報取得中")
        
        if CLLocationManager.locationServicesEnabled() {
            //位置情報
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.startUpdatingLocation()
        
            //向き
            locationManager?.headingFilter = 1   //何度動いたら更新するか
            locationManager?.headingOrientation = .portrait //デバイスのどの向きを上とするか
            locationManager?.startUpdatingHeading()
        }
        
        //OpenWeathermap
        openWeatherMap = OpenWeatherMap(delegate: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if CLLocationManager.locationServicesEnabled() {
            locationManager?.stopUpdatingLocation()
            locationManager?.stopUpdatingHeading()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*
     *  位置情報delegate
     */
    //位置情報の使用の許可
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways, .authorizedWhenInUse:
            break
        }
    }
    //向き変更
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
//        if (self.app.wind_deg != nil){
//            orientation = newHeading.magneticHeading
//            
//            //
//            if(orientation <= app.wind_deg!){
//                //風向きの方が大きいので、風向き-角度だけ回転させる
//                direction = app.wind_deg! - orientation
//            }else{
//                direction = 360 - (orientation - app.wind_deg!)
//            }
//            
//            updateLabel()
//        }
    }
    //位置情報取得
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = manager.location
        {
            Location.sharedManager.latitude = location.coordinate.latitude
            Location.sharedManager.longitude = location.coordinate.longitude
            print("緯度\(Location.sharedManager.latitude)")
            print("経度\(Location.sharedManager.longitude)")
            openWeatherMap?.get(lat: Location.sharedManager.latitude!, lon: Location.sharedManager.longitude!)
            if CLLocationManager.locationServicesEnabled() {
                print("locationManager: stop")
                locationManager?.stopUpdatingLocation()
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
        self.showDialog(title: "エラー", mes: "位置情報を取得できませんでした。再度取得します。")
        locationManager?.requestLocation()
        print("locationManager: start")
        SwiftSpinner.show("位置情報取得中")
    }
    
    /*
     *  OpenWeatherMap
     */
    func openWeather_CompleteSession() {
        SwiftSpinner.hide()
        //速度計算
        Location.sharedManager.relativeSpeed = UserStatus.sharedManager.calcVelocity(wind: Location.sharedManager.wind_speed!, temp: Location.sharedManager.temp!)
        print("RelativeSpeed=\(Location.sharedManager.relativeSpeed)")
    }
    
    func openWeather_ErrorSession(error: Error) {
        
    }
    
    
    /*
     *  汎用ダイアログ
     */
    func showDialog(title: String, mes: String)
    {
        let alert: UIAlertController = UIAlertController(title: title, message: mes, preferredStyle:  UIAlertControllerStyle.alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "了解", style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            print("OK")
        })
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
}

