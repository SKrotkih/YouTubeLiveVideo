import Foundation

enum RTSPMethod: String {
    case options      = "OPTIONS"
    case describe     = "DESCRIBE"
    case announce     = "ANNOUNCE"
    case setup        = "SETUP"
    case play         = "PLAY"
    case pause        = "PAUSE"
    case teardown     = "TEARDOWN"
    case getParameter = "GET_PARAMETER"
    case setParameter = "SET_PARAMETER"
    case redirect     = "REDIRECT"
    case record       = "RECORD"
}

// MARK: RTSPResponder
protocol RTSPResponder: class {
    func onResponse(response:RTSPResponse)
}

// MARK: -
final class RTSPNullResponder: RTSPResponder {
    static let instance:RTSPNullResponder = RTSPNullResponder()

    func onResponse(response:RTSPResponse) {
    }
}

// MARK: -
class RTSPConnection: NSObject {
    static let defaultRTPPort:Int32 = 8000

    var userAgent:String = "lf.swift"

    private var sequence:Int = 0
    private lazy var socket:RTSPSocket = {
        let socket:RTSPSocket = RTSPSocket()
        socket.delegate = self
        return socket
    }()

    private var responders:[RTSPResponder] = []

    func doMethod(method: RTSPMethod, _ uri: String, _ headerFields:[String:String] = [:], _ responder:RTSPResponder = RTSPNullResponder.instance) {
        sequence += 1
        var request:RTSPRequest = RTSPRequest()
        request.uri = uri
        request.method = method.rawValue
        request.headerFields = headerFields
        request.headerFields["C-Seq"] = "\(sequence)"
        request.headerFields["User-Agent"] = userAgent
        responders.append(responder)
        socket.doOutput(request)
    }
}

// MARK: RTSPSocketDelegate
extension RTSPConnection: RTSPSocketDelegate {
    func listen(response: RTSPResponse) {
        guard let responder:RTSPResponder = responders.first else {
            return
        }
        responder.onResponse(response)
        responders.removeFirst()
    }
}
