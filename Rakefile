require "mkmf"

desc "Fetches all Carthage dependencies"
task :dependencies do
    abort("Carthage is not installed in the system") unless find_executable("carthage")
    system("cd Projects/GitHubKit && carthage update") or exit
    system("cd Projects/IssuesKit && carthage update") or exit
end