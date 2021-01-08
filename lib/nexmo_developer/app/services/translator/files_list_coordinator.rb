module Translator
  class FilesListCoordinator
    def self.call(attrs = {})
      new(attrs).call
    end

    def initialize(days:)
      @days = days
    end

    def call
      process_files(files)
    end

    def files
      @files ||= `(git fetch origin master:master) && (git log --since="#{@days}".days --name-only --oneline --diff-filter=ACM --pretty=format: master #{Rails.configuration.docs_base_path}/_documentation/en #{Rails.configuration.docs_base_path}/_tutorials/en #{Rails.configuration.docs_base_path}/_use_cases/en) | uniq | awk 'NF'`.split("\n")
    end

    def process_files(files)
      files.each_with_object([]) do |file, list|
        if file.include?('_documentation')
          list << file if translatable_doc_file(file) == ''
        elsif file.include?('_use_cases')
          list << file if translatable_use_case_file(file) == ''
        elsif file.include?('_tutorials')
          list << file if translatable_tutorial_file(file) == ''
        else
          raise ArgumentError, "The following file did not match documentation, use cases or tutorials: #{file}"
        end
      end

      list.uniq
    end

    def translatable_doc_file(file)
      return nil unless File.exist?("#{Rails.configuration.docs_base_path}/#{file}")

      allowed_products.each do |product|
        return file if file.split('/')[2] == product
      end
    end

    def translatable_use_case_file(file)
      return nil unless File.exist?("#{Rails.configuration.docs_base_path}/#{file}")

      allowed_products.each do |product|
        return file if use_case_product(file).include?(product)
      end
    end

    def use_case_product(file)
      @use_case_product = YAML.safe_load(File.read("#{Rails.configuration.docs_base_path}/#{file}"))['products']

      @use_case_product
    end

    def translatable_tutorial_file(file)
      return nil unless File.exist?("#{Rails.configuration.docs_base_path}/#{file}")

      allowed_tutorial_files.each do |tutorial|
        return file if file == tutorial
      end
    end

    def allowed_products
      @allowed_products ||= [
        'account',
        'application',
        'conversion',
        'numbers',
        'number-insight',
        'sms',
        'tools',
        'verify',
        'voice',
      ].freeze
    end

    def allowed_tutorial_files
      file_names = []
      tutorials_list = []

      TutorialList.all.each do |item|
        allowed_products.each do |product|
          tutorials_list << item if item.products.to_s.include?(product)
        end
      end

      tutorials_list.each do |item|
        item.tutorial.prerequisites&.each do |prereq|
          file_name = "#{prereq.load_file!.root.split('/').last}/en/#{prereq.name}.md"
          file_names << file_name
        end

        item.tutorial.yaml['tasks']&.each do |task|
          file_name = "_tutorials/en/#{task}.md"
          file_names << file_name
        end
      end

      file_names.uniq
    end
  end
end
