require 'faker'
require 'factory_bot'
require 'sqlite3'
require 'distribution'
require 'time'

db = SQLite3::Database.new "beerdb.sqlite3"

def beta_val_int(max, a, b)
  (Distribution::Beta.cdf(rand(), a, b)*max).ceil.to_i
end

def gen_order_date()
  month = beta_val_int(12, 6, 6)
  if rand(2)
    month = beta_val_int(12, 15, 6)
  end
  
  day = 1
  if month == 2
    day = rand(29) + 1
  elsif [1,3,5,7,8,10,12].include? month
    day = rand(31) + 1
  elsif [4,6,9,11].include? month 
    day = rand(30) + 1
  end

  begin
    day = DateTime.new(2020, month, day, rand(24), rand(60), rand(60), "00:00")
  rescue Date::Error => e
    puts e.message
    puts "month: #{month}, day: #{day}"
  end

  #puts "Dia original: #{day.strftime("%b %a")}"
  if rand(2) and !['Fri', 'Sat', 'Sun'].include? day.strftime("%a")
    daynum = day.strftime("%u").to_i
    rand_weekend = 4 + (rand(3) + 1)
    day += rand_weekend - daynum
    #puts "Dia resultante (con cambio): #{day.strftime("%a")}; daynum: #{daynum}; delta: #{rand_weekend - daynum}; rand_weekend: #{rand_weekend}"
  else
    #puts "Dia resultante (sin cambio): #{day.strftime("%a")}"
  end

  day
end

# Create the database
begin
  numcountries = 50
  numcustomers = 2000
  numbreweries = 40
  numbrands = 500
  numbeers = 2000
  numorders = 100000

  # Fake countries
  print "Generating countries..."
  numcountries.times {
    db.execute("INSERT INTO countries (name) 
      VALUES (?)", [Faker::Address.unique.country]) 
  }
  puts "done"

  # Fake customers
  print "Generating customers..."
  numcustomers.times {
    db.execute("INSERT INTO customers (first_name, last_name, email, dni, country_id)
      VALUES (?, ?, ?, ?, ?)", 
      [Faker::Name.name, Faker::Name.last_name,
      Faker::Internet.email,
      Faker::Code.npi,
      rand(50) + 1])
  }
  puts "done"

  # Fake breweries
  print "Generating breweries..."
  numbreweries.times {
    db.execute("INSERT INTO breweries (name, estdate)
      VALUES(?, ?)", [Faker::Company.unique.name, 
                      Time.at(rand*Time.now.to_f).to_s])
  }
  puts "done"

  # Fake brands
  print "Generating brands..."
  numbrands.times {
    db.execute("INSERT INTO brands (name, brewery_id)
      VALUES(?, ?)", [Faker::Beer.brand, 
                      rand(40) + 1])
  }
  puts "done"

  # Fake beers
  print "Generating beers..."
  numbeers.times {
    db.execute("INSERT INTO beers (brand_id, name, flavor, alcvol, contents, unit_price)
      VALUES(?, ?, ?, ?, ?, ?)", [rand(500) + 1,
                      Faker::Beer.name,
                      Faker::Beer.style,
                      ((rand()*13)*100.0).to_i/100.0,
                      [330, 500, 750, 1000, 5000].sample,
                      [500, 1000, 1200, 1500, 1800, 2000, 2800, 8000].sample + [20,30,40,50,80,90].sample])
  }
  puts "done"

  # Generate orders
  print "Generating orders..."
  numorders.times do |i|
    begin
      db.execute("INSERT INTO orders (date, customer_id) 
        VALUES(?, ?)",
        [gen_order_date().to_s,
        rand(2000) + 1])
    rescue SQLite3::SQLException => e
      puts e.message
      puts e.backtrace
    end
  end
  puts "done"

  print "Adding beers to orders..."
  beers = (1..2000).to_a
  progress = 0
  numorders.times do |i|
    order_id = i + 1
    num_beer_types = [1, beta_val_int(5, 6, 1)].max

    beer_ids = []

    # Pick unique beer ids for order
    num_beer_types.times do |j|
      beer_ids << (beers - beer_ids).sample
    end
    
    order_cost = 0
    
    # Per each beer chosen
    beer_ids.each do |beer_id|
      # Simulate amount
      beer_amount = [1, 2 ** beta_val_int(8, 6, 1)].max
      
      # Get the unit price of the beer
      beer_unit_price = db.get_first_value("SELECT unit_price FROM beers where id = #{beer_id}").to_i
      order_cost += beer_unit_price * beer_amount

      db.execute("INSERT INTO beers_orders (beer_id, order_id, amount) 
      VALUES(?, ?, ?)", [
        beer_id, order_id, beer_amount
      ])
    end

    db.execute("UPDATE orders SET total = #{order_cost} where id = #{order_id}")

    if i % (numorders / 4) == 0
      progress += 25
      print("#{progress}%...")
    end
  end

  if progress != 100
    puts "100%...done"
  else
    puts "done"
  end
rescue Faker::UniqueGenerator::RetryLimitExceeded => e
  puts e.message
end
