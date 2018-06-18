require "task_manager/task"

describe TaskManager::Task do
  subject do
    described_class.parse(line)
  end

  context "basic task" do
    let(:line) { "- Hello world." }

    it do
      expect(subject.to_s).to eql(line)
    end
  end

  context "task with tags" do
    let(:line) { "- Hello world. #hello #world" }

    it do
      expect(subject.to_s).to eql(line)
    end
  end

  context "finished task" do
    let(:line) { "✓ Hello world." }

    it do
      expect(subject.to_s).to eql(line)
    end
  end

end
