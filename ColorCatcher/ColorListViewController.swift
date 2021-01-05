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
    // Convert hex to RGB usable as UIColor
    func toRgbString(_ hex: String) -> UIColor {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hex.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        if hexString.count != 6 {
            return UIColor.black
        }
        
        var rgb : UInt32 = 0
        Scanner(string: hexString).scanHexInt32(&rgb)
        
        return UIColor.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0, blue: CGFloat(rgb & 0x0000FF) / 255.0, alpha: 1.0)
    }
    
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

extension UITableView {
    // extend tableView in order to handle empty table status
    // source: https://stackoverflow.com/a/45157417
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
      
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "Helvetica Neue", size: 20)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}

class ColorListViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var original: UIImage!
    var colors: [Color] = []
    
    func createNote(hexString: String) {
        let _ = ColorManager.main.create(hexString: hexString)
        reload()
    }

    // @IBOutlet var colorNameLabel: UILabel!
    
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
        let hexString = averageColor?.toHexString()
        createNote(hexString: "#" + hexString!)
    }
    
    @objc func appMovedToBackground() {
        self.view.backgroundColor = UIColor.black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
        // Do any additional setup after loading the view.
    }
    
    // define table num of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // define table size (rows)
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if colors.count == 0 {
            self.tableView.setEmptyMessage("Take a picture of something to catch the average HEX color")
        } else {
            self.tableView.restore()
        }

        return colors.count
    }

    // define table cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        cell.textLabel?.text = colors[indexPath.row].hex
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        cell.contentView.backgroundColor = UIColor().toRgbString(colors[indexPath.row].hex)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    // delete action
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "delete") { (action, indexPath) in
            // delete item at indexPath
            ColorManager.main.delete(color: self.colors[indexPath.row])
            self.reload()

        }
        return [delete]
    }
    
    func reload() {
        colors = ColorManager.main.getAllColors()
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ColorSegue" {
            if let destination = segue.destination as?
                ColorViewController {
                    destination.color = colors[tableView.indexPathForSelectedRow!.row]

            }
        }
    }
}
