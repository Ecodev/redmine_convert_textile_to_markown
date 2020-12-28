task :count_tables => :environment do
    convert = {
      Comment =>  [:comments],
      WikiContent => [:text],
      Issue =>  [:description],
      Message => [:content],
      News => [:description],
      Document => [:description],
      Project => [:description],
      Journal => [:notes],
    }

    count_success = 0
    count_failure = 0
    print 'WelcomeText'
    content = Setting.welcome_text
    if content != nil
      check(content, "welcome text")
    end
    count_success += 1
    puts

    convert.each do |the_class, attributes|
      print the_class.name
      the_class.find_each do |model|
        begin
          # We may encounter errors when saving the new value.
          # For example, if it exceeds the maximum size allowed by SQL column
          attributes.each do |attribute|
            content = model[attribute]
            if content != nil
              check(content, "#{the_class}-#{model.id}")
            end
          end
        rescue
          count_failure += 1
          puts
          puts "Check failed for #{the_class} with id #{model.id}"
        else
          count_success += 1
        end
      end
      puts
    end
    puts "Done converting #{count_success} models"
    puts "Failed converting #{count_failure} models"
  end

  def check(content, what)
    write = false
    if content.include?("<table")
      puts "WARNING: HTML table content in #{what}"
      write = true
    end

    if content.match(/^[^\|]?\s*\|.*$\s*\s*\|/m)
      puts "WARNING: Mardown table content in #{what}"
      write = true
    end

    if write
      File.open(what, 'wb') do |fo|
        fo.write(content)
      end
    end

    return content
  end
