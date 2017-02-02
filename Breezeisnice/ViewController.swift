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
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, OpenWeatherMapDelegate {
    
    @IBOutlet var MeterImageView: UIImageView!
    @IBOutlet var BgMap: MKMapView!
    @IBOutlet var WindSpeedLabel: UILabel!
    @IBOutlet var RelativeSpeedLabel: UILabel!
    @IBOutlet var WindDegLabel: UILabel!
    @IBOutlet var TempLabel: UILabel!
    @IBAction func refresh_Click(_ sender: Any) {
        //スピナー表示
        SwiftSpinner.show(progress: 0,title:"位置情報取得中")
        progress = 0.0
        isSpinnerEnabled = true

        if CLLocationManager.locationServicesEnabled() {
            print("Refresh")
            locationManager?.requestLocation()
        }
    }
    
    /*
     *  スピナーの進歩状況
     */
    var progress: Double = 0.0
    var isSpinnerEnabled = false
    
    /*
     * 角度関連
     */
    var angle: Double = 0   //メータの回転角度
    var orientation: Double = 0  //端末が向いている方向
    var direction: Double = 0   //端末が向いている方向から風向き
    
    /*
     *  OpenWeatherMap
     */
    var openWeatherMap: OpenWeatherMap?
    
    //位置情報
    var locationManager: CLLocationManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //スピナー表示
        SwiftSpinner.show(progress: 0,title: "位置情報取得中")
        progress = 0.0
        isSpinnerEnabled = true
        
        
        if CLLocationManager.locationServicesEnabled() {
            //位置情報
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.distanceFilter = 1000
            locationManager?.requestLocation()
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
    
    override func viewWillAppear(_ animated: Bool) {
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.updateTimer(_:)), userInfo: nil, repeats: true)    }
    
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
        orientation = newHeading.magneticHeading
        updateAngle()
        updateLabels()
    }
    //位置情報取得
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = manager.location
        {
            SwiftSpinner.show(progress: 1,title: "位置情報取得中")
            isSpinnerEnabled = false;
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

        DispatchQueue.main.async {
            SwiftSpinner.hide()
            //速度計算
            Location.sharedManager.relativeSpeed = UserStatus.sharedManager.calcVelocity(wind: Location.sharedManager.wind_speed!, temp: Location.sharedManager.temp!)
            print("wind_speed:\(Location.sharedManager.wind_speed!),RelativeSpeed=\(Location.sharedManager.relativeSpeed)")
            self.mapPosition(latD: 10000,lonD: 10000,anim: true)
            self.updateAngle()
            self.updateLabels()
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager?.startUpdatingHeading()
            }
        }
 
    }
    
    func openWeather_ErrorSession(error: Error) {
        //TODO
        print(error)
    }
    
    /*
     *  タイマーアップデート
     */
    func updateTimer(_ sender: AnyObject) {
        if(Location.sharedManager.wind_deg != nil)
        {
            rotateMeter(direction)
        }
        if isSpinnerEnabled {
            let rand: Double = Double(arc4random_uniform(10)) / 1000
            progress += 0.005 + rand
            SwiftSpinner.show(progress: progress, title: "位置情報取得中")
        }
    }
    
    /*
     *  回転
     */
    func rotateMeter(_ angle: Double) {
        let angleRad: CGFloat = CGFloat(((angle) * M_PI) / 180)
        UIView.animate(withDuration: 0.1,
                       animations: { () -> Void in
                        // 回転用のアフィン行列を生成.
                        self.MeterImageView.transform = CGAffineTransform(rotationAngle: angleRad)
        },
                       completion: { (Bool) -> Void in
                        self.angle = angle
        })
    }
    
    /*
     *  ラベル更新
     */
    func updateLabels() {
        if (Location.sharedManager.isWeatherEnabled() && Location.sharedManager.isLocationEnabled()){
            WindSpeedLabel.text = "風速: \(Location.sharedManager.wind_speed!) m/s"
            RelativeSpeedLabel.text = "速度: \(UserStatus.sharedManager.calcRelative(angle: direction))km/h"
            WindDegLabel.text = "風向き: \(Location.sharedManager.getWindDegString())"
            TempLabel.text = String(format: "%.1f℃", Location.sharedManager.temp!)
            print("wind_deg:\(Location.sharedManager.wind_deg!)")
        }
    }
    
    /*
     *  回転角度更新
     */
    func updateAngle(){
        if (Location.sharedManager.isWeatherEnabled()){
            if(orientation <= Location.sharedManager.wind_deg!){
                //風向きの方が大きいので、風向き-角度だけ回転させる
                direction = Location.sharedManager.wind_deg! - orientation
            }else{
                direction = 360 - (orientation - Location.sharedManager.wind_deg!)
            }
        }
    }
    
    /*
     *  地図の位置更新
     */
    func mapPosition(latD: Int, lonD: Int, anim: Bool){
        //地図
        BgMap.centerCoordinate = CLLocationCoordinate2DMake(Location.sharedManager.latitude!, Location.sharedManager.longitude!)
        // 縮尺
        let latDist : CLLocationDistance = CLLocationDistance(latD)
        let lonDist : CLLocationDistance = CLLocationDistance(lonD)
        
        // 表示領域を作成
        let region: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(BgMap.centerCoordinate, latDist, lonDist);
        
        BgMap.setRegion(region, animated: anim)
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

