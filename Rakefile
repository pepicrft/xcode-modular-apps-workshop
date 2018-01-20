require "mkmf"
require 'cli/ui'
require "open3"

desc "Fetches all Carthage dependencies"
task :dependencies do
    abort("Carthage is not installed in the system") unless find_executable("carthage")
    CLI::UI::StdoutRouter.enable
    CLI::UI::Frame.open('Carthage dependencies') do
        CLI::UI::Frame.open('GitHubKit') do
            return_value = nil
            Open3.popen3("cd Projects/GitHubKit && carthage update") do |stdin, stdout, stderr, wait_thr|
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
        CLI::UI::Frame.open('IssuesKit') do
            return_value = nil
            Open3.popen3("cd Projects/IssuesKit && carthage update") do |stdin, stdout, stderr, wait_thr|
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
    end
end