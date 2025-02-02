# EasyFrameCommand
`easy-frame` is a command line interface written in swift to create AppStore screenshots with framed devices, marketing text, and custom layout written in SwiftUI. 

## Idea
This swift package is meant to be forked and adjusted for individual use. This allows you to write your own custom layout using SwiftUI.

## Usage instructions
-   Create a folder structure with the raw screenshots like in the below example (e.x. by using the fastlane create_screenshots lane)
-   Create an EasyFrame.json config file like in the below example, which describes each desired App Store page, the localized texts to be rendered on the resulting screenshot and a screenshot name, which should be part of the raw screenshot filename
-   Download the device frames via `fastlane frameit download_frames`, which persists them inside `~/.fastlane/frameit/latest`
-   Run the local `easy-frame` CLI command via the below command:
    ```sh
    cg path/to/EasyFrameCommandProject
    swift run easy-frame --root-folder path/to/parent-folder
    ```
    
## Example 
```
// directory structure
parent-folder/
    raw-screenshots/
        EasyFrame.json
        de-DE/
            iPhone 15 Pro Max-1-calendar.png
            iPhone 15 Pro Max-2-list.png
            iPhone 15 Pro Max-3-add-entry.png
            iPhone 15 Pro Max-4-settings.png
            iPad Pro (12.9-inch) (6th generation)-1-calendar.png
            iPad Pro (12.9-inch) (6th generation)-2-list.png
            iPad Pro (12.9-inch) (6th generation)-3-add-entry.png
            iPad Pro (12.9-inch) (6th generation)-4-settings.png
        en-GB/
            iPhone 15 Pro Max-1-calendar.png
            iPhone 15 Pro Max-2-list.png
            iPhone 15 Pro Max-3-add-entry.png
            iPhone 15 Pro Max-4-settings.png
            iPad Pro (12.9-inch) (6th generation)-1-calendar.png
            iPad Pro (12.9-inch) (6th generation)-2-list.png
            iPad Pro (12.9-inch) (6th generation)-3-add-entry.png
            iPad Pro (12.9-inch) (6th generation)-4-settings.png
    screenshots/ (this folder will be created by easy-frame)
        de-DE/
            iPhone 15 Pro Max-1-calendar.jpg
            iPhone 15 Pro Max-2-list.jpg
            iPhone 15 Pro Max-3-add-entry.jpg
            iPhone 15 Pro Max-4-settings.jpg
            iPad Pro (12.9-inch) (6th generation)-1-calendar.jpg
            iPad Pro (12.9-inch) (6th generation)-2-list.jpg
            iPad Pro (12.9-inch) (6th generation)-3-add-entry.jpg
            iPad Pro (12.9-inch) (6th generation)-4-settings.jpg
        en-GB/
            iPhone 15 Pro Max-1-calendar.jpg
            iPhone 15 Pro Max-2-list.jpg
            iPhone 15 Pro Max-3-add-entry.jpg
            iPhone 15 Pro Max-4-settings.jpg
            iPad Pro (12.9-inch) (6th generation)-1-calendar.jpg
            iPad Pro (12.9-inch) (6th generation)-2-list.jpg
            iPad Pro (12.9-inch) (6th generation)-3-add-entry.jpg
            iPad Pro (12.9-inch) (6th generation)-4-settings.jpg
        
```

```json
// EasyFrame.json
{
    "pages": [
        {
            "languages": [
                { "locale": "en-GB", "title": "Title 1 EN", "description": "Description" },
                { "locale": "de-DE", "title": "Title 1 DE", "description": "Description" }
            ],
            "screenshotsSingleHero": {
                "firstScreenshot": "1-calendar",
                "additionalScreenshots": ["2-list"]
            }
        },
        {
            "languages": [
                { "locale": "en-GB", "title": "Title 2 EN", "description": "Description" },
                { "locale": "de-DE", "title": "Title 2 DE", "description": "Description" }
            ],
            "screenshot": "3-add-entry"
        },
        {
            "languages": [
                { "locale": "en-GB", "title": "Title 3 EN", "description": "Description" },
                { "locale": "de-DE", "title": "Title 3 DE", "description": "Description" }
            ],
            "screenshot": "4-settings"
        }
    ]
}
```
