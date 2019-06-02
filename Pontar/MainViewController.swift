//
//  MainViewController.swift
//  Pontar
//
//  Created by Jack Moon on 2019/06/01.
//  Copyright © 2019 Jack Moon. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

// Main ViewPanel
class MainViewController: UIViewController, CLLocationManagerDelegate, MyPageDelegate
{
    
    // API
    let API_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "97f186690914a233e90d0d6435f75810"
    
    // References
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    
    // Set instances
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        // Adding related properties in plist is necessary
        locationManager.requestWhenInUseAuthorization()
        // Get the GPS data
        locationManager.startUpdatingLocation()
    }
    
    //MARK: Location Manager Delegate Related
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        // Get the most accurate location
        let currentLocation = locations[locations.count - 1]
        
        if currentLocation.horizontalAccuracy > 0
        {
            locationManager.stopUpdatingLocation()
            
            let latitude = String(currentLocation.coordinate.latitude)
            let longitude = String(currentLocation.coordinate.longitude)
            
            print("longitude = \(longitude), latitude = \(latitude)")
            
            // Make a parameter for API calling
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeather(url: API_URL, parameters: params)
        }
    }
    
    // This will be called when it failed to get GPS data
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print(error)
        
        locationLabel.text = "GPS Not Available"
    }
    
    //MARK: MyPage Related
    func performCustomSetting(cityName: String) {
        print(cityName)
        
        let params : [String : String] = ["q" : cityName, "appid" : APP_ID]
        
        getWeather(url: API_URL, parameters: params)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMyPage"
        {
            let targetView = segue.destination as! MyPageViewController
            
            targetView.delegate = self
        }
    }
    
    //MARK: Network Related
    func getWeather(url: String, parameters: [String : String])
    {
        // Create and send HTTP request and get data in the form of JSON
        Alamofire.request(url, method : HTTPMethod.get, parameters : parameters).responseJSON
        {
            response in
            if response.result.isSuccess
            {
                print("HTTP request sent successfully")
                
                let resultJSON = JSON(response.result.value!)
                self.parseWeatherData(jsonData: resultJSON)
            }
            else
            {
                print("Error : \(String(describing: response.result.error))")
                self.locationLabel.text = "Connection Failed"
            }
        }
    }
    
    //MARK: UI
    func updateWeather()
    {
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        locationLabel.text = weatherDataModel.location
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIcon)
    }
    
    //MARK: JSON Parsing
    func parseWeatherData(jsonData : JSON)
    {
        let temp = jsonData["main"]["temp"].doubleValue
        
        weatherDataModel.temperature = Int(temp - 273.14)
        weatherDataModel.location = jsonData["name"].stringValue
        weatherDataModel.condition = jsonData["weather"][0]["id"].intValue
        weatherDataModel.weatherIcon = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        
        updateWeather()
    }
    
    //MARK: Buttons Clicked
    @IBAction func MyPageOnClick(_ sender: UIButton)
    {
        performSegue(withIdentifier: "toMyPage", sender: self)
    }
}
