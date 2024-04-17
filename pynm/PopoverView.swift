//
//  PopoverView.swift
//  pynm
//
//  Created by 최근호 on 2018. 7. 4..
//  Copyright © 2018년 최근호. All rights reserved.
//

import UIKit
import JSPhoneFormat

class PopoverView: UIView {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet var name: UILabel!
    @IBOutlet var address: UILabel!
    @IBOutlet var tel: UILabel!
    @IBOutlet var star: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: -1, height: 3)
        layer.shadowRadius = 1
        layer.shadowOpacity = 0.4
    }
    
    func showPopover(data: StoreData) {
        self.appDelegate.isAutoCenter = false
        self.isHidden = false
        self.name.text = data.name
        self.address.text = "\(data.address1) \(data.address2) \(data.address3)"
        
        
        let x = (self.superview!.frame.width - self.frame.width) / 2
        let y = (self.superview!.frame.height / 2) - self.frame.height - 54
        self.frame.origin = CGPoint(x: x, y: y)
        
        let phoneFormat = JSPhoneFormat.init(appenCharacter: "-")
        self.tel.text = phoneFormat.addCharacter(at: data.tel)
        
        if star.subviews.count > 0 {
            star.subviews.forEach { $0.removeFromSuperview() }
        }
        for i in 1...Int(floor(data.star!)) {
            let view = UIImageView(image: UIImage(named: "star-filled"))
            view.frame.size = CGSize(width: 18, height: 18)
            view.frame.origin.x = CGFloat((i-1)*22)
            star.addSubview(view)
        }
        
        if floor(data.star!) != data.star! {
            let view = UIImageView(image: UIImage(named: "star-half"))
            view.frame.size = CGSize(width: 18, height: 18)
            view.frame.origin.x = CGFloat(star.subviews.count * 22)
            star.addSubview(view)
        }
        
    }
    
    func hidePopover() {
        self.isHidden = true
    }
    
}
