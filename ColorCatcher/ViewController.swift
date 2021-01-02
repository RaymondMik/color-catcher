//
//  ViewController.swift
//  MyFavColors
//
//  Created by Ramón Miklus on 31/12/20.
//

import UIKit

extension UIImage {
    // Get average color of an image
    // source: https://www.hackingwithswift.com/example-code/media/how-to-read-the-average-color-of-a-uiimage-using-ciareaaverage
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: 1)
    }
}

extension UIColor {
    // Convert UIColor to Hex color string
    // source: https://stackoverflow.com/questions/36341358/how-to-convert-uicolor-to-string-and-string-to-uicolor-using-swift
    func toHexString(uppercased: Bool = false) -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        let hex = [r, g, b].map { $0 * 255 }.reduce("", { $0 + String(format: "%02x", Int($1)) })
        return uppercased ? hex.uppercased() : hex
    }
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var original: UIImage!
    @IBOutlet var colorNameLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func addColor() {
        // Open device camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraImage = UIImagePickerController()
            cameraImage.sourceType = .camera
            cameraImage.allowsEditing = true
            cameraImage.delegate = self
            present(cameraImage, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // handle image captured with the device camera
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        original = image
        
        let averageColor = original.averageColor
        self.view.backgroundColor = averageColor
        self.colorNameLabel.font.withSize(20)
        self.colorNameLabel.text = "HEX: #" + (averageColor?.toHexString())! ?? "#000000"
    }
    
    @objc func appMovedToBackground() {
        self.view.backgroundColor = UIColor.black
        self.colorNameLabel.text = "Take a picture of something to catch the average HEX color"
    }
}
