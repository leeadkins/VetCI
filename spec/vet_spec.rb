require './lib/vet-ci'

VetCI::Setup.prepare_database

# Testing files should actually go here

describe VetCI::Project do
  it 'creates a new Project' do

  end
end