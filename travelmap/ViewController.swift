//
//  ViewController.swift
//  travelmap
//
//  Created by 齋藤温仁 on 2024/06/09.
//

import UIKit
import MapKit

class ViewController: UIViewController, UISearchBarDelegate {
    
    var serchedLatitude: CLLocationDegrees = 0.0
    var serchedLongitude: CLLocationDegrees = 0.0
    var swiftDataService = SwiftDataService.shared
    var serchedPlace: String = ""
    var searchedPlaceMemo: String = ""
    var model: VacationModel?
    var routeSteps: [CLLocationCoordinate2D] = []
    var testManager:CLLocationManager = CLLocationManager()
    
    private var testSerchBar: UISearchBar!
//    @IBOutlet weak var testSearchBar: UISearchBar!
    var locationMnager: CLLocationManager!
    @IBOutlet weak var testMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupSearchBar()
        testSerchBar.delegate = self
        locationMnager = CLLocationManager()
        locationMnager.delegate = self
        testMapView.delegate = self
        locationMnager!.requestWhenInUseAuthorization()
        self.testMapView.translatesAutoresizingMaskIntoConstraints = false
        self.testMapView.setCenter(testMapView.userLocation.coordinate, animated: true)
        self.testMapView.userTrackingMode = .followWithHeading
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.testMapView.removeOverlays(self.testMapView.overlays)
        self.testMapView.removeAnnotations(self.testMapView.annotations)
        let annotations = self.getAllPoints()
        annotations.forEach {
            annotation in
            testMapView.addAnnotation(annotation)
        }
    }
    
    func setupSearchBar() {
        if let navigationBarFrame = navigationController?.navigationBar.bounds {
            let searchBar: UISearchBar = UISearchBar(frame: navigationBarFrame)
            searchBar.delegate = self
            searchBar.placeholder = "場所を探す"
            searchBar.tintColor = UIColor.gray
            searchBar.keyboardType = UIKeyboardType.default
            navigationItem.titleView = searchBar
            navigationItem.titleView?.frame = searchBar.frame
            self.testSerchBar = searchBar
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //キーボードを閉じる。
        searchBar.resignFirstResponder()
        //検索条件を作成する。
        let request = MKLocalSearch.Request()
        if let text = searchBar.text, !text.isEmpty {
            request.naturalLanguageQuery = searchBar.text
            //検索範囲はマップビューと同じにする。
            request.region = testMapView.region
            //ローカル検索を実行する。
            let localSearch:MKLocalSearch = MKLocalSearch(request: request)
            localSearch.start(completionHandler: { result, error in
                for placemark in (result?.mapItems)! {
                    if error == nil {
                        //検索された場所にピンを刺す。
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = CLLocationCoordinate2DMake(placemark.placemark.coordinate.latitude, placemark.placemark.coordinate.longitude)
                        annotation.title = placemark.placemark.name
                        annotation.subtitle = placemark.placemark.title
                        self.testMapView.addAnnotation(annotation)
                        self.testMapView.setCenter(annotation.coordinate, animated: true)
                        self.serchedPlace = placemark.placemark.name ?? ""
                        self.serchedLatitude = placemark.placemark.coordinate.latitude
                        self.serchedLongitude = placemark.placemark.coordinate.longitude
                        
                        let points = self.getAllPoints()
                        if let lastPoint = points.last {
                            self.fetchRoute(from: lastPoint.coordinate, to: annotation.coordinate)
                        }
                    } else {
                        print(error!)
                    }
                }
            })
        }
    }
    
    func getAllPoints() -> [MKPointAnnotation] {
        var results: [MKPointAnnotation] = []
        swiftDataService.fetchVacation { vacations, error in
            if let error {
                print(error)
            }
            
            if let vacations {
                vacations.enumerated().forEach { index, vacation in
                    let annotation = MKPointAnnotation()
                    let centerCoordinate = CLLocationCoordinate2D(latitude: vacation.latitude, longitude: vacation.longitude)
                    annotation.coordinate = centerCoordinate
                    //TODO: 5.ルート表示をここで行なう
                    if index > 0 {
                        self.fetchRoute(from: results[index - 1].coordinate, to: centerCoordinate)
                    }
                    annotation.title = vacation.vacationName
                    annotation.subtitle = vacation.memo
                    results.append(annotation)
                }
            }
        }
        return results
    }
    
    func addPin(latitude: Double, longitude: Double) {
        let pin = MKPointAnnotation()
        pin.title = "大阪駅"
        pin.subtitle = "大阪駅にピン留めしています"
        pin.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.testMapView.addAnnotation(pin)
    }
    
    @objc func goToAddView() {
        self.performSegue(withIdentifier: "goAddView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goAddView"{
            let addVC = segue.destination as! AddViewController
            addVC.searchedPlace = self.serchedPlace
            addVC.searchedLatitude = self.serchedLatitude
            addVC.searchedLongitude = self.serchedLongitude
            addVC.memo = self.searchedPlaceMemo
            addVC.model = self.model
        }
    }
}

extension ViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    // 許可を求めるためのdelegateメソッド
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            // 許可されてない場合
        case .notDetermined:
            // 許可を求める
            manager.requestWhenInUseAuthorization()
            // 拒否されてる場合
        case .restricted, .denied:
            // 何もしない
            break
            // 許可されている場合
        case .authorizedAlways, .authorizedWhenInUse:
            // 現在地の取得を開始
            manager.startUpdatingLocation()
            break
        default:
            break
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let title = view.annotation?.title {
            self.serchedPlace = title ?? ""
            
            swiftDataService.fetchVacation { vacations, error in
                if let error {
                    print(error)
                }
                
                if let vacations {
                    let specifiedVacation = vacations.filter { vacation in
                        vacation.vacationName == title
                    }
                    self.model = specifiedVacation.first
                }
            }
        }
        
        if let subTitle = view.annotation?.subtitle {
            self.searchedPlaceMemo = subTitle ?? ""
        }
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        let annotations = getAllPoints()
        annotations.forEach { annotation in
            mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.title == "My Location" {
            return nil
        }
        let pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pinView.canShowCallout = true
        
        let leftButton = UIButton()
        leftButton.frame = CGRect(x:0,y:0,width:40,height:40)
        leftButton.setImage(UIImage(systemName: "plus.magnifyingglass"), for: .normal)
        leftButton.addTarget(self, action: #selector(goToAddView), for: .touchUpInside)
        
        pinView.leftCalloutAccessoryView = leftButton
        
        return pinView
    }
    
    //TODO: 1.ルート表示に必要
    func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            //案内線の色
            renderer.strokeColor = UIColor(red: 100/255.0, green: 149/255.0, blue: 237/255.0, alpha: 1.0)
            renderer.lineWidth = 5.0
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    //TODO: 2.ルート表示に必要
    func showRoute(_ route: MKRoute) {
        testMapView.addOverlay(route.polyline)
        testMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        // 経路上のポイントをrouteStepsに追加
        let routePoints = route.polyline.points()
        let routePointCount = route.polyline.pointCount
        routeSteps = []
        for i in 0..<routePointCount {
            let point = routePoints[i]
            let pointCoordinate = point.coordinate
            routeSteps.append(pointCoordinate)
        }
    }
    //TODO: 3.ルート表示に必要
    func fetchRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: from))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: to))
        request.transportType = .automobile // 車での移動
        
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if let route = response?.routes.first {
                strongSelf.showRoute(route)
            }
        }
    }
}

