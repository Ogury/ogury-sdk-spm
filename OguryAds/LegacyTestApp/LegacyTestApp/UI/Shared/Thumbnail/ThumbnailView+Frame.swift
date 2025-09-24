//
//  Copyright © 2020 co.ogury All rights reserved.
//

import UIKit

extension ThumbnailView {
    
    func updateLayoutForCurrentPanel() {
        switch segmentType.selectedSegmentIndex {
        case 0:
            defaultView.isHidden = false
            cornerView.isHidden = true
            positionView.isHidden = true
            updateLayoutForDefaultPanel()
        case 1:
            defaultView.isHidden = true
            cornerView.isHidden = false
            positionView.isHidden = true
            updateLayoutForCornerPanel()
        case 2:
            defaultView.isHidden = true
            cornerView.isHidden = true
            positionView.isHidden = false
            updateLayoutsForPositionPanel()
        default:
            break
        }
    }
    
    func updateFrameForCurrentPanel() {
        switch segmentType.selectedSegmentIndex {
        case 0:
            updateFrameForDefaultPanel()
        case 1:
            updateFrameForCornerPanel()
        case 2:
            updateFrameForPositionPanel()
        default:
            break
        }
    }
    
// MARK: - Default position panel
    
    func initDefaultView() {
        defaultView = UIView()
        let title = "Default size position :\n\tx: 20, y: 150" +
            "\n\twidth: 180, height: 180 \n\tbased on bottom right corner"
        titleDefaultView = UILabel()
        titleDefaultView.text = title
        titleDefaultView.numberOfLines = 0
        titleDefaultView.adjustsFontSizeToFitWidth = true

        customizeSmallLabel(label: titleDefaultView)
        addSubview(defaultView)
    }
    
    func updateLayoutForDefaultPanel() {
        addCommonViewsTo(parentView: defaultView)
        
        defaultView.addSubview(titleDefaultView)
    }

    func updateFrameForDefaultPanel() {
        
        titleDefaultView.frame = CGRect(x: 0,
                                        y: 182,
                                        width: defaultView.frame.width,
                                        height: 100)
        
        defaultView.frame = CGRect(x: 30,
                                   y: 30,
                                   width: frame.width - 60,
                                   height: frame.height - 60)
        
        adUnitIDLabel.frame = CGRect(x: 0,
                                     y: 5,
                                     width: defaultView.frame.width,
                                     height: 21)
        
        adUnitIDTextField.frame = CGRect(x: 0,
                                         y: 27,
                                         width: defaultView.frame.width,
                                         height: 34)
        
        campaignIDLabel.frame = CGRect(x: 0,
                                       y: 66,
                                       width: defaultView.frame.width * 0.475,
                                       height: 21)
        
        campaignIDField.frame = CGRect(x: 0,
                                       y: 87,
                                       width: defaultView.frame.width * 0.475,
                                       height: 34)
        
        creativeIDLabel.frame = CGRect(x: defaultView.frame.width * 0.525,
                                       y: 66,
                                       width: defaultView.frame.width * 0.475,
                                       height: 21)
        
        creativeIDField.frame = CGRect(x: defaultView.frame.width * 0.525,
                                       y: 87,
                                       width: defaultView.frame.width * 0.475,
                                       height: 34)
        
        dspCreativeIDLabel.frame = CGRect(x: 0,
                                          y: 126,
                                          width: defaultView.frame.width * 0.475,
                                          height: 21)
        
        dspCreativeIDField.frame = CGRect(x: 0,
                                          y: 148,
                                          width: defaultView.frame.width * 0.475,
                                          height: 34)
        
        dspRegionLabel.frame = CGRect(x: defaultView.frame.width * 0.525,
                                      y: 126,
                                      width: defaultView.frame.width * 0.475,
                                      height: 21)
        
        dspRegionPicker.frame = CGRect(x: defaultView.frame.width * 0.525,
                                       y: 148,
                                       width: defaultView.frame.width * 0.475,
                                       height: 34)
    }
    
// MARK: - Legacy position panel

    func initPositionView() {
        positionView = UIView()
        addSubview(positionView)
    }
    
    func updateLayoutsForPositionPanel() {
        yLabel.text = "Offset Top"
        xLabel.text = "Offset Right"

        addCommonViewsTo(parentView: positionView)
        addSizeViewsTo(parentView: positionView)
        addPositionViewsTo(parentView: positionView)
    }
    
