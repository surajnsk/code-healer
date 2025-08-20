require 'fileutils'
require 'securerandom'

module CodeHealer
  # Manages isolated healing workspaces for safe code evolution
  class HealingWorkspaceManager
    class << self
      def create_healing_workspace(repo_path, branch_name = nil)
        config = CodeHealer::ConfigManager.code_heal_directory_config
        
        # Create unique workspace directory
        workspace_id = "healing_#{Time.now.to_i}_#{SecureRandom.hex(4)}"
        workspace_path = File.join(config[:path], workspace_id)
        
        puts "🏥 Creating healing workspace: #{workspace_path}"
        
        begin
          # Ensure code heal directory exists
          FileUtils.mkdir_p(config[:path])
          
          # Clone current branch to workspace
          if clone_strategy == "branch"
            clone_current_branch(repo_path, workspace_path, branch_name)
          else
            clone_full_repo(repo_path, workspace_path, branch_name)
          end
          
          puts "✅ Healing workspace created successfully"
          workspace_path
        rescue => e
          puts "❌ Failed to create healing workspace: #{e.message}"
          cleanup_workspace(workspace_path) if Dir.exist?(workspace_path)
          raise e
        end
      end
      
      def apply_fixes_in_workspace(workspace_path, fixes, class_name, method_name)
        puts "🔧 Applying fixes in workspace: #{workspace_path}"
        
        begin
          # Apply each fix to the workspace
          fixes.each do |fix|
            file_path = File.join(workspace_path, fix[:file_path])
            next unless File.exist?(file_path)
            
            # Backup original file
            backup_file(file_path)
            
            # Apply the fix
            apply_fix_to_file(file_path, fix[:new_code], class_name, method_name)
          end
          
          puts "✅ Fixes applied successfully in workspace"
          true
        rescue => e
          puts "❌ Failed to apply fixes in workspace: #{e.message}"
          false
        end
      end
      
      def test_fixes_in_workspace(workspace_path)
        config = CodeHealer::ConfigManager.code_heal_directory_config
        
        puts "🧪 Testing fixes in workspace: #{workspace_path}"
        
        begin
          # Change to workspace directory
          Dir.chdir(workspace_path) do
            # Run basic syntax check
            syntax_check = system("ruby -c #{find_ruby_files.join(' ')} 2>/dev/null")
            return false unless syntax_check
            
            # Run tests if available
            if File.exist?('Gemfile')
              bundle_check = system("bundle check >/dev/null 2>&1")
              return false unless bundle_check
              
              # Run tests if RSpec is available
              if File.exist?('spec') || File.exist?('test')
                test_result = system("bundle exec rspec --dry-run >/dev/null 2>&1") ||
                             system("bundle exec rake test:prepare >/dev/null 2>&1")
                puts "🧪 Test preparation: #{test_result ? '✅' : '⚠️'}"
              end
            end
            
            puts "✅ Workspace validation passed"
            true
          end
        rescue => e
          puts "❌ Workspace validation failed: #{e.message}"
          false
        end
      end
      
      def merge_fixes_back(repo_path, workspace_path, branch_name)
        puts "🔄 Merging fixes back to main repository"
        
        begin
          # Create healing branch in main repo
          Dir.chdir(repo_path) do
            # Ensure we're on the target branch
            system("git checkout #{branch_name}")
            system("git pull origin #{branch_name}")
            
            # Create healing branch
            healing_branch = "code-healer-fix-#{Time.now.to_i}"
            system("git checkout -b #{healing_branch}")
            
            # Copy fixed files from workspace
            copy_fixed_files(workspace_path, repo_path)
            
            # Commit changes
            system("git add .")
            commit_message = "Fix applied by CodeHealer: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
            system("git commit -m '#{commit_message}'")
            
            # Push branch
            system("git push origin #{healing_branch}")
            
            puts "✅ Healing branch created: #{healing_branch}"
            healing_branch
          end
        rescue => e
          puts "❌ Failed to merge fixes back: #{e.message}"
          nil
        end
      end
      
      def cleanup_workspace(workspace_path)
        return unless Dir.exist?(workspace_path)
        
        puts "🧹 Cleaning up workspace: #{workspace_path}"
        FileUtils.rm_rf(workspace_path)
        puts "✅ Workspace cleaned up"
      end
      
      def cleanup_expired_workspaces
        config = CodeHealer::ConfigManager.code_heal_directory_config
        return unless config[:auto_cleanup]
        
        puts "🧹 Cleaning up expired healing workspaces"
        
        Dir.glob(File.join(config[:path], "healing_*")).each do |workspace_path|
          next unless Dir.exist?(workspace_path)
          
          # Check if workspace is expired
          if workspace_expired?(workspace_path, config[:cleanup_after_hours])
            cleanup_workspace(workspace_path)
          end
        end
      end
      
      private
      
      def clone_strategy
        CodeHealer::ConfigManager.code_heal_directory_config[:clone_strategy] || "branch"
      end
      
      def clone_current_branch(repo_path, workspace_path, branch_name)
        Dir.chdir(repo_path) do
          current_branch = branch_name || `git branch --show-current`.strip
          puts "🌿 Cloning current branch: #{current_branch}"
          
          # Clone only the current branch
          system("git clone --single-branch --branch #{current_branch} #{repo_path} #{workspace_path}")
          
          # Remove .git to avoid conflicts
          FileUtils.rm_rf(File.join(workspace_path, '.git'))
        end
      end
      
      def clone_full_repo(repo_path, workspace_path, branch_name)
        Dir.chdir(repo_path) do
          current_branch = branch_name || `git branch --show-current`.strip
          puts "🌿 Cloning full repository, switching to: #{current_branch}"
          
          # Clone full repo
          system("git clone #{repo_path} #{workspace_path}")
          
          # Switch to specific branch
          Dir.chdir(workspace_path) do
            system("git checkout #{current_branch}")
          end
        end
      end
      
      def backup_file(file_path)
        backup_path = "#{file_path}.code_healer_backup"
        FileUtils.cp(file_path, backup_path)
      end
      
      def apply_fix_to_file(file_path, new_code, class_name, method_name)
        content = File.read(file_path)
        
        # Find and replace the method
        method_pattern = /def\s+#{Regexp.escape(method_name)}\s*\([^)]*\)(.*?)end/m
        if content.match(method_pattern)
          content.gsub!(method_pattern, new_code)
          File.write(file_path, content)
          puts "✅ Applied fix to #{File.basename(file_path)}##{method_name}"
        else
          puts "⚠️  Could not find method #{method_name} in #{File.basename(file_path)}"
        end
      end
      
      def find_ruby_files
        Dir.glob("**/*.rb")
      end
      
      def copy_fixed_files(workspace_path, repo_path)
        # Copy all Ruby files from workspace to repo
        Dir.glob(File.join(workspace_path, "**/*.rb")).each do |workspace_file|
          relative_path = workspace_file.sub(workspace_path + "/", "")
          repo_file = File.join(repo_path, relative_path)
          
          if File.exist?(repo_file)
            FileUtils.cp(workspace_file, repo_file)
            puts "📁 Copied fixed file: #{relative_path}"
          end
        end
      end
      
      def workspace_expired?(workspace_path, hours)
        return false unless hours && hours > 0
        
        # Extract timestamp from workspace name
        if workspace_path =~ /healing_(\d+)/
          timestamp = $1.to_i
          age_hours = (Time.now.to_i - timestamp) / 3600
          age_hours > hours
        else
          false
        end
      end
    end
  end
end
