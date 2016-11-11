import Foundation
import AVFoundation

// MARK: FLVVideoCodec
enum FLVVideoCodec: UInt8 {
    case SorensonH263 = 2
    case Screen1      = 3
    case ON2VP6       = 4
    case ON2VP6Alpha  = 5
    case Screen2      = 6
    case AVC          = 7
    case Unknown      = 0xFF

    var isSupported:Bool {
        switch self {
        case SorensonH263:
            return false
        case Screen1:
            return false
        case ON2VP6:
            return false
        case ON2VP6Alpha:
            return false
        case Screen2:
            return false
        case AVC:
            return true
        case Unknown:
            return false
        }
    }
}

// MARK: - FLVFrameType
enum FLVFrameType: UInt8 {
    case Key        = 1
    case Inter      = 2
    case Disposable = 3
    case Generated  = 4
    case Command    = 5
}

// MARK: - FLVAVCPacketType
enum FLVAVCPacketType:UInt8 {
    case Seq = 0
    case Nal = 1
    case Eos = 2
}

// MARK: - FLVAACPacketType
enum FLVAACPacketType:UInt8 {
    case Seq = 0
    case Raw = 1
}

// MARK: - FLVSoundRate
enum FLVSoundRate:UInt8 {
    case KHz5_5 = 0
    case KHz11  = 1
    case KHz22  = 2
    case KHz44  = 3
    
    var floatValue:Float64 {
        switch self {
        case KHz5_5:
            return 5500
        case KHz11:
            return 11025
        case KHz22:
            return 22050
        case KHz44:
            return 44100
        }
    }
}

// MARK: - FLVSoundSize
enum FLVSoundSize:UInt8 {
    case Snd8bit = 0
    case Snd16bit = 1
}

// MARK: - FLVSoundType
enum FLVSoundType:UInt8 {
    case Mono = 0
    case Stereo = 1
}

// MARK: - FLVAudioCodec
enum FLVAudioCodec:UInt8 {
    case PCM           = 0
    case ADPCM         = 1
    case MP3           = 2
    case PCMLE         = 3
    case Nellymoser16K = 4
    case Nellymoser8K  = 5
    case Nellymoser    = 6
    case G711A         = 7
    case G711MU        = 8
    case AAC           = 10
    case Speex         = 11
    case MP3_8k        = 14
    case Unknown       = 0xFF
    
    var isSupported:Bool {
        switch self {
        case PCM:
            return false
        case ADPCM:
            return false
        case MP3:
            return false
        case PCMLE:
            return false
        case Nellymoser16K:
            return false
        case Nellymoser8K:
            return false
        case Nellymoser:
            return false
        case G711A:
            return false
        case G711MU:
            return false
        case AAC:
            return true
        case Speex:
            return false
        case MP3_8k:
            return false
        case Unknown:
            return false
        }
    }
    
    var formatID:AudioFormatID {
        switch self {
        case PCM:
            return kAudioFormatLinearPCM
        case MP3:
            return kAudioFormatMPEGLayer3
        case PCMLE:
            return kAudioFormatLinearPCM
        case AAC:
            return kAudioFormatMPEG4AAC
        case MP3_8k:
            return kAudioFormatMPEGLayer3
        default:
            return 0
        }
    }
    
    var headerSize:Int {
        switch self {
        case AAC:
            return 2
        default:
            return 1
        }
    }
}

// MARK: -
struct FLVTag {

    enum TagType: UInt8 {
        case Audio = 8
        case Video = 9
        case Data  = 18

        var streamId:UInt16 {
            switch self {
            case .Audio:
                return RTMPChunk.audio
            case .Video:
                return RTMPChunk.video
            case .Data:
                return 0
            }
        }
        
        var headerSize:Int {
            switch self {
            case .Audio:
                return 2
            case .Video:
                return 5
            case .Data:
                return 0
            }
        }

        func createMessage(streamId: UInt32, timestamp: UInt32, buffer:NSData) -> RTMPMessage {
            switch self {
            case .Audio:
                return RTMPAudioMessage(streamId: streamId, timestamp: timestamp, buffer: buffer)
            case .Video:
                return RTMPVideoMessage(streamId: streamId, timestamp: timestamp, buffer: buffer)
            case .Data:
                return RTMPDataMessage(objectEncoding: 0x00)
            }
        }
    }

    static let headerSize = 11

    var tagType:TagType = .Data
    var dataSize:UInt32 = 0
    var timestamp:UInt32 = 0
    var timestampExtended:UInt8 = 0
    var streamId:UInt32 = 0
}

// MARK: CustomStringConvertible
extension FLVTag: CustomStringConvertible {
    var description:String {
        return Mirror(reflecting: self).description
    }
}

