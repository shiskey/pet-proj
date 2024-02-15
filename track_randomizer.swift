#!/usr/bin/swift

import Cocoa
typealias UIColor = NSColor

extension UIColor {

    enum UIColorInputError: Error {

        case missingHashMarkAsPrefix(String)
        case unableToScanHexValue(String)
        case mismatchedHexStringLength(String)
        case unableToOutputHexStringForWideDisplayColor

        var errorDescription: String? {
            switch self {
            case .missingHashMarkAsPrefix(let hex):
                return "Invalid RGB string, missing '#' as prefix in \(hex)"

            case .unableToScanHexValue(let hex):
                return "Scan \(hex) error"

            case .mismatchedHexStringLength(let hex):
                return "Invalid RGB string from \(hex), number of characters after '#' should be either 3, 4, 6 or 8"

            case .unableToOutputHexStringForWideDisplayColor:
                return "Unable to output hex string for wide display color"
            }
        }
    }

    private func hexStringThrows(_ includeAlpha: Bool = true) throws -> String  {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)

        guard r >= 0 && r <= 1 && g >= 0 && g <= 1 && b >= 0 && b <= 1 else {
            let error = UIColorInputError.unableToOutputHexStringForWideDisplayColor
            print(error.localizedDescription)
            throw error
        }

        if (includeAlpha) {
            return String(format: "#%02X%02X%02X%02X",
                          Int(round(r * 255)), Int(round(g * 255)),
                          Int(round(b * 255)), Int(round(a * 255)))
        } else {
            return String(format: "#%02X%02X%02X", Int(round(r * 255)),
                          Int(round(g * 255)), Int(round(b * 255)))
        }
    }

    func hexString(_ includeAlpha: Bool = true) -> String  {
        guard let hexString = try? hexStringThrows(includeAlpha) else {
            return ""
        }
        return hexString
    }

}

func generateColor() -> String {
    return UIColor(
        hue: .random(in: 0...1),
        saturation: .random(in: 0.4...1),
        brightness: .random(in: 0.9...1),
        alpha: .random(in: 0.9...1)
    ).hexString()
}

func generateRandomValue() -> Float {
    return .random(in: 0.2...0.7)
}

func saveToJsonFile(to path: String) {
    let fileUrl = URL(fileURLWithPath: path)

    let leadColor = generateColor()
    let bassColor = generateColor()

    let sourceJsonString =
    """
    {
        "name": "Test track",
        "description": "Description_HERE",
        "duration": "Duration_HERE_3:00",
        "bpm": 120,
        "main_pad": "pad.mp3",
        "final_chord": "final.mp3",
        "tail": "tail.mp3",
        "backgroung_image": "back",
        "lead_progress_bar_color": "\(leadColor)",
        "bass_progress_bar_color": "\(bassColor)",
        "bells": ["bell1.mp3", "bell2.mp3", "bell3.mp3"],
        "lead_loops": [
            {
                "audio_name": "lead1.mp3",
                "audio_bell": "lead_1_bell.mp3",
                "icon_name_default": "p03",
                "icon_name_active": "a03",
                "icon_name_timeline": "t03",
                "icon_color": "\(leadColor)",

                "c1_stroke_color": "\(generateColor())",

                "c1_active_stroke_color": "\(generateColor())",
                "c2_active_stroke_color": "\(generateColor())",
                "c3_active_stroke_color": "\(generateColor())",

                "c1_active_progress_color": "\(generateColor())",
                "c2_active_progress_color": "\(generateColor())",
                "c3_active_progress_color": "\(generateColor())",

                "c2_active_progress": \(generateRandomValue()),
                "c3_active_progress": \(generateRandomValue()),

                "show_on_bar": 1,
                "hide_on_bar": 0
            },
            {
                "audio_name": "lead2.mp3",
                "audio_bell": "lead_2_bell.mp3",
                "icon_name_default": "p04",
                "icon_name_active": "a04",
                "icon_name_timeline": "t04",
                "icon_color": "\(leadColor)",

                "c1_stroke_color": "\(generateColor())",

                "c1_active_stroke_color": "\(generateColor())",
                "c2_active_stroke_color": "\(generateColor())",
                "c3_active_stroke_color": "\(generateColor())",

                "c1_active_progress_color": "\(generateColor())",
                "c2_active_progress_color": "\(generateColor())",
                "c3_active_progress_color": "\(generateColor())",

                "c2_active_progress": \(generateRandomValue()),
                "c3_active_progress": \(generateRandomValue()),

                "show_on_bar": 1,
                "hide_on_bar": 0
            },
        ],
        "bass_loops": [
            {
                "audio_name": "bass1.mp3",
                "audio_bell": "bass_1_bell.mp3",
                "icon_name_default": "p03",
                "icon_name_active": "a03",
                "icon_name_timeline": "t03",
                "icon_color": "\(bassColor)",

                "c1_stroke_color": "\(generateColor())",

                "c1_active_stroke_color": "\(generateColor())",
                "c2_active_stroke_color": "\(generateColor())",
                "c3_active_stroke_color": "\(generateColor())",

                "c1_active_progress_color": "\(generateColor())",
                "c2_active_progress_color": "\(generateColor())",
                "c3_active_progress_color": "\(generateColor())",

                "c2_active_progress": \(generateRandomValue()),
                "c3_active_progress": \(generateRandomValue()),

                "show_on_bar": 1,
                "hide_on_bar": 0
            },
            {
                "audio_name": "bass2.mp3",
                "audio_bell": "bass_2_bell.mp3",
                "icon_name_default": "p04",
                "icon_name_active": "a04",
                "icon_name_timeline": "t04",
                "icon_color": "\(bassColor)",

                "c1_stroke_color": "\(generateColor())",

                "c1_active_stroke_color": "\(generateColor())",
                "c2_active_stroke_color": "\(generateColor())",
                "c3_active_stroke_color": "\(generateColor())",

                "c1_active_progress_color": "\(generateColor())",
                "c2_active_progress_color": "\(generateColor())",
                "c3_active_progress_color": "\(generateColor())",

                "c2_active_progress": \(generateRandomValue()),
                "c3_active_progress": \(generateRandomValue()),

                "show_on_bar": 1,
                "hide_on_bar": 0
            },
        ]
    }
    """

    // Transform array into data and save it into file
    do {
        try sourceJsonString.write(to: fileUrl, atomically: true, encoding: .utf8)
    } catch {
        print(error)
    }
}

