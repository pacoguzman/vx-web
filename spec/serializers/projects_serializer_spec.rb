require 'spec_helper'

describe ProjectsSerializer do
  it "should find last_builds" do
    p1 = create(:project, name: "p1", id: uuid_for(1))
    p2 = create(:project, name: "p2", id: uuid_for(2), company: p1.company)

    b1_2 = create(:build, project: p1, number: 2)
    create(:build, project: p1, number: 1)

    b2_2 = create(:build, project: p2, number: 2)
    create(:build, project: p2, number: 1)

    dont_allow(p1).last_build
    dont_allow(p2).last_build

    s = described_class.new([p1,p2])
    expect(s.last_builds).to eq [b1_2, b2_2]
    expect(s.to_json).to be
  end
end
