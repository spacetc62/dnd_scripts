class Attack
  attr_accessor :weapon, :character
  def initialize(options)
    @weapon = options[:weapon]
    @attack_mod = options[:attack_mod]
    @damage_mod = options[:damage_mod]
    @character = options[:character]
  end
  
  def run
    raise "override in specific attack class"
  end

  def roll_damage(damage_modifier)
    is_vital = @character.active_feats.include?(:vital_strike)
    
    rolls = @weapon.damage_roll
    rolls += @weapon.damage_roll if is_vital
    total = rolls.inject(0){ |a,r| a+r } + damage_modifier
    
    "#{total} = (#{@weapon.pretty_print_die_roll} + #{damage_modifier}) = #{rolls.join("/")} + #{damage_modifier}"
  end
end

class Feat
  def initialize(options)
    @character = options[:character]
  end
end

class PowerAttackFeat < Feat
  def applies_to
    [MeleeAttack]
  end
  
  def run(attack)
    pow_damage_mod = 2 + ( (@character.bab / 4.0).floor * 2 )
    pow_damage_mod = ( pow_damage_mod * attack.weapon.strength_multiplier ).floor
    power_attack_mod = -1 - (@character.bab / 4.0).floor
    
    attack.damage_mod = attack.damage_mod + pow_damage_mod
    attack.attack_mod = attack.attack_mod + power_attack_mod
  end
end

class MeleeAttack < Attack
  attr_accessor :damage_mod, :attack_mod, :attack_bonus, :damage_bonus
  
  def run
    roll_attack
  end
  
  def roll_attack
    @damage_mod = @damage_mod + @character.extra_damage_bonus
    @attack_mod = @attack_mod + @character.extra_attack_bonus
    
    @character.active_feats.select do |feat|
      if feat.respond_to? :applies_to and feat.applies_to.include? self.class
        feat.run(self)
      end
    end
    
    attack_roll = rand(20)
    puts ""
    puts "Attacking with #{@weapon.name}"
    puts "Attack: #{attack_roll + @attack_mod} = (1d20+#{@attack_mod}) = #{attack_roll} + #{@attack_mod}   \tDamage: #{roll_damage(@damage_mod)}"
    if attack_roll == 20
      puts "Possible Crit, Rolling Secondary:"
      attack_roll = rand(20)
      puts "Attack: #{attack_roll + @attack_mod} = (1d20+#{@attack_mod}) = #{attack_roll} + #{@attack_mod}   \tDamage: #{roll_damage(@damage_mod)}"
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
  attr_accessor :actions, :active_feats, :extra_attack_bonus, :extra_damage_bonus, :bab
  def initialize(options)
    @name = options[:name]
    @bab = options[:bab]
    @strength = options[:stregth]
    @actions = options[:actions]
    @extra_attack_bonus = options[:extra_attack_bonus]
    @extra_damage_bonus = options[:extra_damage_bonus]
    @active_feats = options[:active_feats]
  end
end

class Weapon
  attr_reader :name, :die, :die_count, :strength_multiplier
  def initialize(options)
    @name = options[:name]
    @die = options[:die]
    @die_count = options[:die_count]
    @strength_multiplier = options[:strength_multiplier] || 1
  end
  
  def pretty_print_die_roll
    "#{@die_count}d#{@die}"
  end
  
  def damage_roll
    (1..@die_count).map{ rand(@die) }
  end
end
