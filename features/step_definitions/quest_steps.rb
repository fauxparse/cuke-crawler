Given(/^I am at the entrance to the (\w+ \w+) dungeon$/) do |name|
  @dungeon = CukeCrawler::Dungeon.generate(name)
  @adventurer = CukeCrawler::Adventurer.new(@dungeon)
  @started = true
end

When(/^I go (\w+)$/) do |direction|
  expect(adventurer).to be_able_to_go(direction)
  adventurer.send("go_#{direction}!")
end

Then(/^my quest is complete$/) do
  expect(@started).to eq(true), "You never started at the entrance"
  expect(adventurer).to be_alive, "You are dead"
  expect(adventurer).to be_in_location(dungeon.goal)
end
