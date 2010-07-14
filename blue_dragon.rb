#!/opt/local/bin/ruby
require 'rubygems'
require 'random'
require 'attack'

RAND = Random::RNG.new(Time.now.to_i)
def rand(max)
  RAND.rand(max) + 1
end

BAB = 12
STRENGTH = 5
MULTIATTACK = 3
MAGICAL = 2
BARD = 3
POWER_ATTACK_MOD = -1 - (BAB/4.0).floor

LEVEL_DAMAGE_MODIFIER = 5

primary_attack = BAB + STRENGTH + MAGICAL
secondary_attack = BAB - 5 + STRENGTH + MULTIATTACK + MAGICAL
primary_damage = (STRENGTH * 1.5).floor + MAGICAL + LEVEL_DAMAGE_MODIFIER
secondary_damage = STRENGTH + MAGICAL + LEVEL_DAMAGE_MODIFIER
tertiary_damage = (STRENGTH * 0.5).floor + MAGICAL + LEVEL_DAMAGE_MODIFIER


# what could an attack consist of?
#  weapon
#  XdY+Z
#  sneak attack?
#  power attack
#  vital strike

# things that can affect stuff (equipment, feats, etc.) should subscribe to it
#  amulet of mighty fists subscribes to my character's attacks with a hook for the appropriate modification
#  the hook can either be a number to modify by (amulet of mighty fists)
#  or a lambda that'll be passed the object it subscribed to (power attack: bad example because it's only a round, maybe we just pass this into the attack instance)
#  what about things that can be turned on and off, like power attack?  how do we want to store that?
#   maybe they subscribe, but things can be active or inactive as well and only the active things affect stuff?


# attack bonus (melee) = BAB + STR modifier + size modifier (-1 for large)   pg179
# damage (melee) = STR modifier + (1.5 mult for primary natural, 0.5 for 'secondary' [tertiary for me])
#   primary is determined by only having one attack of that type (claws don't work)

# how to group attacks?
#   claws are one group
#   wings are one group

# naming?
#   "full attack" (this is a full round attack)
#     what do we call the things that make up a full round attack?
#       how to group the claws?
#   "attack" (standard action)
#   so what do we call the lowest level thing? (ie bite)

teeth = Weapon.new({
                     :name => "Teeth",
                     :die_count => 2,
                     :die => 6,
                   })

claw = Weapon.new({
                    :name => "Claw",
                    :die_count => 1,
                    :die => 8,
                  })

wing = Weapon.new({
                    :name => "Wing",
                    :die_count => 1,
                    :die => 6,
                  })

tail = Weapon.new({
                    :name => "Tail",
                    :die_count => 1,
                    :die => 8,
                  })

electricity = Weapon.new({
                           :name => "Electricity",
                           :die_count => 7,
                           :die => 8,
                         })


standard_action_attack_group =
  AttackGroup.new(:name => "Standard action attack",
                  :attacks => [
                               Attack.new(:weapon => teeth,
                                          :attack_mod => primary_attack,
                                          :damage_mod => primary_damage),
                               Attack.new(:weapon => claw,
                                          :attack_mod => primary_attack,
                                          :damage_mod => secondary_damage),
                               Attack.new(:weapon => claw,
                                          :attack_mod => primary_attack,
                                          :damage_mod => secondary_damage),
                              ])

full_action_attack_group = 
  AttackGroup.new(:name => "Full action attack",
                  :attacks => standard_action_attack_group.attacks + [
                                                              Attack.new(:weapon => wing,
                                                                         :attack_mod => secondary_attack,
                                                                         :damage_mod => tertiary_damage),
                                                              Attack.new(:weapon => wing,
                                                                         :attack_mod => secondary_attack,
                                                                         :damage_mod => tertiary_damage),
                                                              Attack.new(:weapon => tail,
                                                                         :attack_mod => secondary_attack,
                                                                         :damage_mod => primary_damage),
                                                             ])

breath_weapon_attack_group = 
  AttackGroup.new(:name => "Breath weapon attack",
                  :attacks => [
                               Attack.new(:weapon => electricity,
                                          :attack_mod => 0,
                                          :damage_mod => 0),
                              ])


attack_groups = [
                 standard_action_attack_group,
                 full_action_attack_group,
                 breath_weapon_attack_group,
                ]

              


def pretty_print_die_roll(die_array)
  hash = die_array.inject({}) do |hash, die|
    hash[die] ||= 0
    hash[die] += 1
    hash
  end
  hash.to_a.sort.map { |pair| pair.reverse.join("d") }.join(" + ")
end

# puts pretty_print_die_roll([6, 6, 6, 8, 8])
# exit 0

$stdout << "Breath Weapon? [y/N]: "
if($stdin.readline.chomp.downcase == "y")
#   puts "Damage: " + roll_damage(attacks[6], 0, false)
#   puts "Damage: " + new_attacks[6].roll_damage(0, false)
  puts "Damage: " + breath_weapon_attack_group.attacks.first.roll_damage(0, false)
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
  standard_action_attack_group.attacks.first.roll_attack(extra_attack_mod, extra_damage_mod, is_power, true)
  exit 0
end

$stdout << "Dragon Form (full round action)? [Y/n]: "
if $stdin.readline.chomp.downcase == "n"
  standard_action_attack_group.attacks.each do |attack|
    attack.roll_attack(extra_attack_mod, extra_damage_mod, is_power, false)
  end
else
  full_action_attack_group.attacks.each do |attack|
    attack.roll_attack(extra_attack_mod, extra_damage_mod, is_power, false)
  end
end