saveToJsonFile(to: "./garageBand/App/Resources/Track1/track_1.json")



/*
 Source json
 */

//{
//    "name": "Test track",
//    "description": "Description_HERE",
//    "duration": "Duration_HERE_3:00",
//    "bpm": 120,
//    "main_pad": "pad.mp3",
//    "final_chord": "final.mp3",
//    "tail": "tail.mp3",
//    "backgroung_image": "back",
//    "lead_progress_bar_color": "#ffffffff",
//    "bass_progress_bar_color": "#e910e0ff",
//    "bells": ["bell1.mp3", "bell2.mp3", "bell3.mp3"],
//    "lead_loops": [
//        {
//            "audio_name": "lead1.mp3",
//            "icon_name_default": "p03",
//            "icon_name_active": "a03",
//            "icon_name_timeline": "t03",
//            "icon_color": "#ffffffff",
//
//            "c1_stroke_color": "#ffffff4d",
//
//            "c1_active_stroke_color": "#ffffff4d",
//            "c2_active_stroke_color": "#ffffff4d",
//            "c3_active_stroke_color": "#ffffff4d",
//
//            "c1_active_progress_color": "#ffffffff",
//            "c2_active_progress_color": "#ff7f35ff",
//            "c3_active_progress_color": "#28c038ff",
//
//            "c2_active_progress": 0.46,
//            "c3_active_progress": 0.57,
//
//            "show_on_bar": 1,
//            "hide_on_bar": 0
//        },
//        {
//            "audio_name": "lead2.mp3",
//            "icon_name_default": "p04",
//            "icon_name_active": "a04",
//            "icon_name_timeline": "t04",
//            "icon_color": "#ffffffff",
//
//            "c1_stroke_color": "#ffffff4d",
//
//            "c1_active_stroke_color": "#ffffff4d",
//            "c2_active_stroke_color": "#ffffff4d",
//            "c3_active_stroke_color": "#ffffff4d",
//
//            "c1_active_progress_color": "#ffffffff",
//            "c2_active_progress_color": "#ff7f35ff",
//            "c3_active_progress_color": "#28c038ff",
//
//            "c2_active_progress": 0.46,
//            "c3_active_progress": 0.57,
//
//            "show_on_bar": 1,
//            "hide_on_bar": 0
//        },
//    ],
//    "bass_loops": [
//        {
//            "audio_name": "bass1.mp3",
//            "icon_name_default": "p03",
//            "icon_name_active": "a03",
//            "icon_name_timeline": "t03",
//            "icon_color": "#e910e0ff",
//
//            "c1_stroke_color": "#e910e04d",
//
//            "c1_active_stroke_color": "#ffffff4d",
//            "c2_active_stroke_color": "#e910e04d",
//            "c3_active_stroke_color": "#e910e04d",
//
//            "c1_active_progress_color": "#ffffffff",
//            "c2_active_progress_color": "#56b9f7ff",
//            "c3_active_progress_color": "#e910e04d",
//
//            "c2_active_progress": 0.5,
//            "c3_active_progress": 0.0,
//
//            "show_on_bar": 1,
//            "hide_on_bar": 0
//        },
//        {
//            "audio_name": "bass2.mp3",
//            "icon_name_default": "p04",
//            "icon_name_active": "a04",
//            "icon_name_timeline": "t04",
//            "icon_color": "#ce2babff",
//
//            "c1_stroke_color": "#e910e04d",
//
//            "c1_active_stroke_color": "#ffffff4d",
//            "c2_active_stroke_color": "#e910e04d",
//            "c3_active_stroke_color": "#e910e000",
//
//            "c1_active_progress_color": "#ffffffff",
//            "c2_active_progress_color": "#56b9f7ff",
//            "c3_active_progress_color": "#e910e0ff",
//
//            "c2_active_progress": 0.5,
//            "c3_active_progress": 0.0,
//
//            "show_on_bar": 1,
//            "hide_on_bar": 0
//        },
//    ]
//}
