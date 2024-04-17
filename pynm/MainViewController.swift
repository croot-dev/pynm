//
//  ViewController.swift
//  pynm
//
//  Created by 최근호 on 2018. 6. 23..
//  Copyright © 2018년 최근호. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NMapViewDelegate, NMapPOIdataOverlayDelegate, NMapLocationManagerDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let count = self.appDelegate.nearDatas.count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.appDelegate.nearDatas[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell") as! DetailCell
        
        cell.name.text = row.name
        cell.star.text = String(format: "%.1f",row.star!)
        if row.distance < 0 {
            cell.distance.text = "\(String(round(row.distance*1000)))m"
        } else {
            cell.distance.text = "\(String(row.distance))km"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.curData = self.appDelegate.nearDatas[indexPath.row]
        self.curDataIndex = indexPath.row
        
        if let curData = self.curData {
            self.popoverView.showPopover(data: curData)
            //self.searchView.hideSearchFilterView()
            self.levelStepper.value = 11
            self.mapView!.setMapCenter(curData.coord!, atLevel: Int32(self.levelStepper.value))
            self.detailView.selectRow(row: curData)
            self.detailView.showDetailView()
        }
    }
    
    var mapView: NMapView?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var curData: StoreData?
    var curDataIndex: Int?
    
    @IBOutlet var detailView: DetailView!
    @IBOutlet var popoverView: PopoverView!
    @IBOutlet var searchView: SearchView!
    @IBOutlet var detailList: UITableView!
    @IBOutlet weak var levelStepper: UIStepper!
    
    func dataSorting() {
        self.appDelegate.datas.sort(by: { $0.distance < $1.distance })
    }
    
    func setDatasNearMe() {
        var list: [StoreData] = []
        
        self.dataSorting()
        for data in self.appDelegate.datas {
            //print(data.distance)
            //if data.distance <= Double(self.filterDistance.value) {
                list.append(data)
            //}
        }
        
        self.appDelegate.nearDatas = list
        self.detailList.reloadData()
    }
    
    func calcDistance(lat: Double, lng: Double) -> Double {
        
        // 위도,경도를 라디안으로 변환
        let rlat1 = self.appDelegate.myLocation.latitude * Double.pi / 180
        let rlng1 = self.appDelegate.myLocation.longitude * Double.pi / 180
        let rlat2 = lat * Double.pi / 180
        let rlng2 = lng * Double.pi / 180
        
        // 2점의 중심각(라디안) 요청
        let a =
            sin(rlat1) * sin(rlat2) +
                cos(rlat1) * cos(rlat2) *
                cos(rlng1 - rlng2)
        let rr = acos(a)
        
        // 지구 적도 반경(m단위)
        let earth_radius = 6378140.0
        
        // 두 점 사이의 거리 (m단위)
        let distance = earth_radius * rr
        
        if distance < 1000 {
            return round(distance) / 1000
        } else {
            return round(distance / 100) / 10
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = NMapView(frame: self.view.bounds)
        
        if let mapView = mapView {
            
            // set the delegate for map view
            mapView.delegate = self
            
            // set the application api key for Open MapViewer Library
            mapView.setClientId("6OnRsPUjggXqQ8aIk7Nh")
            
            mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            view.addSubview(mapView)
            view.sendSubview(toBack: mapView)
            
            // Zoom 용 UIStepper 셋팅.
            initLevelStepper(mapView.minZoomLevel(), maxValue:mapView.maxZoomLevel(), initialValue:11)
            view.bringSubview(toFront: levelStepper)
            
            mapView.setBuiltInAppControl(false)
            
            self.detailList.delegate = self
            self.detailList.dataSource = self
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /* DB 가져오는 부분 */
        db.collection("restaurant").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let rawData:Dictionary<String, Any> = document.data() as Dictionary
                    var data = StoreData()
                    
                    for key in rawData.keys {
                        switch key {
                        case "name":
                            data.name = rawData["name"] as! String
                        case "address1":
                            data.address1 = rawData["address1"] as! String
                        case "address2":
                            data.address2 = rawData["address2"] as! String
                        case "address3":
                            data.address3 = rawData["address3"] as! String
                        case "address_jibun":
                            data.address_jibun = rawData["address_jibun"] as! String
                        case "menu":
                            data.menu = (rawData["menu"] as? Bool == true)
                        case "image":
                            data.image = rawData["image"] as! [String?]
                        case "parking":
                            data.menu = (rawData["parking"] as? Bool == true)
                        case "opentime":
                            data.opentime = rawData["opentime"] as? String
                        case "closetime":
                            data.closetime = rawData["closetime"] as? String
                        case "price":
                            data.price = rawData["price"] as? Int
                        case "star":
                            data.star = rawData["star"] as? Float
                        case "tel":
                            data.tel = rawData["tel"] as! String
                        case "coord":
                            if let coord = rawData["coord"] as? NSObject {
                                let lat: Double = coord.value(forKey: "latitude") as! Double
                                let lng: Double = coord.value(forKey: "longitude") as! Double
                                
                                data.coord = NGeoPoint(longitude: lng, latitude: lat)
                                data.distance = self.calcDistance(lat: lat as Double, lng: lng as Double)
                            }
                        case "comment":
                            data.comment = rawData["comment"] as? String
                        default:
                            break
                        }
                    }
                    
                    self.mapView?.findPlacemark(atLocation: data.coord!)
                    self.appDelegate.datas.append(data)
                }
                
                self.setDatasNearMe()
                self.drawMarker(false)
            }
            self.detailView.selectRow(row: self.appDelegate.datas[0])
            self.detailView.hideDetailView()
        }
        
        self.enableLocationUpdate()
    }
    
    func drawMarker(_ showAll: Bool) {
        if let mapOverlayManager = self.mapView?.mapOverlayManager {
            
            mapView?.mapOverlayManager.clearOverlays()
            
            // create POI data overlay
            if let poiDataOverlay = mapOverlayManager.newPOIdataOverlay() {
                
                poiDataOverlay.initPOIdata(Int32(self.appDelegate.nearDatas.count))
                for (index,data) in self.appDelegate.nearDatas.enumerated() {
                    if let coord = data.coord {
                        poiDataOverlay.addPOIitem(atLocation: coord, title: data.name, type: UserPOIflagTypeDefault, iconIndex: Int32(index), with: nil)
                    }
                }
                poiDataOverlay.endPOIdata()
                
                // show all POI data
                if showAll {
                    poiDataOverlay.showAllPOIdata()
                }
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        mapView?.didReceiveMemoryWarning()
    }
    
    // MARK: - My Location
    func enableLocationUpdate() {
        
        if let lm = NMapLocationManager.getSharedInstance() {
            
            if lm.locationServiceEnabled() == false {
                locationManager(lm, didFailWithError: .denied)
                return
            }
            
            if lm.isUpdateLocationStarted() == false {
                // set delegate
                lm.setDelegate(self)
                // start updating location
                lm.startContinuousLocationInfo()
            }
        }
    }
    
    // MARK: - NMapLocationManagerDelegate Methods
    open func locationManager(_ locationManager: NMapLocationManager!, didUpdateTo location: CLLocation!) {
        
        let coordinate = location.coordinate
        let coord = NGeoPoint(longitude: coordinate.longitude, latitude: coordinate.latitude)
        let locationAccuracy = Float(location.horizontalAccuracy)
        
        mapView?.mapOverlayManager.setMyLocation(coord, locationAccuracy: locationAccuracy)
        if self.appDelegate.isAutoCenter == true {
            self.levelStepper.value = 11
            mapView?.setMapCenter(coord, atLevel: Int32(self.levelStepper.value))
        }
        
        if self.appDelegate.isSearch == false {
            for var data in self.appDelegate.datas {
                data.distance = self.calcDistance(lat: coord.latitude, lng: coord.longitude)
            }
            
            self.setDatasNearMe()
            self.appDelegate.myLocation = coord
        }
    }
    
    open func locationManager(_ locationManager: NMapLocationManager!, didFailWithError errorType: NMapLocationManagerErrorType) {
        
        var message: String = "근처 냉면집을 찾기 위한 위치정보 사용에 동의합니다."
        
        switch errorType {
        case .unknown: fallthrough
        case .canceled: fallthrough
        case .timeout:
            message = "일시적으로 내위치를 확인 할 수 없습니다."
        case .denied:
            message = "위치 정보를 확인 할 수 없습니다.\n사용자의 위치 정보를 확인하도록 허용하시려면 위치서비스를 켜십시오."
        case .unavailableArea:
            message = "현재 위치는 지도내에 표시할 수 없습니다."
        case .heading:
            message = "나침반 정보를 확인 할 수 없습니다."
        }
        
        if self.appDelegate.datas.count > 0 {
            self.setDatasNearMe()
        }
        
        if (!message.isEmpty) {
            let alert = UIAlertController(title:"알림", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:"OK", style:.default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
        /*
         if let mapView = mapView, mapView.isAutoRotateEnabled {
         mapView.setAutoRotateEnabled(false, animate: true)
         }
         */
    }
    
    @IBOutlet var setMeCenter: UIButton!
    // MARK: - NMapViewDelegate
    open func onMapView(_ mapView: NMapView!, initHandler error: NMapError!) {
        if (error == nil) { // success
            // set map center and level
            self.levelStepper.value = 11
            mapView.setMapCenter(self.appDelegate.myLocation, atLevel: Int32(self.levelStepper.value))
            self.setMeCenter.setBackgroundImage(#imageLiteral(resourceName: "v4_btn_navi_location_selected"), for: .normal)
            
            // set for retina display
            mapView.setMapEnlarged(true, mapHD: true)
            // set map mode : vector/satelite/hybrid
            mapView.mapViewMode = .vector
        } else { // fail
            print("onMapView:initHandler: \(error.description)")
        }
    }
    var isFirstTouch = false
    open func onMapView(_ mapView: NMapView!, touchesBegan touches: Set<AnyHashable>!, with event: UIEvent!) {
        self.isFirstTouch = true
    }
    open func onMapView(_ mapView: NMapView!, touchesMoved touches: Set<AnyHashable>!, with event: UIEvent!) {
        if self.isFirstTouch == true {
            self.detailView.hideDetailView()
            self.popoverView.hidePopover()
            //self.searchView.hideSearchFilterView()
            self.isFirstTouch = false
            self.appDelegate.isAutoCenter = false
            self.setMeCenter.setBackgroundImage(#imageLiteral(resourceName: "v4_btn_navi_location_normal"), for: .normal)
        }
    }
    func onMapView(_ mapView: NMapView!, didChangeMapCenter location: NGeoPoint) {
        //self.searchView.hideSearchFilterView()
        self.setMeCenter.setBackgroundImage(#imageLiteral(resourceName: "v4_btn_navi_location_normal"), for: .normal)
    }
    open func onMapView(_ mapView: NMapView!, willChangeMapLevel toLevel: Int32) {
        self.popoverView.hidePopover()
    }
    
    
    // MARK: - NMapPOIdataOverlayDelegate
    open func onMapOverlay(_ poiDataOverlay: NMapPOIdataOverlay!, imageForOverlayItem poiItem: NMapPOIitem!, selected: Bool) -> UIImage! {
        return NMapViewResources.imageWithType(poiItem.poiFlagType, selected: selected)
    }
    open func onMapOverlay(_ poiDataOverlay: NMapPOIdataOverlay!, anchorPointWithType poiFlagType: NMapPOIflagType) -> CGPoint {
        return NMapViewResources.anchorPoint(withType: poiFlagType)
    }
    open func onMapOverlay(_ poiDataOverlay: NMapPOIdataOverlay!, calloutOffsetWithType poiFlagType: NMapPOIflagType) -> CGPoint {
        return CGPoint(x: 0, y: 0)
    }
    open func onMapOverlay(_ poiDataOverlay: NMapPOIdataOverlay!, imageForCalloutOverlayItem poiItem: NMapPOIitem!, constraintSize: CGSize, selected: Bool, imageForCalloutRightAccessory: UIImage!, calloutPosition: UnsafeMutablePointer<CGPoint>!, calloutHit calloutHitRect: UnsafeMutablePointer<CGRect>!) -> UIImage! {
        return nil
    }
    open func onMapOverlay(_ poiDataOverlay: NMapPOIdataOverlay!, viewForCalloutOverlayItem poiItem: NMapPOIitem!, calloutPosition: UnsafeMutablePointer<CGPoint>!) -> UIView! {
        
        let data = self.appDelegate.nearDatas[Int(poiItem.iconIndex)]
        calloutPosition.pointee.x = round(self.popoverView.bounds.size.width / 2) + 1
        self.curData = data
        if let map = mapView, let coord = data.coord {
            map.setMapCenter(coord)
            if self.levelStepper.value < 11 {
                self.levelStepper.value = 11
                map.setZoomLevel(11)
            }
        }
        
        self.popoverView.showPopover(data: data)
        //self.searchView.hideSearchFilterView()
        //self.detailView.selectRow(row: data)
        //self.detailView.showDetailView()
        
        return nil
    }
    
    // MARK: - Layer Button
    @IBAction func layerButtonAction(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "Layers", message: nil, preferredStyle: .actionSheet)
        
        if let map = mapView {
            // Action Sheet 생성
            let trafficAction = UIAlertAction(title: "Traffic layer is " + (map.mapViewTrafficMode ? "On" : "Off"), style: .default, handler: { (action) -> Void in
                print("Traffic layer Selected...")
                map.mapViewTrafficMode = !map.mapViewTrafficMode
            })
            
            let bicycleAction = UIAlertAction(title: "Bicycle layer is " + (map.mapViewBicycleMode ? "On" : "Off"), style: .default, handler: { (action) -> Void in
                print("Traffic layer Selected...")
                map.mapViewBicycleMode = !map.mapViewBicycleMode
            })
            
            let alphaAction = UIAlertAction(title: "Alpha layer is " + (map.mapViewAlphaLayerMode ? "On" : "Off"), style: .default, handler: { (action) -> Void in
                print("Alpha layer Selected...")
                map.mapViewAlphaLayerMode = !map.mapViewAlphaLayerMode
                
                //                지도 위 반투명 레이어에 색을 지정할 때에는 다음 메서드를 사용한다
                //                map.setMapViewAlphaLayerMode(!map.mapViewAlphaLayerMode, with: UIColor(red: 0.5, green: 1.0, blue: 0.5, alpha: 0.9))
            })
            
            alertController.addAction(trafficAction)
            alertController.addAction(bicycleAction)
            alertController.addAction(alphaAction)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Map Mode Segmented Control
    @IBAction func modeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView?.mapViewMode = .vector
        case 1:
            mapView?.mapViewMode = .satellite
        case 2:
            mapView?.mapViewMode = .hybrid
        default:
            mapView?.mapViewMode = .vector
        }
    }
    
    
    @IBOutlet var searchText: UITextField!
    @IBAction func submit(_ sender: Any) {
        
        if searchText.text != nil && searchText.text != "" {
            
            self.appDelegate.isSearch = true
            self.appDelegate.nearDatas = []
            for data in self.appDelegate.datas {
                if self.searchView.matches(for: "(\(searchText.text!))", in: data.name) {
                    self.appDelegate.nearDatas.append(data)
                }
            }
            self.appDelegate.isAutoCenter = false
            self.drawMarker(true)
            self.detailList.reloadData();
            self.detailView.showDetailView();
            self.view.endEditing(true)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true);
    }
    
    @IBAction func privPolicy() {
        let url = URL(string: "http://croot.kr/pynm_privatePolicy.html")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            //If you want handle the completion block than
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                print("Open url : \(success)")
            })
        }
    }
    
    @IBAction func more(_ sender: UIButton) {
        //self.tableView
        self.detailView.selectRow(row: self.curData!)
        self.detailView.showDetailView()
    }
    
    @IBAction func searchBoxToggle(_ sender: Any) {
        if self.searchView.isHidden == true {
            self.searchView.showSearchView()
        } else {
            self.searchView.hideSearchView()
            
            self.appDelegate.isSearch = false
            self.appDelegate.nearDatas = []
            for data in self.appDelegate.datas {
                self.appDelegate.nearDatas.append(data)
            }
            self.detailList.reloadData();
        }
    }
    
    @IBAction func setMeCenter(_ sender: Any) {
        self.detailView.hideDetailView()
        self.popoverView.hidePopover()
        //self.searchView.hideSearchFilterView()
        mapView?.setMapCenter(self.appDelegate.myLocation)
        
        self.setMeCenter.setBackgroundImage(#imageLiteral(resourceName: "v4_btn_navi_location_selected"), for: .normal)
    }
    
    // MARK: - Level Stepper
    func initLevelStepper(_ minValue: Int32, maxValue: Int32, initialValue: Int32) {
        levelStepper.minimumValue = Double(minValue)
        levelStepper.maximumValue = Double(maxValue)
        levelStepper.stepValue = 1
        levelStepper.value = Double(initialValue)
    }
    
    @IBAction func levelStepperValeChanged(_ sender: UIStepper) {
        mapView?.setZoomLevel(Int32(sender.value))
    }

    @IBOutlet var filterRating: UISlider!
    @IBOutlet var filterDistance: UISlider!
    @IBOutlet var filterPrice: UISlider!
    @IBAction func resetFilter(_ sender: Any) {
        self.filterRating.value = 3
        self.filterDistance.value = 10
        self.filterPrice.value = 12000
    }
}

