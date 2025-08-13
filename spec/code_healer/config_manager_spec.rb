# frozen_string_literal: true

require "spec_helper"

RSpec.describe CodeHealer::ConfigManager do
  let(:config_manager) { described_class }

  describe ".config" do
    context "when configuration file exists" do
      let(:config_path) { create_temp_config(test_config) }
      let(:test_config) do
        {
          "enabled" => true,
          "allowed_classes" => ["User", "Order"],
          "evolution_strategy" => { "method" => "api" },
          "business_context" => { "enabled" => true }
        }
      end

      before do
        allow(config_manager).to receive(:config_file_path).and_return(config_path)
      end

      after do
        cleanup_temp_files
      end

      it "loads configuration from file" do
        expect(config_manager.config["enabled"]).to be true
        expect(config_manager.config["allowed_classes"]).to eq(["User", "Order"])
      end

      it "merges with default configuration" do
        expect(config_manager.config["evolution_strategy"]["method"]).to eq("api")
        expect(config_manager.config["business_context"]["enabled"]).to be true
      end
    end

    context "when configuration file does not exist" do
      before do
        allow(config_manager).to receive(:config_file_path).and_return("/nonexistent/path")
      end

      it "returns default configuration" do
        expect(config_manager.config["enabled"]).to be false
        expect(config_manager.config["allowed_classes"]).to eq([])
      end
    end
  end

  describe ".enabled?" do
    context "when enabled in config" do
      let(:config_path) { create_temp_config({ "enabled" => true }) }

      before do
        allow(config_manager).to receive(:config_file_path).and_return(config_path)
      end

      after do
        cleanup_temp_files
      end

      it "returns true" do
        expect(config_manager.enabled?).to be true
      end
    end

    context "when disabled in config" do
      let(:config_path) { create_temp_config({ "enabled" => false }) }

      before do
        allow(config_manager).to receive(:config_file_path).and_return(config_path)
      end

      after do
        cleanup_temp_files
      end

      it "returns false" do
        expect(config_manager.enabled?).to be false
      end
    end
  end

  describe ".allowed_classes" do
    let(:config_path) { create_temp_config({ "allowed_classes" => ["User", "Order"] }) }

    before do
      allow(config_manager).to receive(:config_file_path).and_return(config_path)
    end

    after do
      cleanup_temp_files
    end

    it "returns allowed classes from config" do
      expect(config_manager.allowed_classes).to eq(["User", "Order"])
    end
  end

  describe ".evolution_strategy" do
    let(:config_path) { create_temp_config({ "evolution_strategy" => { "method" => "hybrid" } }) }

    before do
      allow(config_manager).to receive(:config_file_path).and_return(config_path)
    end

    after do
      cleanup_temp_files
    end

    it "returns evolution strategy from config" do
      expect(config_manager.evolution_strategy).to eq({ "method" => "hybrid" })
    end
  end

  describe ".claude_code_enabled?" do
    context "when claude_code is enabled" do
      let(:config_path) { create_temp_config({ "claude_code" => { "enabled" => true } }) }

      before do
        allow(config_manager).to receive(:config_file_path).and_return(config_path)
      end

      after do
        cleanup_temp_files
      end

      it "returns true" do
        expect(config_manager.claude_code_enabled?).to be true
      end
    end

    context "when claude_code is disabled" do
      let(:config_path) { create_temp_config({ "claude_code" => { "enabled" => false } }) }

      before do
        allow(config_manager).to receive(:config_file_path).and_return(config_path)
      end

      after do
        cleanup_temp_files
      end

      it "returns false" do
        expect(config_manager.claude_code_enabled?).to be false
      end
    end
  end

  describe ".api_enabled?" do
    context "when api is configured" do
      let(:config_path) { create_temp_config({ "api" => { "provider" => "openai" } }) }

      before do
        allow(config_manager).to receive(:config_file_path).and_return(config_path)
      end

      after do
        cleanup_temp_files
      end

      it "returns true" do
        expect(config_manager.api_enabled?).to be true
      end
    end

    context "when api is not configured" do
      let(:config_path) { create_temp_config({}) }

      before do
        allow(config_manager).to receive(:config_file_path).and_return(config_path)
      end

      after do
        cleanup_temp_files
      end

      it "returns false" do
        expect(config_manager.api_enabled?).to be false
      end
    end
  end

  describe ".business_context_enabled?" do
    context "when business_context is enabled" do
      let(:config_path) { create_temp_config({ "business_context" => { "enabled" => true } }) }

      before do
        allow(config_manager).to receive(:config_file_path).and_return(config_path)
      end

      after do
        cleanup_temp_files
      end

      it "returns true" do
        expect(config_manager.business_context_enabled?).to be true
      end
    end

    context "when business_context is disabled" do
      let(:config_path) { create_temp_config({ "business_context" => { "enabled" => false } }) }

      before do
        allow(config_manager).to receive(:config_file_path).and_return(config_path)
      end

      after do
        cleanup_temp_files
      end

      it "returns false" do
        expect(config_manager.business_context_enabled?).to be false
      end
    end
  end

  describe ".auto_create_pr?" do
    context "when pull_request.auto_create is true" do
      let(:config_path) { create_temp_config({ "pull_request" => { "auto_create" => true } }) }

      before do
        allow(config_manager).to receive(:config_file_path).and_return(config_path)
      end

      after do
        cleanup_temp_files
      end

      it "returns true" do
        expect(config_manager.auto_create_pr?).to be true
      end
    end

    context "when pull_request.enabled is true" do
      let(:config_path) { create_temp_config({ "pull_request" => { "enabled" => true } }) }

      before do
        allow(config_manager).to receive(:config_file_path).and_return(config_path)
      end

      after do
        cleanup_temp_files
      end

      it "returns true" do
        expect(config_manager.auto_create_pr?).to be true
      end
    end

    context "when both are false" do
      let(:config_path) { create_temp_config({ "pull_request" => { "auto_create" => false, "enabled" => false } }) }

      before do
        allow(config_manager).to receive(:config_file_path).and_return(config_path)
      end

      after do
        cleanup_temp_files
      end

      it "returns false" do
        expect(config_manager.auto_create_pr?).to be false
      end
    end
  end
end
