#!/bin/ruby
# coding: utf-8
class Card
  X_MAX=9
  Y_MAX=9
  def initialize
    @data = Array.new
    0.upto(Y_MAX - 1) do |y_val| 
      line=Array.new
      0.upto(X_MAX - 1) do |x_val|
        line.push 0
      end
      @data.push line
    end
  end

  def set_from_array card
    @data = Array.new
    0.upto(Y_MAX - 1) do |y_val| 
      line=Array.new
      0.upto(X_MAX - 1) do |x_val|
        tmp =card[y_val][x_val].dup
        line.push (tmp=="_")?(0):(tmp.to_i)
      end
      @data.push line
    end
  end
  
  def get(arg_x:, arg_y:)
    @data[ arg_y ][ arg_x ].dup
  end
  
  def set(arg_x:, arg_y:, arg_val:)
    @data[arg_y][arg_x] = arg_val.dup
  end

  def get_line(arg_y:)
    return @data[arg_y].dup
  end

  def get_tate(arg_x:)
    ret = Array.new
    0.upto(Y_MAX - 1 ) do | y |
      ret.push get arg_x: arg_x, arg_y: y
    end
    return ret
  end

  def get_block_to_array(arg_x:,arg_y:)
    block_x = arg_x / 3
    block_y = arg_y / 3
    ret=Array.new
    0.upto(2) do | step_y |
      0.upto(2) do | step_x |
        ret.push get( arg_x: (block_x * 3 + step_x),
                      arg_y: (block_y * 3 + step_y))
      end
    end
    return ret 
  end

  def get_can_val arg_x:, arg_y:
    return nil unless get(arg_x: arg_x, arg_y: arg_y) == 0
    data  = get_line arg_y: arg_y
    data.concat( get_tate arg_x: arg_x)
    data.concat( get_block_to_array( arg_x: arg_x ,
                                     arg_y: arg_y ) )
    data.flatten!
    data.sort!
    data.uniq!
    data.delete(0)
    ret = Array.new
    1.upto(9) do |val|
      next if  data.index val
      ret.push  val
    end
    return ret
  end

  def disp
    0.upto(Card::Y_MAX - 1) do |y_val| 
      puts "---------------------------------------" if y_val % 3 == 0
      line = ""
      0.upto(Card::X_MAX - 1) do |x_val|
        line += "|" if x_val % 3 == 0
        card =  get(arg_x: x_val, arg_y: y_val)
        card ="_" if card == 0
        line +="#{card} "
      end
      puts "#{line}"
    end
  end

  def get_undef_array
    ret=Array.new
    0.upto(Card::Y_MAX - 1) do |y_val| 
      0.upto(Card::X_MAX - 1) do |x_val|
        card = get(arg_x: x_val, arg_y: y_val)
        ret.push( {arg_x: x_val, arg_y: y_val} )if card == 0
      end
    end
    return ret
  end
  
  def check_1to9( ar:)
    tmp=ar.delete_if{|x| x==0}
    uniqd_co  = tmp.sort.uniq.count
    normal_co =  tmp.count
    return true if uniqd_co ==normal_co
    return false
  end
  
  def check_err
    ret=Array.new
    0.upto(Card::Y_MAX - 1) do |y_val| 
      line = get_line(arg_y: y_val)
      unless  check_1to9(ar:  line )
        puts "#{y_val} #{line} line err"
        return true
      end
    end
    0.upto(Card::X_MAX - 1) do |x_val|
      tate = get_tate(arg_x: x_val)
      unless  check_1to9(ar: tate )
        puts "#{x_val} #{tate} tate err"
        return true
      end
    end
    0.step(Card::Y_MAX-1,3 ) do |y_val| 
      0.step(Card::X_MAX-1,3) do |x_val|
        block = get_block_to_array(arg_x: x_val, arg_y: y_val)
        unless check_1to9(ar: block)
          puts "#{x_val} #{y_val } #{block} block err"
          return true
        end
      end
    end
    return false
  end

  def check_comp
    0.upto(Card::Y_MAX - 1) do |y_val| 
      0.upto(Card::X_MAX - 1) do |x_val|
        val = get(arg_x: x_val,arg_y: y_val)
        return false if val == nil or val == 0
      end
    end
    return true
  end
end

