# frozen_string_literal: true

require 'erb'
require 'fileutils'
require 'thor'
require 'asciidoctor-pdf'

class BuildCli < Thor
  def self.exit_on_failure?
    true
  end

  desc 'build', 'build the résumé'
  option :build_name, aliases: :n, default: 'general'
  option :include_time, aliases: :t, type: :boolean
  option :job_title, aliases: :j, default: 'Full-Stack Software Engineer'
  option :jvm, type: :boolean, default: true
  option :web, type: :boolean
  option :page_size, default: 'a4'
  option :open, aliases: :o, type: :boolean
  def build
    Build.new(
      options[:build_name],
      options[:include_time],
      options[:job_title],
      options[:jvm],
      options[:page_size],
      options[:open]
    ).build
  end
end

class Build
  def initialize(build_name, include_time, job_title, is_jvm, page_size, open)
    @build_name = build_name

    dt = DateTime.now
    date = sprintf('%d.%02d.%02d', dt.year, dt.month, dt.day)
    time = include_time ? sprintf('-%02d.%02d', dt.hour, dt.second) : ''
    date_time = date + time
    if @build_name.empty?
      @build_dir = "builds/#{date_time}"
    else
      @build_dir = "builds/#{date_time}-#{@build_name}"
    end

    @is_jvm = is_jvm
    @job_title = job_title
    @page_size = page_size
    @open = open
  end

  def build
    if FileTest.exist?(@build_dir)
      FileUtils.rm_r(@build_dir)
    end
    FileUtils.makedirs(@build_dir)

    # Off for now, until we figure out how to add image.
    # FileUtils.copy_file('images/selfPhoto.jpg', "#{@build_dir}/selfPhoto.jpg")

    theme = ERB.new(File.read('src/ruby/cv-theme.yml.erb')).result(binding)
    File.open("#{@build_dir}/cv-theme.yml", 'w') do |file|
      file.write theme
    end

    cv = ERB.new(File.read('src/ruby/cv.asciidoc.erb')).result(binding)
    File.open("#{@build_dir}/cv.asciidoc", 'w') do |file|
      file.write cv
    end

    out_name = if @build_name.empty?
                @is_jvm ? 'cv-jvm.pdf' : 'cv-web.pdf'
              else
                "#{@build_name}.pdf"
              end

    out = "#{@build_dir}/#{out_name}"

    Asciidoctor.convert_file(
      "#{@build_dir}/cv.asciidoc",
      backend: :pdf,
      safe: :unsafe,
      to_file: out
    )

    system "open -a Preview #{out}" if @open
  end

  def parts(*parts)
    parts.inject('') do |acc, part|
      acc + self.part(part)
    end
  end

  def part(part)
    File.read("src/include/#{part}.asciidoc") + "\n"
  end
end

# Leave here because we may need a simple extension in the future
# Asciidoctor::Extensions.register :unbreakable_list_items do
#   tree_processor do
#     process do |document|
#       document.find_by context: :list_item do |list_item|
#         open_block = Asciidoctor::Block.new(list_item, :open, content_model: :compound)
#         text_literal = Asciidoctor::Inline.new(open_block, :paragraph, list_item.text, content_model: :verbatim)
#         open_block << text_literal
#         open_block.set_option 'unbreakable'
#         list_item.text = nil
#         list_item.content_model = :compound
#         list_item.blocks << open_block
#       end
#     end
#   end
# end

BuildCli.start
