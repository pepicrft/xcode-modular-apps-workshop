import Foundation
import SakefileDescription

func fetchDependencies() throws {
    try Utils.shell.runAndPrint(bash: "carthage update --platform iOS")
}

func build() throws {
    try Utils.shell.runAndPrint(bash: "xcodebuild -workspace Projects/Issues.xcworkspace -scheme App -configuration Debug | xcpretty")
}

func generate(project: String) throws {
    print("Generating project: \(project)")
    try Utils.shell.runAndPrint(bash: "xcodegen --spec Projects/\(project)/project.yml --project Projects/\(project)/")
}

let sake = Sake(tasks: [
    Task("build", description: "Builds the project") {
        try build()
    },
    Task("dependencies", description: "Fetches Carthage dependencies") {
        try fetchDependencies()
    },
    Task("generate-xcodeprojects", description: "Generates Xcode projects") {
        try generate(project: "GitHubKit")
        try generate(project: "IssuesKit")
        try generate(project: "IssuesUI")
        try generate(project: "App")
    }]
)


