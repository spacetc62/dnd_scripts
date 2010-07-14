class Attack
  def initialize(options)
#     @name = options[:name]
#     @character = options[:character]
    @weapon = options[:weapon]
    @attack_mod = options[:attack_mod]
    @damage_mod = options[:damage_mod]
#     @damage_roll = options[:damage_roll]
    @pow_damage_mod = options[:pow_damage_mod]
  end

  def roll_damage(damage_modifier, is_vital)
    rolls = @weapon.damage_roll
    rolls += @weapon.damage_roll if is_vital
    total = rolls.inject(0){ |a,r| a+r } + damage_modifier
    
    #   rolls.join("/") + " -> #{total}"
    "#{total} = (#{@weapon.pretty_print_die_roll} + #{damage_modifier}) = #{rolls.join("/")} + #{damage_modifier}"
  end
  
  def roll_attack(extra_attack_mod, extra_damage_mod, is_power, is_vital)
    
    damage_mod = @damage_mod + extra_damage_mod + (is_power ? @pow_damage_mod : 0)
    attack_mod = @attack_mod + extra_attack_mod + (is_power ? POWER_ATTACK_MOD : 0)
    
    attack_roll = rand(20)
    puts ""
    puts "Attacking with #{@weapon.name}"
    #   puts "Attack: #{attack_roll} -> #{attack_roll + attack_mod}  \tDamage: #{roll_damage(attack, damage_mod, is_vital)}"
    puts "Attack: #{attack_roll + attack_mod} = (1d20+#{attack_mod}) = #{attack_roll} + #{attack_mod}   \tDamage: #{roll_damage(damage_mod, is_vital)}"
    if attack_roll == 20
      puts "Possible Crit, Rolling Secondary:"
      attack_roll = rand(20)
      #     puts "Attack: #{attack_roll} -> #{attack_roll + attack_mod}  \tDamage: #{roll_damage(attack, damage_mod, is_vital)}"
      puts "Attack: #{attack_roll + attack_mod} = (1d20+#{attack_mod}) = #{attack_roll} + #{attack_mod}   \tDamage: #{roll_damage(damage_mod, is_vital)}"
    end
    
  end
end

# class Character
#   def initialize(options)
#     @bab = options[:bab]
#     @strength = options[:stregth]
# #     @attack_modifiers = options[:attack_modifiers]
#     @attacks = options[:attacks]
#   end
# end

class Weapon
  attr_reader :name, :die, :die_count
  def initialize(options)
    @name = options[:name]
    @die = options[:die]
    @die_count = options[:die_count]
#     @damage_modifier = options
  end
  
  def pretty_print_die_roll
    "#{@die_count}d#{@die}"
  end
  
  def damage_roll
    (1..@die_count).map{ rand(@die) }
  end
end
