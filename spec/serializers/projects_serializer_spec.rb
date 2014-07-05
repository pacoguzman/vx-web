require 'spec_helper'

describe ProjectsSerializer do

  it "should find and use last_builds" do
    p1 = create(:project, name: "p1", id: uuid_for(1))
    p2 = create(:project, name: "p2", id: uuid_for(2), company: p1.company)

    15.times { |n| create :build, number: (n+1), project: p1 }
    30.times { |n| create :build, number: (n+1), project: p2 }

    dont_allow(p1).last_builds
    dont_allow(p2).last_builds

    s = described_class.new([p1,p2])
    lb = s.last_builds
    expect(lb[p1.id].map(&:number)).to eq [15, 14, 13, 12, 11, 10, 9, 8, 7, 6]
    expect(lb[p2.id].map(&:number)).to eq [30, 29, 28, 27, 26, 25, 24, 23, 22, 21]

    expect(s.to_json).to be
  end

end
