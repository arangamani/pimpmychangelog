class Githubifier

  attr_reader :user, :project, :changelog

  def initialize(user, project, changelog)
    @user = user
    @project = project
    @changelog = changelog
  end

  # @return [String] The changelog with contributors and issues as link
  def better_changelog
    @better_changelog = changelog.clone

    linkify_changelog!
    append_links_definition_to_changelog!

    @better_changelog
  end

  ISSUE_NUMBER_REGEXP = /(^|[^\[])#(\d+)($|[^\]])/
  CONTRIBUTOR_REGEXP = /(^|[^\[])@(\w+)($|[^\]])/

  def linkify_changelog!
    @better_changelog.gsub!(ISSUE_NUMBER_REGEXP, '\1[#\2][]\3')
    @better_changelog.gsub!(CONTRIBUTOR_REGEXP, '\1[@\2][]\3')
  end

  def append_links_definition_to_changelog!
    issues.each do |issue|
      @better_changelog += "\n[##{issue}]: https://github.com/#{user}/#{project}/issues/#{issue}"
    end

    contributors.each do |contributor|
      @better_changelog += "\n[@#{contributor}]: https://github.com/#{contributor}"
    end
  end

  def issues
    ChangeLogParser.new(changelog).issues
  end

  def contributors
    ChangeLogParser.new(changelog).contributors
  end
end

class ChangeLogParser
  attr_reader :changelog

  # @param [String] changelog
  def initialize(changelog)
    @changelog = changelog
  end

  # @return [String] the changelog content without the link definitions
  def content
    @changelog.split("<!--- The following link definitions are generated by PimpMyChangelog --->").first
  end

  # @return [Array] ordered array of issue numbers found in the changelog
  #   Example: ['12', '223', '470']
  def issues
    changelog.scan(/#(\d+)/).
      uniq.sort_by { |a, b| a.to_i <=> b.to_i }.flatten
  end

  # @return [Array] ordered array of contributors found in the changelog
  #   Example: ['gregbell', 'pcreux', 'samvincent']
  def contributors
    changelog.scan(/@(\w+)/).
      uniq.sort.flatten
  end

end
