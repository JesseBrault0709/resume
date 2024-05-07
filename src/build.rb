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
  option :job_title, default: 'Full-Stack Software Engineer'
  option :jvm, type: :boolean, default: true
  option :web, type: :boolean
  option :page_size, default: 'a4'
  option :open, type: :boolean
  def build
    Build.new(options[:jvm], options[:job_title], options[:page_size], options[:open]).build
  end
end

class Build
  def initialize(is_jvm, job_title, page_size, open)
    @is_jvm = is_jvm
    @job_title = job_title
    @page_size = page_size
    @open = open
  end

  def build
    FileUtils.makedirs('build')

    theme = ERB.new(File.read('src/cv-theme.yml.erb')).result(binding)
    File.open('build/cv-theme.yml', 'w') do |file|
      file.write theme
    end

    cv = ERB.new(File.read('src/cv.asciidoc.erb')).result(binding)
    File.open('build/cv.asciidoc', 'w') do |file|
      file.write cv
    end

    out = @is_jvm ? 'build/cv-jvm.pdf' : 'build/cv-web.pdf'

    Asciidoctor.convert_file('build/cv.asciidoc', backend: :pdf, safe: :unsafe, to_file: out)

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

BuildCli.start
