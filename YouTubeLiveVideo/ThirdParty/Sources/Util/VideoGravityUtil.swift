import Foundation
import AVFoundation

final class VideoGravityUtil {
    @inline(__always) static func calclute(videoGravity:String, inout inRect:CGRect, inout fromRect:CGRect) {
        switch videoGravity {
        case AVLayerVideoGravityResizeAspect:
            resizeAspect(&inRect, fromRect: &fromRect)
        case AVLayerVideoGravityResizeAspectFill:
            resizeAspectFill(&inRect, fromRect: &fromRect)
        default:
            break
        }
    }

    @inline(__always) static func resizeAspect(inout inRect:CGRect, inout fromRect:CGRect) {
        let xRatio:CGFloat = inRect.width / fromRect.width
        let yRatio:CGFloat = inRect.height / fromRect.height
        if (yRatio < xRatio) {
            inRect.origin.x = (inRect.size.width - fromRect.size.width * yRatio) / 2
            inRect.size.width = fromRect.size.width * yRatio
        } else {
            inRect.origin.y = (inRect.size.height - fromRect.size.height * xRatio) / 2
            inRect.size.height = fromRect.size.height * xRatio
        }
    }

    @inline(__always) static func resizeAspectFill(inout inRect:CGRect, inout fromRect:CGRect) {
        let inRectAspect:CGFloat = inRect.size.width / inRect.size.height
        let fromRectAspect:CGFloat = fromRect.size.width / fromRect.size.height
        if (inRectAspect < fromRectAspect) {
            inRect.origin.x += (inRect.size.width - inRect.size.height * fromRectAspect) / 2
            inRect.size.width = inRect.size.height * fromRectAspect
        } else {
            inRect.origin.y += (inRect.size.height - inRect.size.width / fromRectAspect) / 2
            inRect.size.height = inRect.size.width / fromRectAspect
        }
    }
}
