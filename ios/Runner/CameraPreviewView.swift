//
//  CameraPreviewView.swift
//

import Flutter
import UIKit

class CameraPreviewView: NSObject, FlutterPlatformView {

    private let previewView: UIView

    init(
        frame: CGRect,
        viewId: Int64,
        args: Any?
    ) {

        previewView = StreamManager.shared.hkView

        previewView.frame = frame

        super.init()
    }

    func view() -> UIView {

        return previewView
    }
}