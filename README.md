# EasyFrameCommand
`easy-frame` is a lightweight Swift command-line tool to create fully customizable framed App Store screenshots using SwiftUI. Built for automation, this open-source Swift package efficiently frames screenshots for all localizations and devices. While it follows a workflow similar to fastlane’s frameit, you are in full controll. Simply fork the reporsitory with just about 500 lines of swift code and get as creative as you desire.

![Framed Example Screenshots](example.png)

## Who is this tool for?
This Swift package is ideal for indie Swift developers who value:  
- **Automation** over manual screenshot creation  
- **Full design control** over relying on premade templates with limited customization options
- **A free and open-source solution** over paid alternatives

## Getting started
To generate screenshots like in the example above - using the implementation as-is, just follow the below steps:
1. Set up the directory structure as shown in the example below. Place your unframed raw screenshots in the `raw-screenshots` directory, organized by locale.  
    ```
    parent-folder/
        raw-screenshots/
            EasyFrame.json
            de-DE/
                iPhone 15 Pro Max-1-calendar.png
                iPhone 15 Pro Max-2-list.png
                iPhone 15 Pro Max-3-add-entry.png
                iPad Pro (12.9-inch) (6th generation)-1-calendar.png
                iPad Pro (12.9-inch) (6th generation)-2-list.png
                iPad Pro (12.9-inch) (6th generation)-3-add-entry.png
            en-GB/
                iPhone 15 Pro Max-1-calendar.png
                iPhone 15 Pro Max-2-list.png
                iPhone 15 Pro Max-3-add-entry.png
                iPad Pro (12.9-inch) (6th generation)-1-calendar.png
                iPad Pro (12.9-inch) (6th generation)-2-list.png
                iPad Pro (12.9-inch) (6th generation)-3-add-entry.png
    ```
   - If you use Fastlane to generate unframed screenshots, its output directory structure already meets `easy-frame`'s requirements. Just ensure that the `output_directory` is set to `raw-screenshots`.  
        ```ruby
        capture_ios_screenshots(
            devices: ["iPhone 15 Pro Max", "iPad Pro (12.9-inch) (6th generation)"],
            languages: ["de-DE", "en-GB"],
            scheme: ENV["XCODE_SCHEME_UI_TEST"],
            output_directory: "./fastlane/raw-screenshots"
        )
        ```
1. Create an `EasyFrame.json` configuration file based on the below [Example EasyFrame.json](#example-easyframejson). The config defines each App Store page with:  
    - localized texts, which will be displayed on the framed screenshot  
    - a screenshot name, which must partially match the raw screenshot filenames
1. Run the local `easy-frame` swift package command to generate framed screenshots into the `parent-folder/screenshots/` directory:
    ```sh
    cd path/to/EasyFrameCommandProject
    swift run easy-frame path/to/parent-folder
    ```

## Which devices are supported?
See [Sources/EasyFrameCommand/Model/SupportedDevice.swift](Sources/EasyFrameCommand/Model/SupportedDevice.swift). The device frames have been taken from https://github.com/fastlane/frameit-frames.

## Where to adjust the SwiftUI layout?
See [Sources/EasyFrameCommand/View/ScreenshotView.swift](Sources/EasyFrameCommand/View/ScreenshotView.swift)
    
## Example directory structure
```
parent-folder/
    raw-screenshots/ (the locale folders contains the unframed raw screenshots)
        EasyFrame.json
        de-DE/
            iPhone 15 Pro Max-1-calendar.png
            iPhone 15 Pro Max-2-list.png
            iPhone 15 Pro Max-3-add-entry.png
            iPad Pro (12.9-inch) (6th generation)-1-calendar.png
            iPad Pro (12.9-inch) (6th generation)-2-list.png
            iPad Pro (12.9-inch) (6th generation)-3-add-entry.png
        en-GB/
            iPhone 15 Pro Max-1-calendar.png
            iPhone 15 Pro Max-2-list.png
            iPhone 15 Pro Max-3-add-entry.png
            iPad Pro (12.9-inch) (6th generation)-1-calendar.png
            iPad Pro (12.9-inch) (6th generation)-2-list.png
            iPad Pro (12.9-inch) (6th generation)-3-add-entry.png
    screenshots/ (this folder will be generated by easy-frame with the framed screenshots)
        de-DE/
            iPhone 15 Pro Max-1-calendar.jpg
            iPhone 15 Pro Max-2-list.jpg
            iPhone 15 Pro Max-3-add-entry.jpg
            iPad Pro (12.9-inch) (6th generation)-1-calendar.jpg
            iPad Pro (12.9-inch) (6th generation)-2-list.jpg
            iPad Pro (12.9-inch) (6th generation)-3-add-entry.jpg
        en-GB/
            iPhone 15 Pro Max-1-calendar.jpg
            iPhone 15 Pro Max-2-list.jpg
            iPhone 15 Pro Max-3-add-entry.jpg
            iPad Pro (12.9-inch) (6th generation)-1-calendar.jpg
            iPad Pro (12.9-inch) (6th generation)-2-list.jpg
            iPad Pro (12.9-inch) (6th generation)-3-add-entry.jpg
```

## Example EasyFrame.json
```json
{
    "pages": [
        {
            "languages": [
                { "locale": "en-GB", "title": "Title 1 EN", "description": "Description" },
                { "locale": "de-DE", "title": "Title 1 DE", "description": "Description" }
            ],
            "screenshot": "1-calendar"
        },
        {
            "languages": [
                { "locale": "en-GB", "title": "Title 2 EN", "description": "Description" },
                { "locale": "de-DE", "title": "Title 2 DE", "description": "Description" }
            ],
            "screenshot": "2-list"
        },
        {
            "languages": [
                { "locale": "en-GB", "title": "Title 3 EN", "description": "Description" },
                { "locale": "de-DE", "title": "Title 3 DE", "description": "Description" }
            ],
            "screenshot": "3-add-entry"
        }
    ]
}
```

## Acknowledgments
Thanks to [FrameKit](https://github.com/ainame/FrameKit) and fastlane [frameit](https://docs.fastlane.tools/actions/frameit/), which both inspired me and made this swift package possible.

## Roadmap
There is no planned roadmap or a guarantee of ongoing maintenance. This Swift package is intended to be forked and serves as a solid starting point for further customization 😉
