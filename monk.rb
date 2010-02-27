#!/opt/local/bin/ruby
require 'rubygems'
require 'random'

RAND = Random::RNG.new(Time.now.to_i)
def rand(max)
  RAND.rand(max) + 1
end

STRENGTH = 7
BARD = 3
POW_DAMAGE = 6
POW_ATTACK = -3
ATTACK_BONUS = 8 #feats, etc...

EXTRA = [9]
FLURRY = [9,9,4,4,-1]
REGULAR = [8,3]

def roll_damage(modifier)
  d1 = rand(8)
  d2 = rand(8)
  
  "#{d1}/#{d2}/#{d1 + d2 + STRENGTH + modifier}"
end

def roll_attack(attack_modifier, damage_modifier)
  attack_roll = rand(20)
  puts ""
  puts "Attack: #{attack_roll}/#{attack_roll + ATTACK_BONUS + attack_modifier},\tDamage: #{roll_damage(damage_modifier)}"
  if attack_roll == 20
    puts "Possible Crit, Rolling Secondary:"
    attack_roll = rand(20)
    puts "Attack: #{attack_roll}/#{attack_roll + ATTACK_BONUS + attack_modifier},\tDamage: #{roll_damage(damage_modifier)}"
  end
end

def roll_and_print_attack(attack_modifier, damage_modifier)
  
end

$stdout << "Bard Singing? [Y/n]: "
bard_modifier = $stdin.readline.chomp.downcase == "n" ? 0 : 3

$stdout << "Power Attack? [y/N]: "
power_attack = 0
power_damage = 0
if $stdin.readline.chomp.downcase == "y"
  power_attack = POW_ATTACK
  power_damage = POW_DAMAGE
end

$stdout << "Flurry? [Y/n]: "
flurry = !($stdin.readline.chomp.downcase == "n")

attacks = REGULAR
if flurry
  attacks = FLURRY
  $stdout << "Extra Blow? [y/N]: "
  attacks += EXTRA if $stdin.readline.chomp.downcase == "y"
end

attacks.each do |attack|
  roll_attack(attack + bard_modifier + power_attack, bard_modifier + power_damage)
end


  
  
  










