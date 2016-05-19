module CurlBuilder
  module Paths
    def work_dir
      @work_dir ||= File.join setup(:run_on_dir), "build"
    end

    def download_dir
      @download_dir ||= File.join work_dir, "download"
    end

    def source_dir
      @source_dir ||= File.join work_dir, "source"
    end

    def expanded_archive_dir
      @configure_binary ||= File.join source_dir, "curl-#{setup(:libcurl_version)}"
    end

    def archive_name
      @archive_name ||= "libcurl-#{setup(:libcurl_version)}.tar.gz"
    end

    def archive_path
      @archive_path ||= File.join download_dir, archive_name
    end

    def output_dir_for(platform, architecture)
      File.join work_dir, "out", platform, architecture
    end

    def binary_path_for(platform, architecture)
      File.join output_dir_for(platform, architecture), "lib", "libcurl.a"
    end

    def result_dir
      File.join setup(:run_on_dir), "curl"
    end

    def result_lib_dir(platform)
      File.join result_dir, "lib", platform 
    end

    def result_include_dir(platform, architecture)
      File.join result_dir, "include", platform, architecture
    end

    def packed_lib_path_with(platform)
      File.join result_lib_dir(platform), "libcurl.a"
    end
  end
end