    func updateFrameForPositionPanel() {
        updateFramesForCommonViews()
        updateFrameForSizeAndPositionViews()
    }

    func updateFramesForCommonViews() {
        
        positionView.frame = CGRect(x: 30,
                                    y: 30,
                                    width: frame.width - 60,
                                    height: frame.height - 60)
        
        adUnitIDLabel.frame = CGRect(x: 0,
                                     y: 5,
                                     width: positionView.frame.width,
                                     height: 21)
        
        adUnitIDTextField.frame = CGRect(x: 0,
                                         y: 27,
                                         width: positionView.frame.width,
                                         height: 34)
        
        campaignIDLabel.frame = CGRect(x: 0,
                                       y: 66,
                                       width: positionView.frame.width * 0.475,
                                       height: 21)
        
        campaignIDField.frame = CGRect(x: 0,
                                       y: 87,
                                       width: positionView.frame.width * 0.475,
                                       height: 34)
        
        creativeIDLabel.frame = CGRect(x: positionView.frame.width * 0.525,
                                       y: 66,
                                       width: positionView.frame.width * 0.475,
                                       height: 21)
        
        creativeIDField.frame = CGRect(x: positionView.frame.width * 0.525,
                                       y: 87,
                                       width: positionView.frame.width * 0.475,
                                       height: 34)
        
        dspCreativeIDLabel.frame = CGRect(x: 0,
                                          y: 126,
                                          width: positionView.frame.width * 0.475,
                                          height: 21)
        
        dspCreativeIDField.frame = CGRect(x: 0,
                                          y: 148,
                                          width: positionView.frame.width * 0.475,
                                          height: 34)
        
        dspRegionLabel.frame = CGRect(x: positionView.frame.width * 0.525,
                                      y: 126,
                                      width: positionView.frame.width * 0.475,
                                      height: 21)
        
        dspRegionPicker.frame = CGRect(x: positionView.frame.width * 0.525,
                                       y: 148,
                                       width: positionView.frame.width * 0.475,
                                       height: 34)
    }

    func updateFrameForSizeAndPositionViews() {
        yLabel.frame = CGRect(x: positionView.frame.width * 0.525,
                              y: 187,
                              width: positionView.frame.width * 0.475,
                              height: 21)
        xLabel.frame = CGRect(x: 0,
                              y: 187,
                              width: positionView.frame.width * 0.525,
                              height: 21)
        xTextField.frame = CGRect(x: 0,
                                  y: 209,
                                  width: positionView.frame.width * 0.475,
                                  height: 34)
        yTextField.frame = CGRect(x: positionView.frame.width * 0.525,
                                  y: 209,
                                  width: positionView.frame.width * 0.475,
                                  height: 34)
        widthLabel.frame = CGRect(x: positionView.frame.width * 0.525,
                                  y: 248,
                                  width: positionView.frame.width * 0.475,
                                  height: 21)
        heightLabel.frame = CGRect(x: 0,
                                   y: 248,
                                   width: positionView.frame.width * 0.475,
                                   height: 21)
        heightTextField.frame = CGRect(x: 0,
                                       y: 274,
                                       width: positionView.frame.width * 0.475,
                                       height: 34)
        widthTextField.frame = CGRect(x: positionView.frame.width * 0.525,
                                      y: 274,
                                      width: positionView.frame.width * 0.475,
                                      height: 34)
    }
    
// MARK: - Corner position panel

    func initCornerView() {
        cornerView = UIView()
        addSubview(cornerView)
    }
    
    func updateLayoutForCornerPanel() {
        yLabel.text = "Offset y"
        xLabel.text = "Offset x"

        addCommonViewsTo(parentView: cornerView)
        addSizeViewsTo(parentView: cornerView)
        addPositionViewsTo(parentView: cornerView)
        
        cornerView.addSubview(segmentCorner)
    }
    
    func updateFrameForCornerPanel() {
        basicFrame()
        positionAndSizeFrame()
    }

