Pod::Spec.new do |s|
  s.name             = "NSString+ShellSplit"
  s.version          = "0.0.1"
  s.summary          = "A category to split NSStrings by shell-quoting rules"
  s.homepage         = "https://github.com/wjk/NSString+ShellSplit"
  s.license          = 'Ruby'
  s.author           = { "William Kent" => "github.com/wjk" }
  s.source           = { :git => "https://github.com/wjk/NSString+ShellSplit.git", :tag => s.version.to_s }

  s.source_files = 'Pod/Classes'
  s.requires_arc = true
end
