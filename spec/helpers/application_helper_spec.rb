RSpec.describe ApplicationHelper, type: :helper do
  describe '#link_to_instance' do
    subject { helper.link_to_instance(instance) }

    context 'when instance is ready' do
      let(:instance) { FactoryGirl.build(:ec2_instance, state: 'ready') }

      it 'returns link to instance' do
        is_expected.to match %r{\<a.* href=\"http://#{instance.name}.#{instance.domain}\".*\>http://#{instance.name}.#{instance.domain}\<\/a\>}
        is_expected.to match(/a.* target="_blank".*/)
      end
    end

    context 'when instance is ready' do
      let(:instance) { FactoryGirl.build(:ec2_instance) }

      it 'returns url of instance' do
        is_expected.to eq "http://#{instance.name}.#{instance.domain}"
      end
    end
  end

  describe '#instance_canonical_url' do
    it 'returns url to ec2_instance' do
      instance = FactoryGirl.build(:ec2_instance)
      expect(helper.instance_canonical_url(instance)).to eq "http://#{instance.name}.#{instance.domain}"
    end
  end

  describe 'flash_class' do
    it "returns 'alert alert-info' when flash is :notice" do
      expect(helper.flash_class(:notice)).to eq 'alert alert-info'
    end

    it "returns 'alert alert-success' when flash is :success" do
      expect(helper.flash_class(:success)).to eq 'alert alert-success'
    end

    it "returns 'alert alert-error' when flash is :error" do
      expect(helper.flash_class(:error)).to eq 'alert alert-error'
    end

    it "returns 'alert alert-error' when flash is :alert" do
      expect(helper.flash_class(:alert)).to eq 'alert alert-error'
    end
  end

  describe 'navbar_link_to' do
    subject { helper.navbar_link_to('Home', 'https://pantry.example.com/') }

    it 'generates li with active class and link if current page is selected' do
      is_expected.to eq("<li><a href=\"https://pantry.example.com/\">Home</a></li>")
    end

    it 'generates li with active class and link if current page is selected' do
      allow(helper).to receive(:current_page?).and_return(true)
      is_expected.to eq("<li class=\"active\"><a href=\"https://pantry.example.com/\">Home</a></li>")
    end
  end
end
