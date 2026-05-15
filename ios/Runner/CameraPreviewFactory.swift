//
//  CameraPreviewFactory.swift
//

import Flutter
import UIKit

class CameraPreviewFactory:
    NSObject,
    FlutterPlatformViewFactory {

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {

        return CameraPreviewView(
            frame: frame,
            viewId: viewId,
            args: args
        )
    }
}