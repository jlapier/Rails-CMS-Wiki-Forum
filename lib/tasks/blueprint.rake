namespace :blueprint do
  desc "Install/Update blueprint stylesheets (+plugins)"
  task :install do
    blueprint_css = File.expand_path("~/.blueprint_css")

    if File.exists?(blueprint_css)
      blueprint_path = File.new(blueprint_css, 'r').read.strip
    else
      puts("What is the path to your blueprint checkout?")
      blueprint_path = $stdin.gets.strip
    end

    compress_script = File.join(blueprint_path, 'lib', 'compress.rb')

    while !File.exists?(compress_script)
      puts("Could not find #{compress_script}. Please enter new path.")
      blueprint_path = $stdin.gets.strip
      compress_script = File.join(blueprint_path, 'lib', 'compress.rb')
    end

    File.open(blueprint_css, 'w'){|f| f.write(blueprint_path)}
    
    system "ruby #{compress_script} -f #{Rails.root.to_s}/config/blueprint_settings.yml -p default"
  end
end
