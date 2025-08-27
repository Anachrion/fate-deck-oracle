# frozen_string_literal: true

namespace :assets do
  desc 'Build Tailwind CSS and precompile assets'
  task build_all: :environment do
    puts 'Building Tailwind CSS...'
    system('bundle exec rails tailwindcss:build')

    puts 'Precompiling assets...'
    system('bundle exec rails assets:precompile')

    puts 'Assets build complete!'
  end

  desc 'Ensure Tailwind CSS is available'
  task ensure_tailwind: :environment do
    tailwind_path = Rails.root.join('app', 'assets', 'builds', 'tailwind.css')
    public_tailwind_path = Rails.root.join('public', 'assets', 'tailwind.css')

    if File.exist?(tailwind_path)
      FileUtils.mkdir_p(File.dirname(public_tailwind_path))
      FileUtils.cp(tailwind_path, public_tailwind_path)
      puts 'Tailwind CSS copied to public/assets/'
    else
      puts "Warning: Tailwind CSS not found at #{tailwind_path}"
    end
  end
end
