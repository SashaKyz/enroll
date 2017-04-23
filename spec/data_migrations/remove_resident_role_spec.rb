require "rails_helper"
require File.join(Rails.root, "app", "data_migrations", "remove_resident_role")

describe RemoveResidentRole do

  let(:given_task_name) { "remove_resident_role" }
  subject { RemoveResidentRole.new(given_task_name, double(:current_scope => nil)) }

  describe "given a task name" do
    it "has the given task name" do
      expect(subject.name).to eql given_task_name
    end
  end

  describe "remove resident role" do
    let!(:person1) { FactoryGirl.create(:person, :with_resident_role, hbx_id: "12345678")}
    let!(:person2) { FactoryGirl.create(:person, :with_resident_role, hbx_id: "87654321", id:'58e3dc7d50526c33c5000187')}

    it "should delete the resident role for person1 and not for person2" do
      subject.migrate
      #binding.pry
      person1.reload
      person2.reload
      binding.pry
      expect(person1.resident_role).to be(nil)
      expect(person2.resident_role).not_to be_nil
    end
  end
end