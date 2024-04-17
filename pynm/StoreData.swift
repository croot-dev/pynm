//
//  ListData.swift
//  pynm
//
//  Created by 최근호 on 2018. 7. 3..
//  Copyright © 2018년 최근호. All rights reserved.
//

struct StoreData {
    var name: String = ""
    var coord: NGeoPoint? = nil
    var address1: String = ""
    var address2: String = ""
    var address_jibun: String = ""
    var address3: String = ""
    var opentime: String? = nil
    var closetime: String? = nil
    var comment: String? = ""
    var price: Int? = nil
    var parking: Bool = false
    var star: Float? = nil
    var tel: String = ""
    var menu: Bool = false
    var image: [String?] = []
    var distance: Double = 0
}
