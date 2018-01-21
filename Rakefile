require "mkmf"
require 'cli/ui'
require "open3"

def execute(command)
    return_value = nil
    Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
        while line=stdout.gets do 
            puts(line) 
        end
        while line = stderr.gets do
            puts(line)
        end
        return_value = wait_thr.value
    end
    abort unless return_value.success?
end

desc "Fetches all Carthage dependencies"
task :dependencies do
    CLI::UI::StdoutRouter.enable
    CLI::UI::Frame.open('🤪 Carthage dependencies') do
      execute("carthage update")
    end
end

desc "Build the iOS app"
task :build_ios do
    CLI::UI::StdoutRouter.enable
    CLI::UI::Frame.open('Build iOS app 🐸') do
        execute("xcodebuild -workspace Projects/Issues.xcworkspace -scheme App -configuration Debug | xcpretty")
    end
end

desc "Build the iOS app"
task :build_ios do
    CLI::UI::StdoutRouter.enable
    CLI::UI::Frame.open('Build iOS app 🐸') do
        execute("xcodebuild -workspace Projects/Issues.xcworkspace -scheme App -configuration Debug | xcpretty")
    end
end

desc "Generates Xcode projects"
task :generate_projects do
  CLI::UI::StdoutRouter.enable
  CLI::UI::Frame.open('Generating GitHubKit project 🦁') do
    execute("xcodegen --spec Projects/GitHubKit/project.yml --project Projects/GitHubKit/")
  end
end