class Caler
  def initialize
  end
  
  def init arg_card
    @card = arg_card
    @can = Card.new
    0.upto(Card::Y_MAX - 1) do |y_val| 
      0.upto(Card::X_MAX - 1) do |x_val|
        @can.set(arg_x: x_val,arg_y: y_val,
                 arg_val: @card.get_can_val(arg_x: x_val,arg_y:y_val))
      end
    end
  end

  def calk( arg_x: , arg_y: ,debug_flg: false)
    can = @can.get(arg_x: arg_x, arg_y: arg_y)
    puts "debug:can #{arg_x}/#{arg_y}:#{can}" if debug_flg
    return nil if can == nil
    return can[0] if can.size == 1

    line = @can.get_line(arg_y: arg_y)
    tate = @can.get_tate(arg_x: arg_x)
    block =@can.get_block_to_array(arg_x: arg_x,arg_y: arg_y)

    puts "debug:line #{line}" if debug_flg
    puts "debug:tate #{tate}" if debug_flg
    puts "debug:block #{block.flatten}" if debug_flg
    can.each do |val|
      if block.flatten.count(val) == 1
        puts "hits block #{val}" if debug_flg
        return val
      end
      if  line.flatten.count(val) == 1
        puts "hits line #{val}" if debug_flg
        return val
      end
      if  tate.flatten.count(val) == 1
        puts "hits tate #{val}" if debug_flg
        return val
      end
    end
    return nil
  end
  
  def disp arg_num:
    puts "number #{arg_num}"
    0.upto(Card::Y_MAX - 1) do |y_val| 
      puts "---------------------------------------" if y_val % 3 == 0
      line = ""
      0.upto(Card::X_MAX - 1) do |x_val|
        card =  @card.get(arg_x: x_val,arg_y: y_val)
        line += "|" if x_val % 3 == 0
        line +="#{card}"
        can  = @can.get(arg_x: x_val,arg_y: y_val)
        if can != nil && can.count(arg_num) != 0
          line +="O "
        else
          line +="X "
        end
      end
      puts "#{line}"
    end
  end
  def disp_unfix_count
    puts "unfix count"
    0.upto(Card::Y_MAX - 1) do |y_val| 
      puts "---------------------------------------" if y_val % 3 == 0
      line = ""
      0.upto(Card::X_MAX - 1) do |x_val|
        card =  @card.get(arg_x: x_val, arg_y: y_val)
        card = (card == 0)?("_"):(card)
        line += "|" if x_val % 3 == 0
        line +="#{card}"
        can  = @can.get(arg_x: x_val, arg_y: y_val)
        if can == nil
          line += "  "
        else
          line +="#{can.size} "
        end
      end
      puts "#{line}"
    end
  end

  def get_undef_array_with_val
    ret=Array.new
    0.upto(Card::Y_MAX - 1) do |y_val| 
      0.upto(Card::X_MAX - 1) do |x_val|
        can= @can.get(arg_x: x_val, arg_y: y_val)
        ret.push(  {arg_x: x_val, arg_y: y_val,val: can}) unless can == nil
      end
    end
    return ret
  end
end

data_1=[
# https://ja.wikipedia.org/wiki/%E6%95%B0%E7%8B%AC
#      0 1 2  3 4 5  6 7 8
  %w(  5 3 _  _ 7 _  _ _ _ ) , 
  %w(  6 _ _  1 9 5  _ _ _ ) ,
  %w(  _ 9 8  _ _ _  _ 6 _ ) ,

  %w(  8 _ _  _ 6 _  _ _ 3 ) ,
  %w(  4 _ _  8 _ 3  _ _ 1 ) ,
  %w(  7 _ _  _ 2 _  _ _ 6 ) ,

  %w(  _ 6 _  _ _ _  2 8 _ ) ,
  %w(  _ _ _  4 1 9  _ _ 5 ) ,
  %w(  _ _ _  _ 8 _  _ 7 9 ) 
     ]

card=Card.new
card.set_from_array data_1
if card.check_err
  puts "bad data"
  card.disp
  exit 1
end

def calc_all cal_arg,card,debug_flg=false
  co_res=0
  0.upto(Card::Y_MAX - 1) do |y_val| 
    0.upto(Card::X_MAX - 1) do |x_val|
      res = cal_arg.calk arg_x: x_val,arg_y: y_val,debug_flg: debug_flg
      unless res == nil
        co_res += 1
        puts "hit #{x_val}/#{y_val}:#{res} "
        card.set(arg_x: x_val,arg_y: y_val,
                 arg_val: res)
      end
    end
  end
  return co_res
end

0.upto(10) do |val|
  puts "start No #{val}"
  card.disp

  cal=Caler.new
  cal.init card
  co = calc_all cal,card,false
  puts "end No #{val} hit #{co}"
  card.disp
  if ( card.check_err == true )
       puts "maby bug?"
       exit 1
  end
  if ( card.check_comp == true )
       puts "complete!"
       exit 1
  end
  break if co == 0 
end

cal=Caler.new
cal.init card
cal.disp_unfix_count
undef_ar =  cal.get_undef_array_with_val

x=undef_ar[0][:arg_x]
y=undef_ar[0][:arg_y]
val=undef_ar[0][:val]

puts
puts "if..set #{x}/#{y}:#{val} "

val.each do | if_val|
  tmp_card= Marshal.load(Marshal.dump(card))
  tmp_card.set(arg_x: x,arg_y: y, arg_val: if_val)
  
  0.upto(50) do |val|
    puts "step #{val}/set #{x}/#{y}:if_val #{if_val}  start"
    tmp_card.disp
    cal=Caler.new
    cal.init tmp_card
    co = calc_all cal,tmp_card,false
    puts "step #{val}/set #{x}/#{y}:#{if_val} hit#{co}  end"
    tmp_card.disp
    
    if ( tmp_card.check_err == true )
      puts "miss val #{if_val}"
      break
    end
    if ( tmp_card.check_comp == true )
      puts "complete!"
      exit 1
    end
    break if co == 0 
  end
end
  
puts "hmm.. may be bug??"
