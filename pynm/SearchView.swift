//
//  Search.swift
//  pynm
//
//  Created by 최근호 on 2018. 7. 7..
//  Copyright © 2018년 최근호. All rights reserved.
//

import UIKit

class SearchView: UIView {
    
    @IBOutlet var searchBtn: UIButton!
    @IBOutlet var searchCloseBtn: UIButton!
    @IBOutlet var searchText: UITextField!
    @IBOutlet var searchFilter: UIView!
    @IBOutlet var filterRating: UISlider!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func UIColorHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    func matches(for regex: String, in text: String) -> Bool {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.count > 0
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.isHidden = true
        
    }
    
    func showSearchView() {
        self.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            
            self.searchCloseBtn.backgroundColor = self.UIColorHex(rgbValue: 0xD34817);
            self.searchCloseBtn.setImage(#imageLiteral(resourceName: "search-close"), for: .normal)
            
            self.frame.size.width = self.superview!.frame.size.width - 32;
        }, completion: { (finished) in
        })
    }
    
    func hideSearchView() {
        
        searchText.text = ""
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.searchCloseBtn.backgroundColor = self.UIColorHex(rgbValue: 0x2D3773);
            self.searchCloseBtn.setImage(#imageLiteral(resourceName: "magnifying-glass.png"), for: .normal)
            
            self.frame.size.width = 0;
        
        }, completion: { (finished) in
            self.isHidden = true
            self.appDelegate.isSearch = true
        })
    }
    /*
    func showSearchFilterView() {
        self.searchFilter.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.searchFilter.frame.size.height = 140
        })
    }
    
    func hideSearchFilterView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.searchFilter.frame.size.height = 0
        })
    }
    */
    
    
    /*
    @IBAction func searchFilterToggle(_ sender: Any) {
        self.searchFilter.isHidden = !self.searchFilter.isHidden
        
        if self.searchFilter.isHidden == false {
            self.showSearchFilterView()
        } else {
            self.hideSearchFilterView()
        }
    }
 */
}
