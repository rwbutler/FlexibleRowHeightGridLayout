// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "FlexibleRowHeightGridLayout",
    platforms: [
        .iOS("9.0")
    ],
    products: [
        .library(
            name: "FlexibleRowHeightGridLayout",
            targets: ["FlexibleRowHeightGridLayout"]
        )
    ],
    targets: [
        .target(
            name: "FlexibleRowHeightGridLayout",
            path: "FlexibleRowHeightGridLayout/Classes"
        )
    ]
)