    func basicFrame() {
        
        cornerView.frame = CGRect(x: 30,
                                  y: 30,
                                  width: frame.width - 60,
                                  height: frame.height - 60)
        
        adUnitIDLabel.frame = CGRect(x: 0,
                                     y: 5,
                                     width: cornerView.frame.width,
                                     height: 21)
        
        adUnitIDTextField.frame = CGRect(x: 0,
                                         y: 27,
                                         width: cornerView.frame.width,
                                         height: 34)
        
        campaignIDLabel.frame = CGRect(x: 0,
                                       y: 66,
                                       width: cornerView.frame.width * 0.475,
                                       height: 21)
        
        campaignIDField.frame = CGRect(x: 0,
                                       y: 87,
                                       width: cornerView.frame.width * 0.475,
                                       height: 34)
        
        creativeIDLabel.frame = CGRect(x: cornerView.frame.width * 0.525,
                                       y: 66,
                                       width: cornerView.frame.width * 0.475,
                                       height: 21)
        
        creativeIDField.frame = CGRect(x: cornerView.frame.width * 0.525,
                                       y: 87,
                                       width: cornerView.frame.width * 0.475,
                                       height: 34)
        
        dspCreativeIDLabel.frame = CGRect(x: 0,
                                          y: 126,
                                          width: cornerView.frame.width * 0.475,
                                          height: 21)
        
        dspCreativeIDField.frame = CGRect(x: 0,
                                          y: 148,
                                          width: cornerView.frame.width * 0.475,
                                          height: 34)
        
        dspRegionLabel.frame = CGRect(x: cornerView.frame.width * 0.525,
                                      y: 126,
                                      width: cornerView.frame.width * 0.475,
                                      height: 21)
        
        dspRegionPicker.frame = CGRect(x: cornerView.frame.width * 0.525,
                                       y: 148,
                                       width: cornerView.frame.width * 0.475,
                                       height: 34)
    
    }

    func positionAndSizeFrame() {
        segmentCorner.frame = CGRect(x: 0,
                                     y: 197,
                                     width: cornerView.frame.width,
                                     height: 24)
        yLabel.frame = CGRect(x: cornerView.frame.width * 0.525,
                              y: 223,
                              width: cornerView.frame.width * 0.475,
                              height: 21)
        xLabel.frame = CGRect(x: 0,
                              y: 223,
                              width: cornerView.frame.width * 0.475,
                              height: 21)
        xTextField.frame = CGRect(x: 0,
                                  y: 245,
                                  width: cornerView.frame.width * 0.475,
                                  height: 34)
        yTextField.frame = CGRect(x: cornerView.frame.width * 0.525,
                                  y: 245,
                                  width: cornerView.frame.width * 0.475,
                                  height: 34)
        widthLabel.frame = CGRect(x: cornerView.frame.width * 0.525,
                                  y: 284,
                                  width: cornerView.frame.width * 0.475,
                                  height: 21)
        heightLabel.frame = CGRect(x: 0,
                                   y: 284,
                                   width: cornerView.frame.width * 0.525,
                                   height: 21)
        heightTextField.frame = CGRect(x: 0,
                                       y: 306,
                                       width: cornerView.frame.width * 0.475,
                                       height: 34)
        widthTextField.frame = CGRect(x: cornerView.frame.width * 0.525,
                                      y: 306,
                                      width: cornerView.frame.width * 0.475,
                                      height: 34)
    }
    
// MARK: - Common methods
    
    func addCommonViewsTo(parentView: UIView) {
        parentView.addSubview(campaignIDLabel)
        parentView.addSubview(adUnitIDLabel)
        parentView.addSubview(adUnitIDTextField)
        parentView.addSubview(campaignIDField)
        parentView.addSubview(creativeIDLabel)
        parentView.addSubview(creativeIDField)
        parentView.addSubview(dspCreativeIDLabel)
        parentView.addSubview(dspCreativeIDField)
        parentView.addSubview(dspRegionLabel)
        parentView.addSubview(dspRegionPicker)
    }
 
    func addSizeViewsTo(parentView: UIView) {
        parentView.addSubview(widthLabel)
        parentView.addSubview(heightLabel)
        parentView.addSubview(widthTextField)
        parentView.addSubview(heightTextField)
    }
    
    func addPositionViewsTo(parentView: UIView) {
        parentView.addSubview(yLabel)
        parentView.addSubview(xLabel)
        parentView.addSubview(yTextField)
        parentView.addSubview(xTextField)
    }
}
