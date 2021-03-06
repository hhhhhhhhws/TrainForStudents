//
//  File.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2017/6/21.
//  Copyright © 2017年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class CheckboxCollectionView : BasePeiwuCollectionView{
    
    //实现UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        var cell = UICollectionViewCell.init()
        let a = jsonDataSource["answers"].arrayValue
        var data = JSON.init("")
        let answerDic = parentView?.answerDic[jsonDataSource["questionsid"].stringValue]
        if 0 == indexPath.item{
            let cellName = "c1"
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath)
            //获取数据
            data = jsonDataSource
            //渲染问题
            let lbl = (cell.viewWithTag(10001) as? UILabel)!
            var title = data["indexname"].stringValue + " " + data["title"].stringValue
            if answerDic != nil{
                title += answerDic!["inputanswer"]!
            }
            lbl.text = title
            
            lbl.numberOfLines = title.getLineNumberForWidth(width: lbl.frame.width - boundary, cFont: (lbl.font)!)
            lbl.frame.size = CGSize(width: lbl.frame.size.width, height: getHeightForLabel(lbl: lbl))
        }else{
            let cellName = "c2"
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath)
            cell.tag = 0
            //获取数据
            data = a[indexPath.item - 1]
            var inputAnswers = [""]
//            let answerDic = parentView?.answerDic[data["questionid"].stringValue]
            //渲染选项
            let btn = (cell.viewWithTag(10001) as? UIButton)!
            btn.layer.cornerRadius = btn.frame.width / 2
            btn.setTitle(data["selecttab"].stringValue, for: .normal)
            let lbl = (cell.viewWithTag(10002) as? UILabel)!
            let title = data["answervalue"].stringValue
            lbl.text = title
            lbl.numberOfLines = title.getLineNumberForWidth(width: lbl.frame.width - boundary, cFont: (lbl.font)!)
            let y = btn.frame.origin.y.adding(4)
//            var y = lbl.frame.origin.y
//            if lbl.numberOfLines >= 2{
//                y = btn.frame.origin.y
//            }
            lbl.frame.origin = CGPoint(x: lbl.frame.origin.x, y: y)
            lbl.frame.size = CGSize(width: lbl.frame.size.width, height: getHeightForLabel(lbl: lbl))
            
            if answerDic != nil {
                if answerDic?["inputanswer"] != nil{
                    inputAnswers = (answerDic?["inputanswer"]?.components(separatedBy: ","))!
                }   
            }
            
            for ia in inputAnswers {
                if btn.currentTitle == ia{
                    btn.setTitleColor(UIColor.white, for: .normal)
                    btn.backgroundColor = UIColor.init(hex: "ffc84c")
                    cell.tag = 1
                    break
                }else{
                    btn.setTitleColor(UIColor.init(hex: "5ea3f3"), for: .normal)
                    btn.backgroundColor = UIColor.init(hex: "f5f8fb")
                }
            }
            
            
        }
        
        
        return cell
        
    }
    
    //计算cell大小
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var labelWidth = UIScreen.width - 40 - boundary
        let a = jsonDataSource["answers"].arrayValue
        var lineHeight = CGFloat()
        var data = JSON.init("")
        var text = ""
        let index = indexPath.item
        var minHeight = CGFloat(40)
        
        //判断是题目还是答案
        if 0 == index{
            data = jsonDataSource
            text = data["indexname"].stringValue + " " + data["title"].stringValue
        }else{
            labelWidth = UIScreen.width - 40 - 35 - 8 - boundary
            data = a[index - 1]
            text = data["answervalue"].stringValue
            minHeight.add(10)  //答案选项的cell需要增加间距
        }
        let lineNumber = text.getLineNumberForWidth(width: labelWidth, cFont: questionFont)
        lineHeight = text.getHeight(font:questionFont)
        lineHeight.multiply(by: CGFloat(lineNumber))
        lineHeight.add(5)
        
        if lineHeight < minHeight {
            lineHeight = minHeight
        }
        
        
        return CGSize(width: UIScreen.width, height: lineHeight)
        
    }
    
    //cell被选中
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            return
        }
        let cell = collectionView.cellForItem(at: indexPath)
        let btn = cell?.viewWithTag(10001) as! UIButton
        let questionId = jsonDataSource["questionsid"].stringValue
        var answerDic = parentView?.answerDic[questionId]
        if answerDic == nil{
            answerDic = getAnswerJson(json: jsonDataSource)
        }
        var ia = answerDic?["inputanswer"]
        if cell?.tag == 0 { //未选中
            btn.setTitleColor(UIColor.white, for: .normal)
            btn.backgroundColor = UIColor.init(hex: "ffc84c")
            
            if ia == nil || ia == "" {
                ia = btn.currentTitle
            }else{
                ia = (ia)! + "," + btn.currentTitle!
            }
            ia = ia?.components(separatedBy: ",").sorted().joined(separator: ",")
            cell?.tag = 1
        }else{  //已选中
            btn.setTitleColor(UIColor.init(hex: "5ea3f3"), for: .normal)
            btn.backgroundColor = UIColor.init(hex: "f5f8fb")
            if (ia?.length)! <= 1{
                ia = ""
            }else{
                
                if btn.currentTitle == String(describing: ia![(ia?.startIndex)!]){
                    let range = ia?.range(of: btn.currentTitle! + ",")
                    ia?.removeSubrange(range!)
                }else{
                    let range = ia?.range(of: "," + btn.currentTitle!)
                    ia?.removeSubrange(range!)
                }
                
            }
            //ia.remove
            cell?.tag = 0
        }
        answerDic?["inputanswer"] = ia
        parentView?.answerDic[questionId] = answerDic

        let inputanswer = answerDic?["inputanswer"]

        if inputanswer != nil && inputanswer != ""{
            let cell = collectionView.cellForItem(at: IndexPath.init(row: 0, section: 0))
            let lbl = (cell?.viewWithTag(10001) as? UILabel)!
            var title = jsonDataSource["indexname"].stringValue + " " + jsonDataSource["title"].stringValue

            let str = inputanswer!
            
            title.insert(contentsOf: str.characters, at: title.endIndex)
            lbl.text = title
        }
    }
    
    
}
