//  ViewController.swift
//  WeatherApp


import UIKit
import CoreLocation //apple library that allows us to tap into GPS
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate{
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "5ac00b4b8084dfde07646645509e2a73"
    

    
    let locationManager = CLLocationManager();
    let weatherDataModel = WeatherDataModel();

    
    //IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Set up the location manager.
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        
        //ask the user for permission to get the current location of the user
        locationManager.requestWhenInUseAuthorization(); //the method that will trigger the authorization popup
        
        locationManager.startUpdatingLocation(); //work in background, looking for the GPS coordinate, will send a message to the viewController
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //getWeatherData method:
    func getWeatherData(url : String, parameters : [String : String]){
        
        //asynchronized code/function, works in the background
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON{
            response in
            if response.result.isSuccess {
                print("Success! We received the correct weather data");
                
                let weatherJSON : JSON = JSON(response.result.value!) //safe to unwrapp because we know the result is valid
                print(weatherJSON)
                self.updateWeatherData(json: weatherJSON);
                
            }
            else{
                print("There is an error, the problem is \(response.result.error)");
                self.cityLabel.text = "Connection Issues";
            }
        }
        
        
    }
    

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    //interpret the JSON values and turn them into usable data
    
    //updateWeatherData method
    func updateWeatherData(json : JSON){
        
        if let tempResult = json["main"]["temp"].double{
            weatherDataModel.temperature = Int(tempResult - 273.5)
            weatherDataModel.city = json["name"].stringValue;
            weatherDataModel.condition = json["weather"][0]["id"].intValue;
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition);
            
            
            updateUIWithWeatherData();
        }
        else{
            cityLabel.text = "Service Unavailable";
        }
        
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    func updateUIWithWeatherData(){
        cityLabel.text = weatherDataModel.city;
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName);
    }
    
    
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //the last value in the CLlocation array will be the most accurate one
        let location = locations[locations.count - 1];
        if location.horizontalAccuracy > 0 {
            
            //if the accuracy is smaller than 0, then its invalid
            locationManager.stopUpdatingLocation(); //stop acquiring location once we found it
            locationManager.delegate = nil; //avoid multiple finding locatoin
            
            let latitude = String(location.coordinate.latitude);
            let longtitude = String(location.coordinate.longitude);
            //create a dictionary, the format comes from the openWeather API
            let params : [String : String] = ["lat" : latitude, "lon" : longtitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params);
        }
    }
    
    
    //Can't Find City Error
    //tells the delegate that it is unable to find the location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error);
        cityLabel.text = "Location Unavailable";
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    func userEnteredANewCityName(city: String) {
        
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params);
    }

    
    //prepares the segue data transfer
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self;
        }
    }
    
    
    
    
}


