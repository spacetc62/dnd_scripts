class Attack
  def initialize(options)
#     @name = options[:name]
#     @character = options[:character]
    @weapon = options[:weapon]
    @attack_mod = options[:attack_mod]
    @damage_mod = options[:damage_mod]
#     @damage_roll = options[:damage_roll]
    @pow_damage_mod = options[:pow_damage_mod]
    @character = options[:character]
  end
  
  def run
    raise "override in specific attack class"
  end

  def roll_damage(damage_modifier, is_vital = nil)
    is_vital = @character.active_feats.include?(:vital_strike)
    
    rolls = @weapon.damage_roll
    rolls += @weapon.damage_roll if is_vital
    total = rolls.inject(0){ |a,r| a+r } + damage_modifier
    
    #   rolls.join("/") + " -> #{total}"
    "#{total} = (#{@weapon.pretty_print_die_roll} + #{damage_modifier}) = #{rolls.join("/")} + #{damage_modifier}"
  end
end

class MeleeAttack < Attack
  def run
    roll_attack
  end
  
  def roll_attack # (extra_attack_mod, extra_damage_mod, is_power, is_vital)
    extra_attack_mod = @character.attack_bonus
    extra_damage_mod = @character.damage_bonus
    is_power = @character.active_feats.include?(:power_attack)
    is_vital = @character.active_feats.include?(:vital_strike)
    
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

class SupernaturalAttack < Attack
  def run
    roll_damage(0, false)
  end
end

class Action
  attr_accessor :name
  def initialize(options)
    @name = options[:name]
    @acts = options[:acts]
    @character = options[:character]
  end
  
  def run
    @acts.map {|a| a.run }
  end
end

class AttackGroup
  attr_accessor :name, :attacks
  def initialize(options)
    @name = options[:name]
    @attacks = options[:attacks]
    @character = options[:character]
  end
  
  def run
    @attacks.map {|a| a.run }
  end
end

class Character
  attr_accessor :actions, :active_feats, :attack_bonus, :damage_bonus
  def initialize(options)
    @name = options[:name]
    @bab = options[:bab]
    @strength = options[:stregth]
#     @attack_modifiers = options[:attack_modifiers]
    @actions = options[:actions]
    @attack_bonus = options[:attack_bonus]
    @damage_bonus = options[:damage_bonus]
    @active_feats = options[:active_feats]
  end
end

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
