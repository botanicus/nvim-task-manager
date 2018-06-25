require "task_manager/task"

describe TaskManager::Task do
  subject do
    described_class.parse(line)
  end

  context "basic task" do
    let(:line) { "- Hello world." }

    it "is unstarted" do
      expect(subject).to be_unstarted
    end

    it "has the correct body" do
      expect(subject.body).to eql("Hello world.")
    end

    it "has no tags" do
      expect(subject.tags).to be_empty
    end

    it "formats itself to a string equal to the initial one" do
      expect(subject.to_s).to eql(line)
    end
  end

  context "task with tags" do
    let(:line) { "- Hello world. #hello #world" }

    it "is unstarted" do
      expect(subject).to be_unstarted
    end

    it "has the correct body" do
      expect(subject.body).to eql("Hello world.")
    end

    it "has the correct tags" do
      expect(subject.tags).to eql([:hello, :world])
    end

    it "formats itself to a string equal to the initial one" do
      expect(subject.to_s).to eql(line)
    end
  end

  context "started task" do
    let(:line) { "- [9:20-????] Hello world." }

    it "is started" do
      expect(subject).to be_started
    end

    it "has the correct body" do
      expect(subject.body).to eql("Hello world.")
    end

    it "has no tags" do
      expect(subject.tags).to be_empty
    end

    it "formats itself to a string equal to the initial one" do
      expect(subject.to_s).to eql(line)
    end

    context "finishing started task" do
      it "sets the done_at time" do
        subject.done!
        expect(subject.to_s).to match(/^✓ \[\d+:\d+-\d+:\d+\] Hello world\.$/)
      end
    end
  end

  context "finished task" do
    let(:line) { "✓ Hello world." }

    it "is done" do
      expect(subject).to be_done
    end

    it "has the correct body" do
      expect(subject.body).to eql("Hello world.")
    end

    it "has no tags" do
      expect(subject.tags).to be_empty
    end

    it "formats itself to a string equal to the initial one" do
      expect(subject.to_s).to eql(line)
    end
  end
end
