//
//  DetailViewController.swift
//  pynm
//
//  Created by 최근호 on 2018. 7. 2..
//  Copyright © 2018년 최근호. All rights reserved.
//

import UIKit
import JSPhoneFormat

class DetailView: UIView {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var levelStepper: UIStepper!
    @IBOutlet weak var setMeCenter: UIButton!
    @IBOutlet var list: UITableView!
    @IBOutlet var content: UIScrollView!
    @IBOutlet var selName: UILabel!
    @IBOutlet var selStar: UIView!
    @IBOutlet var selInfo: UILabel!
    @IBOutlet var selImg: UIImageView!
    @IBOutlet var selTel: UILabel!
    @IBOutlet var selAddr: UILabel!
    @IBOutlet var selTime: UILabel!
    @IBOutlet var selComment: UITextView!
    
    @IBAction func btnDetail(_ sender: UIButton) {
        let isShow = !self.appDelegate.isShowDetail
        
        if isShow == true {
            self.showDetailView()
        } else {
            self.hideDetailView()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func showDetailView() {
        let height: Int = 280
        self.appDelegate.isShowDetail = true
        //self.DetailButton.setImage(#imageLiteral(resourceName: "double-down-arrow.png"), for: .normal)
        self.content.contentSize.height = self.selComment.frame.height + 240;
        self.content.setContentOffset(CGPoint(x:0,y:0), animated: false);
        
        UIView.animate(withDuration: 0.2, animations: {
            let originY = CGFloat(Int(self.superview!.frame.height) - height)
            self.frame.origin.y = originY
            self.frame.size.height = CGFloat(height)
            self.levelStepper.frame.origin.y = originY - 40
            self.setMeCenter.frame.origin.y = originY - 90
        }, completion: { (finished) in
            if finished {
                self.content.contentSize.height = self.selComment.frame.height + 280;
            }
        })
        
        self.selComment.sizeToFit()
    }
    
    func hideDetailView() {
        let height: Int = 40
        self.appDelegate.isShowDetail = false
        //self.DetailButton.setImage(#imageLiteral(resourceName: "double-up-arrow"), for: .normal)
        UIView.animate(withDuration: 0.2, animations: {
            let originY = CGFloat(Int(self.superview!.frame.height) - height)
            self.frame.origin.y = originY
            self.frame.size.height = CGFloat(height)
            self.levelStepper.frame.origin.y = originY - 40
            self.setMeCenter.frame.origin.y = originY - 90
        })
        
    }
    
    //상세목록 중 선택 시
    func selectRow(row: StoreData) {
        
        self.appDelegate.isAutoCenter = false
        
        self.selImg.image = nil
        if row.image.count > 0 {
            for i in 0...row.image.count-1 {
                storage.child(row.image[i]!).getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                    if let error = error {
                        print(error)
                    } else {
                        let image = UIImage(data: data!)
                        self.selImg.image = image
                    }
                }
            }
        }
        
        selName.text = row.name
        
        if selStar.subviews.count > 0 {
            selStar.subviews.forEach { $0.removeFromSuperview() }
        }
        //let starText = String(format: "%.1f",row.star!)
        for i in 1...Int(floor(row.star!)) {
            let view = UIImageView(image: UIImage(named: "star-filled"))
            view.frame.size = CGSize(width: 12, height: 12)
            view.frame.origin.x = CGFloat((i-1)*15)
            selStar.addSubview(view)
        }
        
        if floor(row.star!) != row.star! {
            let view = UIImageView(image: UIImage(named: "star-half"))
            view.frame.size = CGSize(width: 12, height: 12)
            view.frame.origin.x = CGFloat(selStar.subviews.count * 15)
            selStar.addSubview(view)
        }
        
        var distText = ""
        if row.distance < 0 {
            distText = "\(String(round(row.distance*1000)))m"
        } else {
            distText = "\(String(row.distance))km"
        }
    
        let phoneFormat = JSPhoneFormat.init(appenCharacter: "-");
        selInfo.text = distText
        selTel.text = phoneFormat.addCharacter(at: row.tel);
        selAddr.text = "\(row.address1) \(row.address2) \(row.address3)"
        
        let formatter = DateFormatter();
        if let opentime = row.opentime, let closetime = row.closetime {
            formatter.dateFormat = "HH:mm"
            
            if let open = formatter.date(from:opentime), let close = formatter.date(from:closetime) {
                selTime.text = "\(open) ~ \(close)"
            }
        }
        
        if let comment = row.comment {
            selComment.text = "\(comment)"
        } else {
            selComment.text = "후기가 없습니다."
        }
        
        self.content.setContentOffset(CGPoint(x:0,y:0), animated: false)
    }
}
