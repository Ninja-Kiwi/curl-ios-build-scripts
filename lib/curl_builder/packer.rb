module CurlBuilder
  class Packer < ConfigurableStep

    # Creation

    def initialize(options = {})
      super options
    end


    # Logging

    def log_id
      "PACKAGE"
    end


    # Interface

    def pack(compiled_targets)
      
      # Collect target platforms
      
      platforms = Hash.new {|k,v| k[v]=[]}
      
      compiled_targets.each do |target|
        info { "Platform: #{target.platform}" }
        platforms[target.platform] << target.arch
      end
      
      # Pack library and include files for each platform
      
      info { "Packing libraries and headers for #{platforms.keys().join(', ')}" }
      
      successful = {}
      
      platforms.each do |platform, architectures|
        if create_binary_for platform, architectures 
          successful[platform] = architectures
          
          architectures.each do |architecture|
            copy_include_dir platform, architecture
          end
        end
      end
      
      successful
    end

    private
    def copy_include_dir(platform, architecture)
      target_dir = result_include_dir(platform, architecture)
      FileUtils.mkdir_p target_dir
      files_to_copy = File.join output_dir_for(platform, architecture), "include", "curl", "*"

      copy_command = "cp -R #{files_to_copy} #{target_dir}"
      setup(:verbose) ? system(copy_command) : `#{copy_command} &>/dev/null`
      raise Errors::TaskError, "Failed to copy include dir from build to result directory" unless $?.success?

      $?.success?
    end

    def create_binary_for(platform, archs)
      return if archs.empty? || archs.nil?

      info {
        "Creating binary #{archs.size > 1 ? "with combined architectures" : "for architecture"} " + 
          "#{param(archs.join(", "))} (#{platform})..."
      }

      binaries = archs.collect { |arch| binary_path_for platform, arch }

      info { "Binaries: #{binaries.join(" ")}" }

      FileUtils.mkdir_p result_lib_dir platform

      `lipo -create #{binaries.join(" ")} -output #{packed_lib_path_with platform} &>/dev/null`
      warn { "Failed to pack '#{param(platform)}' binary (archs: #{param(archs.join(", "))})." } unless $?.success?

      $?.success?
    end
  end
end
