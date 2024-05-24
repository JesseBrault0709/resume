# frozen_string_literal: true

require 'erb'
require 'fileutils'
require 'thor'
require 'asciidoctor-pdf'

class BuildCli < Thor
  def self.exit_on_failure?
    true
  end

  class_option 'build-name', aliases: :n, default: 'general', desc: 'the name of the build'
  class_option 'doc-type', aliases: :k, default: 'resume', desc: 'the type of the document, such as "resume" or "cv"'
  class_option 'job-title', aliases: :j, default: 'Full-Stack Software Engineer', desc: 'the job title, such as "Software Engineer"'
  class_option 'cover-page', aliases: :c, type: :boolean, desc: 'include the cover page'
  class_option :jvm, type: :boolean, default: true, desc: 'emphasize jvm experience'
  class_option :web, type: :boolean, desc: 'emphasize web experience'
  class_option 'page-size', default: 'a4', desc: 'the page size, such as "a4" or "letter"'

  desc 'build', 'build the résumé'
  option 'include-time', type: :boolean, desc: 'include the time in the build-folder name'
  option :open, aliases: :o, type: :boolean, desc: 'automatically open the built resume in Preview (Mac OS only)'
  def build
    Build.new(
      :build,
      options['build-name'],
      options['doc-type'],
      options['include-time'],
      options['job-title'],
      options['cover-page'],
      options[:web] ? :web : :jvm,
      options['page-size'],
      options[:open]
    ).build
  end

  desc 'create', 'create a build which can be manually modified and built directly by asciidoctor-pdf'
  def create
    Build.new(
      :create,
      options['build-name'],
      options['doc-type'],
      false,
      options['job-title'],
      options['cover-page'],
      options[:web] ? :web : :jvm,
      options['page-size'],
      false
    ).files(true)
  end
end

class Build
  def initialize(command, build_name, doc_type, include_time, job_title, cover_page, type, page_size, open)
    @command = command
    @build_name = build_name
    @doc_type = doc_type

    dt = DateTime.now
    date = sprintf('%d.%02d.%02d', dt.year, dt.month, dt.day)
    time = include_time ? sprintf('-%02d.%02d', dt.hour, dt.second) : ''
    date_time = date + time
    if @build_name.empty?
      @build_dir = "builds/#{date_time}"
    else
      @build_dir = "builds/#{date_time}-#{@build_name}"
    end

    @type == type

    @job_title = job_title
    @cover_page = cover_page
    @page_size = page_size
    @open = open
  end

  def build
    files(false)
    convert_and_open
  end

  def files(include_script)
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
    File.open("#{@build_dir}/#{@build_name}-#{@doc_type}.asciidoc", 'w') do |file|
      file.write cv
    end

    if include_script
      build_script = ERB.new(File.read('src/ruby/build.sh.erb')).result(binding)
      File.open("#{@build_dir}/build", 'w') do |file|
        file.write build_script
        file.chmod(0755)
      end
    end
  end

  def convert_and_open
    out_name = if @build_name.empty?
                 @type == :jvm ? 'cv-jvm.pdf' : 'cv-web.pdf'
               else
                 "#{@build_name}.pdf"
               end

    out = "#{@build_dir}/#{out_name}"

    Asciidoctor.convert_file(
      "#{@build_dir}/#{@build_name}-#{@doc_type}.asciidoc",
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

  def path_before_theme
    if @command.eql?(:build)
      @build_dir + '/'
    else
      ''
    end
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
