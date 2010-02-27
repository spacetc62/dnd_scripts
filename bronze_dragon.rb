#!/opt/local/bin/ruby
require 'rubygems'
require 'random'

RAND = Random::RNG.new(Time.now.to_i)
def rand(max)
  RAND.rand(max) + 1
end

BAB = 10
STRENGTH = 5
MULTIATTACK = 3
MAGICAL = 2
BARD = 2
POWER_ATTACK_MOD = -1 - (BAB/4.0).floor

primary_attack = BAB + STRENGTH + MAGICAL
secondary_attack = BAB - 5 + STRENGTH + MULTIATTACK + MAGICAL
primary_damage = (STRENGTH * 1.5).floor + MAGICAL
secondary_damage = STRENGTH + MAGICAL
tertiary_damage = (STRENGTH * 0.5).floor + MAGICAL



attacks = [
           { 
             :name => "Bite",
             :attack_mod => primary_attack,
             :damage_mod => primary_damage,
             :damage_roll => [6,6],
             :pow_damage_mod => 9
           },
           { 
             :name => "Claw 1",
             :attack_mod => primary_attack,
             :damage_mod => secondary_damage,
             :damage_roll => [8],
             :pow_damage_mod => 6
           },
           { 
             :name => "Claw 2",
             :attack_mod => primary_attack,
             :damage_mod => secondary_damage,
             :damage_roll => [8],
             :pow_damage_mod => 6
           },
           { 
             :name => "Wing 1",
             :attack_mod => secondary_attack,
             :damage_mod => tertiary_damage,
             :damage_roll => [6],
             :pow_damage_mod => 3
           },
           { 
             :name => "Wing 2",
             :attack_mod => secondary_attack,
             :damage_mod => tertiary_damage,
             :damage_roll => [6],
             :pow_damage_mod => 3
           },
           { 
             :name => "Tail",
             :attack_mod => secondary_attack,
             :damage_mod => primary_damage,
             :damage_roll => [8],
             :pow_damage_mod => 6
           },
           {
             :name => "Electrcity",
             :attack_mod => 0,
             :damage_mod => 0,
             :damage_roll => [6,6,6,6,6,6],
             :pow_damage_mod => 0
           }
          ]

def roll_damage(attack, damage_modifier, is_vital)
  rolls = attack[:damage_roll].map{ |die| rand(die) }
  rolls += attack[:damage_roll].map{ |die| rand(die) } if is_vital
  total = rolls.inject(0){ |a,r| a+r } + damage_modifier
  
  rolls.join("/") + " -> #{total}"
end

def roll_attack(attack, extra_attack_mod, extra_damage_mod, is_power, is_vital)
  damage_mod = attack[:damage_mod] + extra_damage_mod + (is_power ? attack[:pow_damage_mod] : 0)
  attack_mod = attack[:attack_mod] + extra_attack_mod + (is_power ? POWER_ATTACK_MOD : 0)
  
  attack_roll = rand(20)
  puts ""
  puts "Attacking with #{attack[:name]}"
  puts "Attack: #{attack_roll} -> #{attack_roll + attack_mod}  \tDamage: #{roll_damage(attack, damage_mod, is_vital)}"
  if attack_roll == 20
    puts "Possible Crit, Rolling Secondary:"
    attack_roll = rand(20)
    puts "Attack: #{attack_roll} -> #{attack_roll + attack_mod}  \tDamage: #{roll_damage(attack, damage_mod, is_vital)}"
  end
end

$stdout << "Breath Weapon? [y/N]: "
if($stdin.readline.chomp.downcase == "y")
  puts "Damage: " + roll_damage(attacks[6], 0, false)
  exit 0
end

$stdout << "Bard Singing? [y/N]: "
bard_mod = $stdin.readline.chomp.downcase == "y" ? BARD : 0

$stdout << "Extra Attack Mod [0]: "
extra_attack_mod = $stdin.readline.chomp.to_i + bard_mod

$stdout << "Extra Damage Mod [0]: "
extra_damage_mod = $stdin.readline.chomp.to_i + bard_mod

$stdout << "Power Attack? [y/N]: "
is_power = $stdin.readline.chomp.downcase == "y"

$stdout << "Vital Strike? [y/N]: "
if $stdin.readline.chomp.downcase == "y"
  roll_attack(attacks[0], extra_attack_mod, extra_damage_mod, is_power, true)
  exit 0
end

$stdout << "Dragon Form? [Y/n]: "
($stdin.readline.chomp.downcase == "n" ? 0..2 : 0..5).each do |i|
  roll_attack(attacks[i], extra_attack_mod, extra_damage_mod, is_power, false)
end
