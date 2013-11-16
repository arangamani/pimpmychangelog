module PimpMyChangelog
  class Parser
    attr_reader :changelog

    # @param [String] changelog
    def initialize(changelog)
      @changelog = changelog
    end

    # @return [String] the changelog content without the link definitions
    def content
      @changelog.split(Pimper::SEPARATOR).first
    end

    # @return [Array] ordered array of issue numbers found in the changelog
    #   Example: ['12', '223', '470']
    def issues
      changelog.scan(/#(\d+)/).flatten.uniq.sort_by(&:to_i)
    end

    # @return [Array] ordered array of contributors found in the changelog
    #   Example: ['gregbell', 'pcreux', 'samvincent']
    def contributors
      changelog.scan(/@([\w-]+)/).flatten.uniq.sort
    end

    def commit_shas
      puts "Changelog received: #{changelog.inspect}"
      scanned = changelog.scan(/(\b[0-9a-f]{8,40}\b)/).flatten.uniq.sort
      puts "Changelog commit sha scanned: #{scanned.inspect}"
      scanned
    end
  end
end
