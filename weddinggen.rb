#!/usr/bin/env ruby

require "csvio"

if __FILE__ == $0

  if(ARGV.size < 1)
     puts "Usage: weddinggen.rb infilename"
     exit
  end
  
  reader = CsvIO.new(ARGV[0], /\t/)

  @namelist = Array.new
  
  reader.getData.each do |datum|
    
    # --- Assumes that CSV file has a 'Guest List Full Names' column defined
    #     Clean up & and + to become and for next step
    names = datum['Guest List Full Names'].sub('&', 'and').sub('+', 'and')
     
    # --- Split on the and if it exists (there's two people in a single row of data)
    andsplit = names.split(' and ', 2)
    firstperson = andsplit[0].nil? ? nil : andsplit[0].strip
    secondperson = andsplit[1].nil? ? nil : andsplit[1].strip
    lastname = nil
    
    # --- If there's a second person, then grab their last name in case
    #     the first person doesn't have their last name written
    if !secondperson.nil?
      lastname = secondperson.split(' ')[-1].strip  # get the last name in the list (will fail for names like San Marcos)
      @namelist << secondperson if secondperson != "guest"
    end
    
    # --- Assume that first person doesn't have last name specified if no
    #     spaces found in their parsed name (before an and)
    if !firstperson.include?(' ')
      firstperson = firstperson + ' ' + lastname
    end
    
    @namelist << firstperson if !firstperson.nil? && firstperson != "guest"
    
  end
  
  puts "======= OUTPUT ========"
  @namelist.each do |name|
    puts name + "\n"
  end

end # __FILE__ == $0