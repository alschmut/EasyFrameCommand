# EasyFrameCommand
`easy-frame` is a swift command line interface to create framed App Store screenshots from a custom SwiftUI layout

This swift package is meant to be forked and adjusted for individual use. This allows you to write your own custom App Store screenshot layout using SwiftUI.

## Usage instructions
-   Create a directory structure according to the below example
    - Place your unframed raw screenshots grouped by locale into the `raw-screenshots` directory. If you use fastlane to create the unframed screenshots it will automatically create the required directory structure. Just make sure to set the `output_directory` to `raw-screenshots`
        ```ruby
        capture_ios_screenshots(
            devices: ["iPhone 15 Pro Max", "iPad Pro (12.9-inch) (6th generation)"],
            languages: ["de-DE", "en-GB"],
            scheme: ENV["XCODE_SCHEME_UI_TEST"],
            output_directory: "./fastlane/raw-screenshots",
            clear_previous_screenshots: true,
            override_status_bar: true
        )
        ```
    -   Create an `EasyFrame.json` config file according to the below example. It describes each desired App Store page, the localized texts to be rendered on the resulting screenshot and a screenshot name, which should be part of the raw screenshot filename
-   Download the device frames via `fastlane frameit download_frames`, which persists them inside `~/.fastlane/frameit/latest`
-   Run the local `easy-frame` CLI command via the below command:
    ```sh
    cd path/to/EasyFrameCommandProject
    swift run easy-frame path/to/parent-folder
    ```
    
### Example directory structure
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

### EasyFrame.json Example
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
