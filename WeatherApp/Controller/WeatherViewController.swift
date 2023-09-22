//
//  ViewController.swift
//  WeatherApp
//
//  Created by Ashraf Eltantawy on 21/09/2023.
//

import UIKit
import NVActivityIndicatorView
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var cLabel: UILabel!
    @IBOutlet weak var bacgroundView: UIView!
    @IBOutlet weak var tempreatureLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    private let gradientLayer = CAGradientLayer()
    let apiKey = "22e5daac3d549ff97b69ba7ccea6f254"
    var lat = 11.344533
    var lon = 104.33322
    var activityIndicator :NVActivityIndicatorView!
    let locationManager = CLLocationManager()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        bacgroundView.layer.addSublayer(gradientLayer)
        
        let indicatorSize:CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width-indicatorSize)/2, y: (view.frame.height-indicatorSize)/2, width: indicatorSize, height: indicatorSize)
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame,type: .ballBeat,color: .white,padding: 20.0)
        activityIndicator.backgroundColor = UIColor.black
        view.addSubview(activityIndicator)
        
        
        locationManager.requestWhenInUseAuthorization()
        activityIndicator.startAnimating()
        DispatchQueue.global().async {
            if (CLLocationManager.locationServicesEnabled()){
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager.startUpdatingLocation()
                
            }
        }
     
    }
    override func viewWillAppear(_ animated: Bool) {
        setBlueGragientBackground()
    }
    func setBlueGragientBackground(){
        let topColor = UIColor(red: 95.0/255.0, green: 165.0/255.0, blue: 1.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 72.0/255, green: 114.0/255.0, blue: 184.0/255.0, alpha: 1.0).cgColor
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor,bottomColor]
    }
    func setGrayGragientBackground(){
        let topColor = UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 72.0/255, green: 72.0/255, blue: 72.0/255, alpha: 1.0).cgColor
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor,bottomColor]
    }

}

extension ViewController : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        lat = location.coordinate.latitude
        lon = location.coordinate.longitude
        
        let url = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric"
        Api.shared.fetchData(url: url) {[weak self]( weatherResponse:WeatherResponse?, error) in
            guard let self = self else{return}
            self.activityIndicator.stopAnimating()
            if let error = error{
                print(error)
            }else{
                self.locationLabel.text = weatherResponse?.name ?? ""
                self.tempreatureLabel.text = "\(Int(round(weatherResponse?.main?.temp ?? 0.0)))"
                self.cLabel.isHidden = false
                self.conditionLabel.text = weatherResponse?.weather?[0].main ?? ""
                self.conditionImageView.image = UIImage(named: weatherResponse?.weather?[0].icon ?? "")
                let date = Date()
                let dateFormatter =  DateFormatter()
                dateFormatter.dateFormat = "EEEE"
                self.dayLabel.text = dateFormatter.string(from: date)
                let sufix = weatherResponse?.weather?[0].icon?.suffix(1)
                if(sufix=="n"){
                    self.setGrayGragientBackground()
                }else{
                    self.setBlueGragientBackground()
                }
                
            }
        }
        
        self.locationManager.stopUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
