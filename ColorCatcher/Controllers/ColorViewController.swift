//
//  ColorViewController.swift
//  ColorCatcher
//
//  Created by Ramón Miklus on 05/01/21.
//

import Foundation
import UIKit

class ColorViewController: UIViewController {
    @IBOutlet var contentTextView: UILabel!

    var color: Color? = nil

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        contentTextView.text = "HEX color: " + color!.hex
        self.view.backgroundColor = UIColor().toRgbString(color!.hex)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}
