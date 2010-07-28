#!/opt/local/bin/ruby
require 'rubygems'
require 'random'
require 'attack'

RAND = Random::RNG.new(Time.now.to_i)
def rand(max)
  RAND.rand(max) + 1
end

BAB = 12
STRENGTH = 5 - 1 # STR drain
MULTIATTACK = 3
MAGICAL = 2
BARD = 3
# POWER_ATTACK_MOD = -1 - (BAB/4.0).floor

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
#   "full attack" (this is a full round attack) [full round attack]
#     what do we call the things that make up a full round attack? [attack group]
#       how to group the claws?
#   "attack" (standard action) [standard attack?]
#   so what do we call the lowest level thing? (ie bite) [attack?]

# feats
#   

character = Character.new({
                            :name         => "Xanion",
                            :bab          => BAB,
                            :strength     => STRENGTH,
                            :active_feats => [],
                          })

teeth = Weapon.new({
                     :name => "Teeth",
                     :die_count => 2,
                     :die => 6,
                     :strength_multiplier => 1.5,
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
                    :strength_multiplier => 0.5,
                  })

tail = Weapon.new({
                    :name => "Tail",
                    :die_count => 1,
                    :die => 8,
                    :strength_multiplier => 1.5,
                  })

electricity = Weapon.new({
                           :name => "Electricity",
                           :die_count => 7,
                           :die => 8,
                         })


standard_action_attack_action =
  Action.new({
               :character => character,
               :name => "standard action attack",
               :acts => [
                         AttackGroup.new({
                                           :character => character,
                                           :name => "Standard action attack",
                                           :attacks => [
                                                        MeleeAttack.new({
                                                                          :character => character,
                                                                          :weapon => teeth,
                                                                          :attack_mod => primary_attack,
                                                                          :damage_mod => primary_damage
                                                                        }),
                                                       ]}),
                        ],
             })

full_action_attack_action = 
  Action.new({
               :character => character,
               :name => "full action attack",
               :acts => [
                         AttackGroup.new({
                                           :character => character,
                                           :name => "Full action attack",
                                           :attacks => [
                                                        MeleeAttack.new(:character => character,
                                                                        :weapon => teeth,
                                                                        :attack_mod => primary_attack,
                                                                        :damage_mod => primary_damage),
                                                        MeleeAttack.new(:character => character,
                                                                        :weapon => claw,
                                                                        :attack_mod => primary_attack,
                                                                        :damage_mod => secondary_damage),
                                                        MeleeAttack.new(:character => character,
                                                                        :weapon => claw,
                                                                        :attack_mod => primary_attack,
                                                                        :damage_mod => secondary_damage),
                                                        MeleeAttack.new(:character => character,
                                                                        :weapon => wing,
                                                                        :attack_mod => secondary_attack,
                                                                        :damage_mod => tertiary_damage),
                                                        MeleeAttack.new(:character => character,
                                                                        :weapon => wing,
                                                                        :attack_mod => secondary_attack,
                                                                        :damage_mod => tertiary_damage),
                                                        MeleeAttack.new(:character => character,
                                                                        :weapon => tail,
                                                                        :attack_mod => secondary_attack,
                                                                        :damage_mod => primary_damage),
                                                       ]})
                         ],
             })

breath_weapon_attack_action = 
  Action.new({
               :character => character,
               :name => "breath weapon attack",
               :acts => [
                         AttackGroup.new(:character => character,
                                         :name => "Breath weapon attack",
                                         :attacks => [
                                                      SupernaturalAttack.new(:character => character,
                                                                             :weapon => electricity,
                                                                             :attack_mod => 0,
                                                                             :damage_mod => 0),
                                                     ])
                        ],
             })


actions = [
           standard_action_attack_action,
           full_action_attack_action,
           breath_weapon_attack_action,
          ]

character.actions = actions              


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
  puts "Damage: " + character.actions.detect {|a| a.name == "breath weapon attack" }.run.flatten.first
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

character.extra_attack_bonus = extra_attack_mod
character.extra_damage_bonus = extra_damage_mod
character.active_feats << :power_attack if is_power



$stdout << "Vital Strike? [y/N]: "
if $stdin.readline.chomp.downcase == "y"
  character.active_feats << :vital_strike
  character.actions.detect {|a| a.name == "standard action attack" }.run
  exit 0
end

# $stdout << "Dragon Form (full round action)? [Y/n]: "
# if $stdin.readline.chomp.downcase == "n"
#   character.actions.detect {|a| a.name == "standard action attack" }.run
# else
  character.actions.detect {|a| a.name == "full action attack" }.run
# end

