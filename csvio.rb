#!/usr/bin/env ruby

# History:
#    - 08 Jul 2011    mikesp      Initial version
#
#
# ============================================================================

# Base class for coverting Comma-delimited text files with
# database-like operations.
class CsvIO
  
   @@splitchar = /,/
   
   # --- Read in CSV-style datafile and set up @columnNames and @data
   def initialize(infilename, delimiter=nil)
 
 	   @@splitchar = delimiter if delimiter
 	   
       # --- Mapping from filename's column ID to the name of the column
       #     Note: an array is used since ALL columns will be read in
       @columnNames = nil

       # --- List of all data read in from csv file. Indexes correspond
       #     to row numbers. Entries in data are hashes of the form:
       #     {colname => value}, where colname is a column name found in
       #     @columnNames.       
       @data = Array.new
            
       # --- Read in all the header names and associate them w/ the appropriate index
       fi = File.new infilename
       @columnNames = fi.readline.strip.split(@@splitchar).collect! { |x| x.strip }
        
       # --- Now, build rows of data, a hash of "Label => Data"
       linecount = 2 # first line is for columns 
       while !fi.eof? do
       	 items = fi.readline.strip.split(@@splitchar,-1) # The -1 ensures that strings ending with ,,,, will all get parsed as nils.
         puts linecount if linecount % 100000 == 0
         puts items if linecount % 100000 == 0
         
         if @columnNames.length != items.length
           puts "Wrong number of entries in file: " + infilename + "   Skipping line: #{linecount}"
           items.each_with_index { |item, idx| puts idx.to_s + " [ " + @columnNames[idx].to_s + " ] = " + item.to_s + "\n" } 
         else
           lineofdata = Hash.new
           items.each_with_index do |datum, index|
             lineofdata[@columnNames[index]] = datum if @columnNames[index] 
           end           
           @data << lineofdata
         end
         
         linecount = linecount + 1
       end
       
       fi.close
   end # def initialize
   
   def getData
     return @data
   end   
   
   def getColumns
     return @columnNames
   end
   
   def setData(data)
     @data = data
   end
   
   def setColumns
     @columnNames = columns
   end
   
   # Writes out all columns and all data associated with columns
   # to filename, delimited by delimchar.
   #
   # Override this function if you wish to write out custom
   # columns / data.
  def writeDelimitedData(filename, delimchar, indata)
      fi = File.new(filename, "w+")
      colmaplen = @columnNames.length

      delim = nil
      if (delimchar.class == Regexp)
        delim = delimchar.source
      else
        delim = delimchar
      end
     
      # --- Header
      @columnNames.each_with_index do |colname, idx|
        fi.print("#{colname}")        
        fi.print(delim) if idx < colmaplen-1
      end
      
      fi.print("\n")
      
      # --- Data
      indata.each do |datum|
        @columnNames.each_with_index do |colname, colid|
          fi.print("#{datum[colname]}")
          fi.print(delim) if colid < colmaplen-1
        end
        fi.print("\n")
      end
                 
     fi.close      
   end
   
   
  # Writes out all columns and all data associated with columns
  # to stdout, delimited by delimchar.
  #
  # Override this function if you wish to write out custom
  # columns / data.
  def stdoutDelimitedData(delimchar, indata)
  
      colmaplen = @columnNames.length
      delim = nil
      if (delimchar.class == Regexp)
        delim = delimchar.source
      else
        delim = delimchar
      end
      
      # --- Header
      @columnNames.each_with_index do |colname, idx|
        STDOUT.print("#{colname}")        
        STDOUT.print(delim) if idx < colmaplen-1
      end
      
      STDOUT.print("\n")
      
      # --- Data
      indata.each do |datum|
        @columnNames.each_with_index do |colname, colid|
          STDOUT.print("#{datum[colname]}")
          STDOUT.print(delim) if colid < colmaplen-1
        end
        STDOUT.print("\n")
      end                 
   end

   # Write data with default delimiter splitchar
   def writeData(filename)
   	 writeDelimitedData(filename, @@splitchar, @data)
   end
   
   # Assumes indata has same columns as @columnNames 
   def writeCommaDelimitedInputData(filename, indata)
     writeDelimitedData(filename, /,/, indata)
   end

   # Comma-delimited output file
   def writeCommaDelimitedData(filename)
     writeDelimitedData(filename, /,/, @data)
   end
   
   # Tab-delimited output file
   def writeTabDelimitedInputData(filename, indata)
     writeDelimitedData(filename, "\t", indata)
   end
  
   # Tab-delimited output file
   def writeTabDelimitedData(filename)
     writeDelimitedData(filename, "\t", @data)
   end
   
   # Comma-delimited data to stdout
   def stdoutCommaDelimitedData()
     stdoutDelimitedData(/,/, @data)
   end
   
   # Tab-delimited output file
   def stdoutTabDelimitedData()
     stdoutDelimitedData("\t", @data)
   end
   
end # end class