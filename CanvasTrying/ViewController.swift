//
//  ViewController.swift
//  CanvasTrying
//
//  Created by Muhammad Tafani Rabbani on 15/10/20.
//

import UIKit
import PencilKit

class ViewController: UIViewController,PKCanvasViewDelegate,PKToolPickerObserver{

    @IBOutlet weak var mCanvas: PKCanvasView!
    
    var height :CGFloat = 500
    var width :CGFloat = 768
    
    var drawing = PKDrawing()
    var toolPicker: PKToolPicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mCanvas.delegate = self
//        mCanvas.tool = PKInkingTool(.marker,color: .blue)
        mCanvas.drawing = drawing
        mCanvas.alwaysBounceVertical = true
        mCanvas.drawingPolicy = .anyInput
        
        // Set up the tool picker
        if #available(iOS 14.0, *) {
            toolPicker = PKToolPicker()
        } else {
            let window = parent?.view.window
            toolPicker = PKToolPicker.shared(for: window!)
        }
        
        toolPicker.setVisible(true, forFirstResponder: mCanvas)
        toolPicker.addObserver(mCanvas)
        toolPicker.addObserver(self)
//        updateLayout(for: toolPicker)
        mCanvas.becomeFirstResponder()
        
        
        
    }

    @IBAction func saveFile(_ sender: Any) {
        let myArray = mCanvas.drawing.dataRepresentation() //NSDATA
        
//        let path = FileManager.default.urls(for: .documentDirectory,
//                                            in: .userDomainMask)[0].appendingPathComponent("myFile.drawing")

        let mPath = "\(AppDelegate.getAppDelegate().getDocDir())/myFile.drawing"
        do{
            try myArray.write(to: URL(fileURLWithPath: mPath))
//            print(path)
        }catch{
            print(error)
        }
        
        //sharing via airdrop
        let activityItems = [NSData(contentsOfFile: "\(mPath)")!]
        let applicationActivities: [UIActivity]? = nil
        let excludedActivityTypes: [UIActivity.ActivityType]? = nil
        typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
        let callback: Callback? = nil
        
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities)
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = callback
        present(controller, animated: true)
    }
    
    
    
    func updateLayout(for toolPicker: PKToolPicker) {
        let obscuredFrame = toolPicker.frameObscured(in: view)
        
        // If the tool picker is floating over the canvas, it also contains
        // undo and redo buttons.
        if obscuredFrame.isNull {
            mCanvas.contentInset = .zero
            navigationItem.leftBarButtonItems = []
        }
        
        // Otherwise, the bottom of the canvas should be inset to the top of the
        // tool picker, and the tool picker no longer displays its own undo and
        // redo buttons.
        else {
            mCanvas.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: view.bounds.maxY - obscuredFrame.minY, right: 0)
            
        }
        mCanvas.scrollIndicatorInsets = mCanvas.contentInset
    }
}

