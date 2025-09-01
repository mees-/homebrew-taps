class ConfettiWebsocket < Formula
  desc "Confetti WebSocket client that runs as a background daemon"
  homepage "https://github.com/mees-/confetti-webhook"
  version "0.0.2"
  license "MIT"

  depends_on "oven-sh/bun/bun"

  # Use the source code repository
  url "https://github.com/mees-/confetti-webhook/archive/refs/tags/client-v0.1.2.tar.gz"
  sha256 "d5558cd419c8d46bdc958064cb97f963d1ea793866414c025906ec15033512ed"

  def install
    # Build from source
    cd "client" do
      system "bun", "install"
      system "bun", "run", "release"
      bin.install "dist/confetti-websocket"
    end

  end

  def post_install
    # Create config directory
    config_dir = File.join(Dir.home, ".config", "confetti-websocket")
    FileUtils.mkdir_p(config_dir)
    
    # Create default config if it doesn't exist
    config_file = File.join(config_dir, "config.json")
    unless File.exist?(config_file)
      File.write(config_file, <<~JSON)
        {
          "url": "ENTER_WEBSOCKET_URL_HERE"
        }
      JSON
    end
    
    ohai "Confetti WebSocket client has been installed!"
    puts
    puts "To start the service:"
    puts "  brew services start confetti-websocket"
    puts
    puts "To stop the service:"
    puts "  brew services stop confetti-websocket"
    puts
    puts "To check service status:"
    puts "  brew services list | grep confetti-websocket"
    puts
    puts "Configuration file location:"
    puts "  ~/.config/confetti-websocket/config.json"
    puts
    puts "Please update the WebSocket URL in the config file before starting the service."
  end

  def uninstall
    # Stop the service if it's running
    system "brew", "services", "stop", "confetti-websocket"
    
    # Remove the binary
    bin.delete "confetti-websocket"
    FileUtils.rm_rf(File.join(Dir.home, ".config", "confetti-websocket"))
  end

  service do
    run [File.join(opt_bin, "confetti-websocket")]
    keep_alive true
    log_path File.join(var, "log", "confetti-websocket.log")
    error_log_path File.join(var, "log", "confetti-websocket.log")
    working_dir Dir.home
    environment_variables PATH: "#{HOMEBREW_PREFIX}/bin:/usr/bin:/bin"
  end

  test do
    # Test that the binary exists and is executable
    assert_predicate File.join(bin, "confetti-websocket"), :exist?
    assert_predicate File.join(bin, "confetti-websocket"), :executable?
    
    # Test help output
    output = shell_output("#{File.join(bin, "confetti-websocket")} --help", 0)
    assert_match "Usage:", output
  end
end
