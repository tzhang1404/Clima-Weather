//  ChangeCityViewController.swift
//  WeatherApp


import UIKit


protocol ChangeCityDelegate{
    func userEnteredANewCityName(city : String)
}


class ChangeCityViewController: UIViewController {
    
    var delegate : ChangeCityDelegate?

    @IBOutlet weak var changeCityTextField: UITextField!

    
    @IBAction func getWeatherPressed(_ sender: AnyObject) {
        //Get the city name the user entered in the text field
        let cityName = changeCityTextField.text!
            delegate?.userEnteredANewCityName(city: cityName)
        //return to the original page
        self.dismiss(animated: true, completion: nil);
        
    }
    
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
