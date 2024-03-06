namespace :papyrus do
  namespace :tailwindcss do
    desc "Configure your Tailwind CSS"
    task :config do
      Rails::Generators.invoke("papyrus:tailwind_config", ["--force"])
    end
  end
end

if Rake::Task.task_defined?("tailwindcss:build")
  Rake::Task["tailwindcss:build"].enhance(["papyrus:tailwindcss:config"])
  Rake::Task["tailwindcss:watch"].enhance(["papyrus:tailwindcss:config"])
end